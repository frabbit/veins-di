package veins.di.macros;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.ds.Option;
import haxe.macro.ExprTools;
import veins.di.macros.ContextMacrosImpl;

import veins.di.macros.Tools.safeThisCall as safe;

class ContextMacros
{

	macro public function add (ethis:Expr, f:ExprOf<Function>):Expr
	{
		return safe(ethis, ContextMacrosImpl.add.bind(_, f));
	}

	macro public function remap (ethis:Expr, f:ExprOf<Function>):Expr
	{
		return safe(ethis, ContextMacrosImpl.remap.bind(_, f));
	}

	macro public function resolve (ethis:Expr, t:Expr):Expr
	{
		return safe(ethis, ContextMacrosImpl.resolve.bind(_, t));
	}

	macro public function run (ethis:Expr, f:ExprOf<Function>):Expr
	{
		return safe(ethis, ContextMacrosImpl.run.bind(_, f));
	}

}