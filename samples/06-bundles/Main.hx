package ;

import veins.di.Module;

typedef X = { a : Int, b : String }

class Main {

	static function main ()
	{

		var ctx = Module.make()
		.add( function () return "1" )
		.add( function () return 1 )
		.addBundle( ( _ : X ) )
		.run(function (b:X) {
			trace(b);
		})
		.bootstrap();
	}
}