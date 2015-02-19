package ;

import veins.di.Context;

class Main {

	static function main ()
	{
		var subA = new Context().add(A.new);

		var subB = new Context().add(B.new);


		var ctx = new Context([subA, subB])
		.add(C.new)
		.run(function (c:C) {
			c.startup();
		})
		.bootstrap();
	}
}

class A {
	public var name = "A";
	public function new () {}
}
class B {
	public var name = "B";
	public function new () {}
}

class C {
	var a:A;
	var b:B;
	public function new (a:A, b:B) {
		this.a = a;
		this.b = b;
	}

	public function startup () {
		trace(a.name);
		trace(b.name);
	}
}