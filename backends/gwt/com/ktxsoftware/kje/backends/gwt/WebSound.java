package com.ktxsoftware.kje.backends.gwt;

import com.google.gwt.dom.client.AudioElement;
import com.google.gwt.dom.client.MediaElement;
import com.google.gwt.media.client.Audio;
import com.google.gwt.user.client.ui.RootPanel;
import com.ktxsoftware.kje.Sound;

public class WebSound implements Sound {
	private AudioElement element;
	
	public WebSound(String filename) {
		Audio audio = Audio.createIfSupported();
		if (audio != null) {
			RootPanel.get().add(audio);
			element = audio.getAudioElement();
			if (element.canPlayType("audio/mp4") == MediaElement.CANNOT_PLAY) element.setSrc(filename + ".ogg");
			else element.setSrc(filename + ".mp4");
			element.setPreload(MediaElement.PRELOAD_AUTO);
		}
	}
	
	@Override
	public void play() {
		if (element == null) return;
		try {
			element.setCurrentTime(0);
		}
		catch (Exception ex) {
			
		}
		element.play();
	}

	@Override
	public void stop() {
		if (element == null) return;
		element.pause();
	}
}