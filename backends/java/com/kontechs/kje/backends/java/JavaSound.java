package com.kontechs.kje.backends.java;

import java.io.File;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Queue;

import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;

import com.kontechs.kje.Sound;

class SoundThread implements Runnable {
	private ArrayList<JavaSound> sounds = new ArrayList<JavaSound>();
	private Queue<Integer> queue = new ArrayDeque<Integer>();
	
	@Override
	public void run() {
		for (;;) {
			boolean notempty;
			synchronized (this) {
				notempty = !queue.isEmpty();
			}
			while (notempty) {
				JavaSound sound;
				synchronized (this) {
					int index = queue.remove();
					sound = sounds.get(index);
					notempty = !queue.isEmpty();
				}
				sound.realplay();
			}
			synchronized (this) {
				try {
					wait();
				}
				catch (InterruptedException e) {
					
				}
			}
		}
	}
	
	public synchronized int addSound(JavaSound sound) {
		sounds.add(sound);
		return sounds.size() - 1;
	}
	
	public synchronized void play(int index) {
		queue.add(index);
		notify();
	}
}

public class JavaSound implements Sound {
	private static SoundThread thread;
	private Clip clip;
	private int index;
	
	public JavaSound(String filename) {
		try {
			AudioInputStream stream = AudioSystem.getAudioInputStream(new File(filename));
			clip = AudioSystem.getClip();
			clip.open(stream);
		} catch (Exception e) {
			e.printStackTrace();
		}
		
		if (thread == null) {
			thread = new SoundThread();
			Thread realthread = new Thread(thread);
			realthread.start();
		}
		index = thread.addSound(this);
	}
	
	@Override
	public void play() {
		thread.play(index);
	}
	
	public void realplay() {
		if (!clip.isRunning()) {
			clip.setFramePosition(0);
			clip.loop(0);
		}
		else clip.setFramePosition(0);
	}
}