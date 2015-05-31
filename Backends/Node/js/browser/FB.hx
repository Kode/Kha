package js.browser;

typedef FBLoginOptions = {
	?scope : String,
	?enable_profile_selector : Bool,
	?profile_selector_ids : String
}

@:native('FB')
extern class FB {
	public static function login( cb : Dynamic->Void , opts : FBLoginOptions ) : Void;
}