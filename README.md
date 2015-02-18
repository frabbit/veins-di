# veins-di
Very simple, lightweight and compile-time-type driven dependency injection framework for Haxe.

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