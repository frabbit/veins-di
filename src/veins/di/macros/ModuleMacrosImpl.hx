package veins.di.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.ds.Option;
import haxe.macro.TypeTools;
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

		var t = typeofNormalized(te);

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
	static function err <T>(str:String, pos):T {
		Context.error(str, pos);
		throw "error";
	}

	public static function addBundle(ethis:Expr, b:ExprOf<{}>):Expr
	{

		var r = switch (b.expr)
		{
			case EParenthesis( { expr : ECheckType(macro _, ct) }):
				var expr = macro @:pos(b.pos) ( null : $ct );
				{ ct: ct, expr : expr };
			case _ : err("expression must be checktype like addBundle(( _ : MyType ))", b.pos);
		}
		var ct = r.ct;
		var typeExpr = r.expr;
		var t = typeofNormalized(typeExpr);

		return switch [t, Context.follow(t)]
		{
			case [TType(_,_), TAnonymous(a)]:
				var afields = a.get().fields;

				var funArgs = [for (f in afields) { name : f.name, type : TypeTools.toComplexType(f.type) }];
				var objFields = [for (f in afields) { field : f.name, expr : macro @:pos(b.pos) $i{f.name} }];

				var res = { expr : EObjectDecl(objFields), pos : b.pos }

				var f = EFunction(null, {
					args : funArgs,
					ret : ct,
					expr : macro return $res
				});
				var fexpr = { expr : f, pos : b.pos };
				macro $ethis.add($fexpr);
			case _ :
				err("error type of argument is not a structure aliases by a typedef", b.pos);
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

		var t = typeofNormalized(f);

		var v = switch extractTFun(t)
		{
			case Some({ args : args, ret : Tools.isVoid(_) => true }):
				err("the return type of f should be a valid type, not Void", cpos);
			case None:
				err("f must be a function returning a type", cpos);
			case Some(x): x;
		}

		var injectArgs = convertArgsToCalls(ethis, v.args, true, cpos);

		var name = switch (castType)
		{
			case Some({ t : x}):
				try {
					var ct = haxe.macro.TypeTools.toComplexType(v.ret);
					var t = typeofNormalized(macro ( (cast null : $ct) : $x));
					Tools.typeToStringId(t);
				} catch (x:Error) {
					//throw new Error(x, origExpr.pos);
					err(x.message, origExpr.pos);

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

		var t = typeofNormalized(f);

		var v = switch extractTFun(t)
		{
			case Some({ args : args, ret : Tools.isVoid(_) => true }):
				err("the return type of f should be a valid type, not Void", cpos);
			case Some(x = { args : [_]}): x;
			case _:
				err("f must be a function with one argument and one returntype", cpos);
		}

		var name = Tools.typeToStringId(v.ret);

		var f = macro function (x) return ($f)(x);

		var ret = macro (@:privateAccess $ethis.remapDynamic)($v{name}, $f );

		return ret;
	}

	static function typeofNormalized (f:Expr) {
		var t = Context.typeof(f);
		Tools.typeNormalize(t);
		return t;
	}

	public static function run (ethis:Expr, f:ExprOf<Function>):Expr
	{
		var cpos = Context.currentPos();

		var origExpr = f;

		var t = typeofNormalized(f);


		var v = switch (t) {
			case TFun(args, Tools.isVoid(_) => false):
				err("the return type of f should be Void", cpos);
			case TFun(args, Tools.isVoid(_) => true):
				convertArgsToCalls(ethis, args, true, cpos);
			default:
				err("f must be a function returning a type", cpos);
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
		return [for (i in 0...args.length) {
			var a = args[i];
			var lazy = isLazyTFun(a.t);

			var t = switch (a.t) {
				case TFun([], ret): ret;
				case _ : a.t;
			}

			var varType = if (!lazy) haxe.macro.TypeTools.toComplexType(TFun([], a.t)) else haxe.macro.TypeTools.toComplexType(a.t);


			var name = Tools.typeToStringId(t);

			var varName = "_a_inject_" + i;

			var id 	= Context.makeExpr(name, cpos);

			var vname = macro @:pos(cpos) $i{varName};

			var assign = macro @:pos(cpos) var $varName:$varType = (@:privateAccess $ctx.resolveDynamic($id));


			{ lazy : lazy, assign : assign , arg : vname };
		}];
	}

	#end
}