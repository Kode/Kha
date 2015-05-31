package js.npm.mailchimp;

typedef MandrillAPIOptions = {
	version : String,
	?secure : Bool
}

extern class MandrillAPI 
implements npm.Package.RequireNamespace<"mailchimp","*">
{
	public function new( apiKey : String , options : MandrillAPIOptions ) : Void;
	public function call( section : String , method : String , params : {} , callback : js.support.Callback<Dynamic>) : Void;

}