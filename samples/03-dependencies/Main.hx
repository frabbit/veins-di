package ;

import veins.di.Module;

class Main {

	static function main ()
	{
		var subA = Module.make().add(A.new);

		var subB = Module.make().add(B.new);


		var ctx = Module.make([subA, subB])
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