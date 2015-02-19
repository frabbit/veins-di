package ;

import veins.di.Context;

class Main {

	static function main ()
	{
		var ctx = new Context();

		ctx.add( A.new )
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