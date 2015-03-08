package ;

import veins.di.Module;

class Main {

	static function main ()
	{
		Module.make().add( A.new )
		.add( B.new )
		.run(function (b:B) {
			b.startup();
		})
		.bootstrap();
	}
}

class A {
	public var name = "A";
	public function new (b:B) {}
}

class B {
	var a:Void->A;
	public function new (a:Void->A) {
		this.a = a;
	}

	public function startup () {
		trace(a().name);
	}
}