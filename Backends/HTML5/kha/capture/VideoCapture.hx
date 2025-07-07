package kha.capture;

import js.Browser.navigator;
import js.Browser;

class VideoCapture {
	public static function init(initialized: kha.Video->Void, error: Void->Void): Void {
		final getUserMedia = (navigator : Dynamic).getUserMedia;
		getUserMedia.call(navigator, {audio: true, video: true}, function(stream: Dynamic) {
			final element = Browser.document.createVideoElement();
			element.srcObject = stream;
			element.onloadedmetadata = function(e) {
				initialized(kha.js.Video.fromElement(element));
			}
		}, function() {
			error();
		});
	}
}
