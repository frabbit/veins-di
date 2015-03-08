
package veins.di.macros;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.TypeTools;


class Tools {

	#if macro

	public static function safeThisCall (ethis:haxe.macro.Expr, f:haxe.macro.Expr->haxe.macro.Expr)
	{
		var type = haxe.macro.Context.typeof(ethis);
		var ct = haxe.macro.TypeTools.toComplexType(type);
		var replacement = macro (__x : $ct);
		var res = f(replacement);
		return macro @:mergeBlock {
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

	static function safeStringId (id:String)
	{
		return id
			.split("->").join("_arrow_")
			.split(":").join("_colon_")
			.split(" ").join("_")
			.split("<").join("_abo_")
			.split(">").join("_abc_")
			.split("{").join("_bo_")
			.split("}").join("_bc_")
			.split("(").join("_po_")
			.split(")").join("_pc_")
			.split(",").join("_comma_")
			.split("?").join("_qm_")
			.split(".").join("_dot_");
	}


	public static function typeToStringId (t:Type):String
	{
		function def (t:Type)
		{
			return safeStringId(TypeTools.toString(t));
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
	#end

}