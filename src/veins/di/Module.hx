package veins.di;

import veins.di.macros.ModuleMacros;
import haxe.ds.GenericStack;
import haxe.ds.Option;
import haxe.macro.Expr;
import veins.di.macros.Tools;

class Module extends ModuleMacros
{

	var registry : Map<String, Void->Dynamic>;

	var instances : Map<String, Void->Dynamic>;

	var remaps : Map<String, Array<Dynamic->Dynamic>>;

	var runs : Array<Void->Void>;

	var dependencies : Array<Module>;

	var resolveStack : Array<String> = [];

	function new (?dependencies:Array<Module>)
	{
		registry = new Map();
		instances = new Map();
		remaps = new Map();
		runs = [];
		this.dependencies = dependencies == null ? [] : dependencies;

	}

	public static function make (?dependencies:Array<Module>) {
		return new Module(dependencies);
	}

	public function bootstrap ()
	{
		for (r in runs) {
			r();
		}
		return this;
	}

	function remapDynamic <R:T, T>(id:String, f:T->R)
	{
		var arr = if (remaps.exists(id)) {
			remaps.get(id);
		} else {
			var c = [];
			remaps.set(id, c);
			c;
		}
		arr.push(f);
		return this;
	}

	function addDynamic (id:String, f : Void->Dynamic):Module
	{
		if (registry.exists(id)) {
			throw "instance for type " + id + "already registered";
		}
		registry.set(id, f);
		return this;
	}

	function resolveDynamic (id:String):Void->Dynamic
	{
		return if (instances.exists(id))
		{
			instances.get(id);
		}
		else
		{
			var f = resolveDynamicNew(id);
			var instance = null;

			function c()
			{
				if (instance == null)
				{
					var isCircular = resolveStack.indexOf(id) != -1;
					if (isCircular) throw "Circular Dependency:\n=> " + resolveStack.join("\n=> ") + "\n=> " + id;
					resolveStack.push(id);
					var res = f();
					if (remaps.exists(id)) {
						for (c in remaps.get(id)) {
							var newRes = c(res);
							if (newRes == res) throw "a remap function must return a different instance for " + id;
							res = newRes;
						}
					}
					resolveStack.pop();
					instance = res;
				}
				return instance;

			}

			instances.set(id, c);
			c;
		}
	}



	function resolveDynamicNew (id:String):Void->Dynamic
	{

		return if (registry.exists(id))
		{
			registry.get(id);
		}
		else switch dependencies {
			case []:
				throw "cannot find instance for type " + id;
			case deps:
				var found = null;
				for (d in deps) {
					try {
						found = d.resolveDynamic(id);
						break;
					} catch (e:Dynamic) {}
				}
				if (found == null) {
					throw "cannot find instance for type " + id;
				}
				found;
		}
	}

	function runDynamic (f:Void->Void) {
		runs.push(f);
		return this;
	}




}
