package js.npm;

import js.html.DOMWindow;
import js.support.Callback;

extern class Jsdom
implements npm.Package.Require<"jsdom","*"> {
	public static function env( html : String , callback : Callback<DOMWindow> ) : Void;
}

typedef JsdomConfig = {
	?html : String,
	?file : String,
	?url : String,
	?scripts : Array<String>,
	?src : String,
	done : Callback<DOMWindow>,
	?document : {
		?referer : String,
		?cookie : String,
		?cookieDomain : String
	},
	features : Dynamic
}