package js.npm.passport;

import js.support.Callback;


typedef FacebookStrategyConfig = {
	clientID : String,
	clientSecret : String,
	callbackURL : String
}

@:native('Strategy')
extern class FacebookStrategy
implements js.npm.passport.Strategy
implements npm.Package.RequireNamespace<"passport-facebook","*">
{
	public function new( config : FacebookStrategyConfig , cb : String -> String -> Profile -> Callback<Dynamic> -> Void ) : Void;
}