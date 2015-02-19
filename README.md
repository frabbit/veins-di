# veins-di
Very simple, lightweight and compile-time-type driven dependency injection framework for Haxe.

## Example Usage
```haxe
import veins.di.Context;

class Main {

	static function main () {

		var ctx = new Context();

		ctx.add( Config.new )
		.add( App.new )
		.run(function (app:App) {
			app.startup();
		})
		.bootstrap();
	}
}
class Config {

	public var applicationName = "MyApp";

	public function new () {}
}

class App {
	var cfg:Config;
	public function new (cfg:Config) {
		this.cfg = cfg;
	}

	public function startup () {
		trace(cfg.applicationName);
	}
}
```

## Lazy Injection to avoid the problem of circular dependencies.

```haxe
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
```

## Context Dependencies

```haxe
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
```