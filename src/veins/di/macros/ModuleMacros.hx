package veins.di.macros;


import haxe.macro.Expr;

#if macro
import veins.di.macros.ModuleMacrosImpl;
import veins.di.macros.Tools.safeThisCall as safe;
#end

class ModuleMacros
{

	macro public function add (ethis:Expr, f:ExprOf<Function>):Expr
	{
		return safe(ethis, ModuleMacrosImpl.add.bind(_, f));
	}

	macro public function addBundle (ethis:Expr, o:ExprOf<{}>):Expr
	{
		return safe(ethis, ModuleMacrosImpl.addBundle.bind(_, o));
	}

	macro public function resolve (ethis:Expr, t:Expr):Expr
	{
		return safe(ethis, ModuleMacrosImpl.resolve.bind(_, t));
	}

	macro public function run (ethis:Expr, f:ExprOf<Function>):Expr
	{
		return safe(ethis, ModuleMacrosImpl.run.bind(_, f));
	}

}