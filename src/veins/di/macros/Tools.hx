package veins.di.macros;

#if macro
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.TypeTools;


class Tools {

	public static function safeThisCall (ethis:haxe.macro.Expr, f:haxe.macro.Expr->haxe.macro.Expr)
	{
		var type = haxe.macro.Context.typeof(ethis);
		var ct = haxe.macro.TypeTools.toComplexType(type);
		var replacement = macro @:pos(ethis.pos) (__x : $ct);
		var res = f(replacement);
		return macro @:pos(ethis.pos) @:mergeBlock {
			var __x = $ethis;
			$res;
		}
	}

	public static function isVoid (t:Type)
	{
		return switch (t) {
			case TAbstract(_.get() => { pack : [], name : "Void"}, []):
				true;
			case _ :
				false;
		}
	}

	static function fullQualified(pack:Array<String>, module:String, typeName:String)
	{
		var pack = pack.join(".");
		var infix = if (pack.length > 0) "." else "";
		return pack + infix + typeName;
	}

	public static function typeNormalize (t:Type)
	{
		TypeTools.iter(t, function f (t1) {
			switch (t1) {
				case null:
				case TFun(args, ret):
					for (a in args) {
						a.name = "";
						typeNormalize(a.t);
					}
					typeNormalize(ret);
				case _: typeNormalize(t1);
			}

		});

	}

	public static function typeToStringId (t:Type):String
	{
		function def (t:Type)
		{
			return TypeTools.toString(t);
		}

		return switch (t)
		{
			case TInst(_, _), TType(_, _), TEnum(_,_), TAbstract(_,_), TFun(_,_), TAnonymous(_):
				def(t);
			case TDynamic(x) if (x != null): def(t);
			case TLazy(f):
				typeToStringId(f());
			case TMono(_), TDynamic(_):
				throw "not supported type '" + haxe.macro.TypeTools.toString(t) + "'";
		}
	}
}
#end
