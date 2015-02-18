import veins.di.Context;

typedef MyFilter = Int->Int;

class Config  implements IConfig {
	var NAME = "Config";
	public function new () {}
}

interface IConfig {

}

interface IAFactoryConfig {
	public var cfg : IConfig;
}

class AFactoryConfig  implements IAFactoryConfig {
	public var cfg : IConfig;
	public function new (cfg:IConfig) {
		this.cfg = cfg;
	}
}

class AFactory {

	public var cfg : IAFactoryConfig;

	var b : Void->B;
	var c : Void->C;

	public function new (cfg:IAFactoryConfig, b:Void->B, c:Void->C) {
		this.cfg = cfg;
		this.b = b;
		this.c = c;
	}

	public function createA () {
		return new A(b(), c());
	}
}

class A {
	var NAME = "A";

	public var b : B;

	public var c : C;

	public function new (b:B, c:C)
	{
		this.b = b;
		this.c = c;

	};
}


class B {
	var NAME = "B";

	public function new () {

	};
}

class C {
	public var NAME = "C";

	public function new () {

	};
}

class D {
	public var NAME = "D";

	public var b : B;
	public var c : C;

	public function new (b:B, c:C) {
		this.b = b;
		this.c = c;
	};
}

class Main {

	static function main ()
	{
		var parent =
			new Context()
			.add( AFactory.new )
			.add( ( AFactoryConfig.new : IAFactoryConfig ) )
			.add( ( Config.new : IConfig ) )
			.add( C.new )
			.add( B.new )
			.bootstrap();


		var ctx =
			new Context([parent])
			.add( D.new )
			.run (function (x:AFactory) {
				trace(x.cfg.cfg);
				var a1 = x.createA();
				var a2 = x.createA();

				trace(a1.b == a2.b);
				trace(a1.c == a2.c);
			})
			.run (function (d:D) {
				trace(d);
				trace(d.b);
				d.NAME;
			})
			.run (function (c:C) {
				trace(c);
				c.NAME;
			})
			.bootstrap();

	}
}
