package veins.di.macros;


import haxe.macro.Expr;

#if macro
import veins.di.macros.ContextMacrosImpl;
import veins.di.macros.Tools.safeThisCall as safe;
#end

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