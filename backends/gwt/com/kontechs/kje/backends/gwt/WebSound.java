package com.kontechs.kje.backends.gwt;

import com.google.gwt.dom.client.AudioElement;
import com.google.gwt.dom.client.MediaElement;
import com.google.gwt.media.client.Audio;
import com.google.gwt.user.client.ui.RootPanel;

import com.kontechs.kje.Sound;

public class WebSound implements Sound {
	private AudioElement element;
	
	public WebSound(String filename) {
		Audio audio = Audio.createIfSupported();
		if (getUserAgent().contains("msie")) audio = null; //not working in IE9
		if (audio != null) {
			RootPanel.get().add(audio);
			element = audio.getAudioElement();
			element.setSrc(filename + ".wav");
			element.setPreload(MediaElement.PRELOAD_AUTO);
		}
	}
	
	@Override
	public void play() {
		if (element == null) return;
		element.setCurrentTime(0);
		element.play();
	}

	@Override
	public void stop() {
		if (element == null) return;
		element.pause();
	}
	
	public static native String getUserAgent() /*-{
	return navigator.userAgent.toLowerCase();
	}-*/;
}