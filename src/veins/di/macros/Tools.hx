
package veins.di.macros;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.TypeTools;


class Tools {

	static var replaceMap = [
		"-" => "_dash_",
		":" => "_colon_",
		" " => "_s_",
		"<" => "_abo_",
		">" => "_abc_",
		"{" => "_bo_",
		"}" => "_bc_",
		"(" => "_po_",
		")" => "_pc_",
		"," => "_comma_",
		"?" => "_qm_",
		"." => "_dot_"
	];

	public static function idToType (id:String)
	{
		var r = id;
		for (k in replaceMap.keys()) {
			r = r.split(replaceMap.get(k)).join(k);
		}
		return r;
	}

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
		var r = id;
		for (k in replaceMap.keys()) {
			r = r.split(k).join(replaceMap.get(k));
		}
		return r;
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