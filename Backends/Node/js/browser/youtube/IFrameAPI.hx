package js.browser.youtube;

import js.Browser;
import js.html.ScriptElement;

/**

	Helper for Youtube Iframe API

**/

class IFrameAPI {

	static var iframeAPICallbacks : Array<Void->Void>;
	static var ready = false;
	static var injected = false;

	static inline var SCRIPT_URL = "https://www.youtube.com/iframe_api";

	/**

	Injects the script and then call "callback"

	**/

	public static function load( cb : Void->Void ){

		if( ready ){
			Browser.window.setTimeout(cb,1);
			return;
		}

		if( iframeAPICallbacks == null )
			iframeAPICallbacks = [];
		
		iframeAPICallbacks.push(cb);

		if( !injected ){
			var doc = Browser.document;
			var script : ScriptElement = cast doc.createElement("script");
			script.src = SCRIPT_URL;

			var firstScript = doc.getElementsByTagName("script")[0];
			firstScript.parentNode.insertBefore(script,firstScript);

			untyped Browser.window.onYouTubeIframeAPIReady = onYouTubeIframeAPIReady;
			injected = true;
		}

	}
	static function onYouTubeIframeAPIReady(){
		ready = true;
		if( iframeAPICallbacks == null ) return;
		for( cb in iframeAPICallbacks ){
			cb();
		}
	}
}