package js.npm;

import js.support.Callback;

typedef EjsTemplate = {} -> String;
typedef EjsOptions = {
	?cache : Bool,
	?filename : String,
	?scope : Dynamic,
	?debug : Bool,
	?compileDebug : Bool,
	?client : Bool,
	?open : String,
	?close : String
}

extern class Ejs
implements npm.Package.Require<"ejs","*">
{
	public static function compile(str:String,opts:EjsOptions) : EjsTemplate;
	public static function renderFile( path : String , options : {} , cb : Callback<String> ) : Void;
	public function render(str:String,opts:EjsOptions) : String;
}