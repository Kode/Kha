package kha.capture;

import js.Browser;

class VideoCapture {
	public static function init(initialized: kha.Video->Void, error: Void->Void): Void {
		var getUserMedia = untyped __js__("navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia || navigator.msGetUserMedia");
		getUserMedia.call(js.Browser.navigator, {audio: true, video: true}, function(stream: Dynamic) {
			var element: js.html.VideoElement = cast Browser.document.createElement("video");
			element.srcObject = stream;
			element.onloadedmetadata = function(e) {
				initialized(kha.js.Video.fromElement(element));
			}
		}, function() {
			error();
		});
	}
}
