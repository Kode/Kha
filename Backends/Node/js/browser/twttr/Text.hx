package js.browser.twttr;

typedef TwitterTextEntity = {
	indices : Array<Int>,
	?hashtag : String,
	?screenName : String,
	?url : String
}

@:native('twttr.txt')
extern class Text {
	
	// TODO

	public static function extractEntitiesWithIndices( txt : String ) : Array<TwitterTextEntity> {}
	public static function getTweetLength( txt:String ) : Int {}

}