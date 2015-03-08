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