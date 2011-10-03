package com.ktx.kje.backends.gwt;

import com.google.gwt.dom.client.AudioElement;
import com.google.gwt.dom.client.MediaElement;
import com.google.gwt.media.client.Audio;
import com.google.gwt.user.client.ui.RootPanel;

import com.ktx.kje.Music;

public class WebMusic implements Music {
	private AudioElement element;
	
	public WebMusic(String filename) {
		Audio audio = Audio.createIfSupported();
		if (audio != null) {
			RootPanel.get().add(audio);
			element = audio.getAudioElement();
			if (element.canPlayType("audio/mp3") == MediaElement.CANNOT_PLAY) element.setSrc(filename + ".ogg");
			else element.setSrc(filename + ".mp3");
			element.setAttribute("loop", "true");
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