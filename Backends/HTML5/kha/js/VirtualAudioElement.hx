package kha.js;

import js.Browser;
import js.html.AudioElement;
import kha.Scheduler;

using StringTools;

class VirtualAudioElement {
	var element: AudioElement;
	var filenames: Array<String>;
	var startTime: Float;

	public function new(filenames: Array<String>) {
		element = Browser.document.createAudioElement();

		this.filenames = [];
		for (filename in filenames) {
			if (element.canPlayType("audio/ogg") != "" && filename.endsWith(".ogg")) this.filenames.push(filename);
			if (element.canPlayType("audio/mp4") != "" && filename.endsWith(".mp4")) this.filenames.push(filename);
		}

		//element.addEventListener("error", errorListener, false);
		//element.addEventListener("canplay", canPlayThroughListener, false);

		element.src = this.filenames[0];
		element.preload = "auto";
		element.load();
	}

	public function play() {
		startTime = Scheduler.time();

	}

	public function resume() {
		element.currentTime = Scheduler.time() - startTime;
		element.play();
	}
}
