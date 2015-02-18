package veins.di.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.ds.Option;
import haxe.macro.ExprTools;



class ContextMacros
{

	#if macro
	static function thisHelper (ethis, call, args)
	{
		var allArgs = [macro @:pos(call.pos) __ctx].concat(args);

		var e = macro @:pos(call.pos) {
			var __ctx = $ethis;
			$call($a{allArgs});
		};
		return e;
	}
	#end

	macro public function add (ethis:Expr, f:ExprOf<Function>):Expr
	{
		return thisHelper(ethis, macro @:pos(f.pos) veins.di.macros.ContextMacros.addStatic, [f]);
	}

	macro public static function addStatic (ethis:Expr, f:ExprOf<Function>):Expr
	{
		return veins.di.macros.ContextMacrosImpl.add(ethis, f);
	}

	macro public function remap (ethis:Expr, f:ExprOf<Function>):Expr
	{
		return thisHelper(ethis, macro @:pos(f.pos) veins.di.macros.ContextMacros.remapStatic, [f]);
	}

	macro public static function remapStatic (ethis:Expr, f:ExprOf<Function>):Expr
	{
		return veins.di.macros.ContextMacrosImpl.remap(ethis, f);
	}

	macro public function resolve (ethis:Expr, t:Expr):Expr
	{
		return thisHelper(ethis, macro @:pos(t.pos) veins.di.macros.ContextMacros.resolveStatic, [t]);
	}

	macro public static function resolveStatic (ethis:Expr, t:Expr):Expr
	{
		return veins.di.macros.ContextMacrosImpl.resolve(ethis, t);
	}

	macro public function run (ethis:Expr, f:ExprOf<Function>):Expr
	{
		return thisHelper(ethis, macro @:pos(f.pos) veins.di.macros.ContextMacros.runStatic, [f]);
	}

	macro public static function runStatic (ethis:Expr, f:ExprOf<Function>):Expr
	{
		return veins.di.macros.ContextMacrosImpl.run(ethis, f);
	}


}