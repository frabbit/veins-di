package ;

import veins.di.Module;

class Main {

	static function main ()
	{

		var ctx = Module.make()
		.add( function ():{ a : Void -> { z : Int}, ?b : Array<Int> } {
			return { a : function () return { z : 1} , b : [1] };
		})
		.run(function (ct:{ a : Void -> { z : Int}, ?b : Array<Int> }) {
			trace(ct);
		})
		.run(function (ct:Void->{ a : Void -> { z : Int}, ?b : Array<Int> }) {
			trace(ct());
		})
		.bootstrap();
	}
}