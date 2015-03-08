package ;

import veins.di.Module;

class Main {

	static function main ()
	{

		var ctx = Module.make()
		.add( function ():{ a : Void -> { z : Int}, ?b : Array<Int>, y : haxe.ds.Option<Int> } {
			return { a : function () return { z : 1} , b : [1], y : haxe.ds.Option.Some(1) };
		})
		.run(function (ct:{ a : Void -> { z : Int}, ?b : Array<Int>, y : haxe.ds.Option<Int> }) {
			trace(ct);
		})

		.bootstrap();
	}
}