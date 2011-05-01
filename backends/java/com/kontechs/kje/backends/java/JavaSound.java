package com.kontechs.kje.backends.java;

import java.io.File;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.Queue;

import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.sound.sampled.LineUnavailableException;

import com.kontechs.kje.Sound;

class SoundThread implements Runnable {
	private ArrayList<JavaSound> sounds = new ArrayList<JavaSound>();
	private Queue<Integer> queue = new ArrayDeque<Integer>();
	private ArrayDeque<JavaSound> soundqueue = new ArrayDeque<JavaSound>();
	
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
				if (soundqueue.contains(sound)) soundqueue.remove(sound);
				soundqueue.push(sound);
				if (!sound.isLoaded()) {
					if (soundqueue.size() < 30) {
						try {
							Clip clip = AudioSystem.getClip();
							sound.load(clip);
						}
						catch (LineUnavailableException e) {
							e.printStackTrace();
						}
					}
					else {
						Iterator<JavaSound> it = soundqueue.descendingIterator();
						while (true) {
							JavaSound last = it.next();
							if (last.isLoaded()) {
								Clip clip = last.unload();
								sound.load(clip);
								break;
							}
						}
					}
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
	
	public synchronized void stop(int index) {
		queue.remove(index);
		notify();
	}
}

public class JavaSound implements Sound {
	private static SoundThread thread;
	private Clip clip;
	private int index;
	private String filename;
	
	public JavaSound(String filename) {
		this.filename = filename;
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
	
	@Override
	public void stop() {
		if (clip.isRunning()) {
			clip.stop();
		}
		thread.stop(index);
	}
	
	public void load(Clip clip) {
		this.clip = clip;
		AudioInputStream stream;
		try {
			stream = AudioSystem.getAudioInputStream(new File("../data/sounds/" + filename + ".wav"));
			clip.close();
			clip.open(stream);
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public Clip unload() {
		Clip clip = this.clip;
		this.clip = null;
		return clip;
	}
	
	public boolean isLoaded() {
		return clip != null;
	}
	
	public void realplay() {
		if (!clip.isRunning()) {
			clip.setFramePosition(0);
			clip.loop(0);
		}
		else clip.setFramePosition(0);
	}
	
	public boolean isRunning() {
		return clip.isRunning();
	}
}