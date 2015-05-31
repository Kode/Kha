package js.npm.mailchimp;

typedef MailChimpAPIOptions = {
	version : String,
	?secure : Bool
}

extern class MailChimpAPI 
implements npm.Package.RequireNamespace<"mailchimp","*">
{
	public function new( apiKey : String , options : MailChimpAPIOptions ) : Void;
	public function call( section : String , method : String , params : {} , callback : js.support.Callback<Dynamic>) : Void;

}