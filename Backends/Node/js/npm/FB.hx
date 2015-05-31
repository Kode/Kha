package js.npm;

extern class FB 
implements npm.Package.Require<"fb","*">
{
	@:overload( function( fql : String , options : {} , cb : Dynamic -> Void ) : Void {} )
	public static function api( url : String , method : String, ?options : {}, cb : Dynamic->Void ) : Void;

}