package veins.di;

import veins.di.macros.ContextMacros;
import haxe.ds.GenericStack;
import haxe.ds.Option;
import haxe.macro.Expr;

class Context extends ContextMacros
{

	var registry : Map<String, Void->Dynamic>;

	var instances : Map<String, Void->Dynamic>;

	var remaps : Map<String, Array<Dynamic->Dynamic>>;

	var runs : Array<Void->Void>;

	var dependencies : Array<Context>;

	var resolveStack : Array<String> = [];

	public function new (?dependencies:Array<Context>)
	{
		registry = new Map();
		instances = new Map();
		remaps = new Map();
		runs = [];
		this.dependencies = dependencies == null ? [] : dependencies;

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

	function addDynamic (id:String, f : Void->Dynamic):Context
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
					var isCircular = Lambda.exists(resolveStack, function (x) return x == id);
					if (isCircular) throw "Circular Dependency:\n=> " + resolveStack.join("\n=> ") + "\n=> " + id;
					resolveStack.push(id);
					var res = f();
					if (remaps.exists(id)) {
						for (c in remaps.get(id)) {
							res = c(res);
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
						found = d.resolveDynamicNew(id);
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
