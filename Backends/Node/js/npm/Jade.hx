package js.npm;

import js.npm.express.ViewEngine;

extern class Jade
implements npm.Package.Require<"jade","*"> {
	public static var __express : ViewEngine;
	// TODO
}