package js.browser.fb;

@:native("FB.Event")
extern class Event {
	public static function subscribe( event : String , method : Dynamic -> Void ) : Void;
	public static function unsubscribe( event : String , method : Dynamic -> Void ) : Void;

}