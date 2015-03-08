# veins-di
Very simple, lightweight and compile-time-type-driven dependency injection framework for Haxe.

## Example Usage
```haxe
import veins.di.Module;

class Main {

	static function main () {

		var ctx = Module.make();

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

## Lazy Injection (to avoid the problem of circular dependencies)

```haxe
import veins.di.Module;

class Main {

	static function main ()
	{
		var ctx = Module.make();

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

## Module Dependencies

```haxe
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
```

## Compile Time Types

```haxe
package ;

import veins.di.Module;

class Main {

	static function main ()
	{

		var ctx = Module.make()
		.add(App.new)
		.add( function ():Point return { x : 1, y : 1 } )
		.add( function ():AppName return "MyApp" )
		.add( function ():String return "someString" )
		.add( Url.new.bind("http://myapp" ) )
		.run(function (a:App) {
			a.startup();
		})
		.bootstrap();
	}
}

class App {

	var p : Point;
	var name : AppName;
	var someString : String;
	var url : Url;

	public function new (p, name, url, str) {
		this.p = p;
		this.name = name;
		this.url = url;
		this.someString = str;
	}

	public function startup () {
		trace(p);
		trace(name);
		trace(url);
		trace(someString);
	}
}

typedef AppName = String;

typedef Point = { x : Int, y : Int };

abstract Url(String) {

	public function new (s:String) {
		this = s;
	}

}
```