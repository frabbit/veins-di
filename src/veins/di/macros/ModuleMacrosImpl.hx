package veins.di.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.ds.Option;
import veins.di.macros.Tools;
import haxe.macro.ExprTools;


class ModuleMacrosImpl
{
	#if macro



	public static function resolve (ethis:Expr, te:Expr):Expr
	{
		var castType = switch getCastType(te) {
			case Some({ t : t}): t;
			case _ : throw "unexpected";
		}

		var t = Context.typeof(te);

		var id = Tools.typeToStringId(t);

		var stringId = Context.makeExpr(id, Context.currentPos());

		return macro (@:privateAccess $ethis.resolveDynamic)($stringId);
	}

	static function getCastType (e:Expr)
	{
		return switch (e.expr)
		{
			case EParenthesis({expr:ECheckType(a,t)}):
				Some({ e : a, t : t});
			case _ :
				None;
		}
	}

	static function extractTFun (t:Type)
	{
		return switch (t) {
			case TFun(args, ret):
				Some({ args : args, ret : ret});
			case _:
				None;
		}
	}

	public static function add (ethis:Expr, f:ExprOf<Function>):Expr
	{

		var cpos = Context.currentPos();

		var origExpr = f;
		var castType = getCastType(f);

		var f = switch castType {
			case Some({ e : e}): e;
			case None : f;
		}

		var t = Context.typeof(f);

		var v = switch extractTFun(t)
		{
			case Some({ args : args, ret : Tools.isVoid(_) => true }):
				Context.error("the return type of f should be a valid type, not Void", cpos);
			case None:
				Context.error("f must be a function returning a type", cpos);
			case Some(x): x;
		}

		var injectArgs = convertArgsToCalls(ethis, v.args, true, cpos);

		var name = switch (castType)
		{
			case Some({ t : x}):
				try {
					var ct = haxe.macro.TypeTools.toComplexType(v.ret);
					var t = Context.typeof(macro ( (cast null : $ct) : $x));
					Tools.typeToStringId(t);
				} catch (x:Error) {
					//throw new Error(x, origExpr.pos);
					haxe.macro.Context.error(x.message, origExpr.pos);

				}
			case None: Tools.typeToStringId(v.ret);
		}

		var assigns = [for (e in injectArgs) e.assign];
		var args = [for (e in injectArgs) if (e.lazy) e.arg else macro @:pos(e.arg.pos) ${e.arg}()];

		var last = macro return ($f)($a{args});

		var blockExprs = assigns.concat([last]);

		var f = macro function () $b{blockExprs};

		var ret = macro (@:privateAccess $ethis.addDynamic)($v{name}, $f );

		return ret;
	}

	public static function remap (ethis:Expr, f:ExprOf<Function>):Expr
	{
		var cpos = Context.currentPos();

		var origExpr = f;

		var t = Context.typeof(f);

		var v = switch extractTFun(t)
		{
			case Some({ args : args, ret : Tools.isVoid(_) => true }):
				Context.error("the return type of f should be a valid type, not Void", cpos);
			case Some(x = { args : [_]}): x;
			case _:
				Context.error("f must be a function with one argument and one returntype", cpos);
		}

		var name = Tools.typeToStringId(v.ret);

		var f = macro function (x) return ($f)(x);

		var ret = macro (@:privateAccess $ethis.remapDynamic)($v{name}, $f );

		return ret;
	}

	public static function run (ethis:Expr, f:ExprOf<Function>):Expr
	{
		var cpos = Context.currentPos();

		var origExpr = f;

		var t = Context.typeof(f);


		var v = switch (t) {
			case TFun(args, Tools.isVoid(_) => false):
				Context.error("the return type of f should be Void", cpos);
			case TFun(args, Tools.isVoid(_) => true):
				convertArgsToCalls(ethis, args, true, cpos);
			default:
				Context.error("f must be a function returning a type", cpos);
		}

		var assigns = [for (e in v) e.assign];
		var args = [for (e in v) if (e.lazy) e.arg else macro ${e.arg}()];

		var last = macro ($f)($a{args});

		var blockExprs = assigns.concat([last]);

		var f = macro function () $b{blockExprs};

		var ret = macro (@:privateAccess $ethis.runDynamic)( $f );

		return ret;
	}


	static function isLazyTFun (t:Type)
	{
		return switch (t) {
			case TFun([], ret): true;
			case _ : false;
		}
	}

	public static function convertArgsToCalls (ctx:Expr, args:Array<{ name : String, opt : Bool, t : Type }>,  mkLazy:Bool, cpos)
	{
		return [for (a in args) {
			var lazy = isLazyTFun(a.t);

			var t = switch (a.t) {
				case TFun([], ret): ret;
				case _ : a.t;
			}

			var varType = if (!lazy) haxe.macro.TypeTools.toComplexType(TFun([], a.t)) else haxe.macro.TypeTools.toComplexType(a.t);


			var name = Tools.typeToSnakeCase(t);
			var path = Tools.typeToStringId(t);

			var varName = "_a" + name;

			var id 	= Context.makeExpr(name, cpos);
			var loc = Context.makeExpr(path, cpos);
			
			var vname = macro @:pos(cpos) $i{varName};

			var assign = macro @:pos(cpos) var $varName:$varType = (@:privateAccess $ctx.resolveDynamic($loc));


			{ lazy : lazy, assign : assign , arg : vname };
		}];
	}

	#end
}