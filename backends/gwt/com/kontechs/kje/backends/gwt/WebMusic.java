package com.kontechs.kje.backends.gwt;

import com.google.gwt.dom.client.AudioElement;
import com.google.gwt.dom.client.MediaElement;
import com.google.gwt.media.client.Audio;
import com.google.gwt.user.client.ui.RootPanel;

import com.kontechs.kje.Music;

public class WebMusic implements Music {
	private AudioElement element;
	
	public WebMusic(String filename) {
		Audio audio = Audio.createIfSupported(); //not supported in IE9
		if (audio != null) {
			RootPanel.get().add(audio);
			element = audio.getAudioElement();
			if (element.canPlayType("audio/ogg") == MediaElement.CANNOT_PLAY) element.setSrc(filename + ".mp3");
			else element.setSrc(filename + ".ogg");
			element.setLoop(true); //Firefox ignores this
			element.setPreload(MediaElement.PRELOAD_AUTO);
		}
	}
	
	@Override
	public void start() {
		if (element != null) element.play();
	}

	@Override
	public void stop() {
		if (element != null) element.pause();
	}
	
	@Override
	public void update() {
		if (element != null && element.getCurrentTime() >= element.getDuration() - 1.0 / 30.0) element.setCurrentTime(0); //for Firefox
	}
}