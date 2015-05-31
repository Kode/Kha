package js.npm.passport;

import js.support.Callback;

typedef TwitterStrategyConfig = {
	consumerKey : String,
	consumerSecret : String,
	callbackURL : String
}

@:native('Strategy')
extern class TwitterStrategy
implements js.npm.passport.Strategy
implements npm.Package.RequireNamespace<"passport-twitter","*">
{
	public function new( config : TwitterStrategyConfig , cb : String -> String -> Profile -> Callback<Dynamic> -> Void ) : Void;
}