package js.npm;

import js.npm.mongoose.*;
import js.support.Callback;

extern class Mongoose
implements npm.Package.Require<"mongoose","*"> {

	/**
	
	Default mongoose instance, ie return value of `require("mongoose")`

	**/
	public static var mongoose : js.npm.mongoose.Mongoose;

	static function __init__() : Void 
		mongoose = untyped Mongoose;
	
}