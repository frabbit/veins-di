package veins.di.macros;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Type;


class Tools {

	#if macro

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

	public static function typeToStringId (t:Type):String
	{
		function def (bt:BaseType)
		{
			var d = bt;
			return fullQualified(d.pack, d.module, d.name);
		}

		return switch (t)
		{
			case TInst(tt, p):
				def(tt.get());
			case TType(tt, p):
				def(tt.get());
			case TEnum(et,_):
				def(et.get());
			case TAbstract(at,_):
				def(at.get());
			case TFun(args,ret):
				[for (a in args) typeToStringId(a.t)].join("_arrow_") + "_arrow_" + typeToStringId(ret);
			case _ : throw "not supported type " + haxe.macro.TypeTools.toString(t);
		}
	}
	#end

}