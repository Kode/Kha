package js.npm;

typedef TwitConfig = {
    consumer_key: String,
    consumer_secret: String,
    ?access_token: String,
    ?access_token_secret: String
}

typedef TwitTweet = {}

typedef TwitAuth = {}

extern class TwitStream {
	public function on( event : String, cb : TwitTweet -> Void  ) : Void;
	public function stop() : Void;
	public function start() : Void;
}

extern class Twit
implements npm.Package.Require<"twit","*"> 
{
	public function new( config : TwitConfig ) : Void;
	public function get( url : String, options : {} , cb : js.support.Callback<Dynamic> ) : Void;
	public function post( url : String, options : {} , cb : js.support.Callback<Dynamic> ) : Void;
	public function stream( url : String , ?options : {} ) : TwitStream;

	public function getAuth() : TwitAuth;
	public function setAuth( auth : TwitAuth ) : Void; 
}