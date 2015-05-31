package js.npm;

import js.npm.express.Request;

extern class ExpressFlash 
implements npm.Package.Require<"express-flash","">
implements js.npm.connect.Middleware
{
	public function new() : Void;
	public static inline function getFlash( req : Request , type : String ) : Dynamic {
		return untyped req.flash( type );
	}
	public static inline function setFlash( req : Request , type : String , msg : Dynamic ) : Void {
		return untyped req.flash( type , msg );
	}
}