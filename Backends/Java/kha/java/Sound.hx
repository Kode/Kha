package kha.java;

import kha.audio1.AudioChannel;

@:classCode('
	class SoundThread implements Runnable {
		private java.util.ArrayList<Sound> sounds = new java.util.ArrayList<Sound>();
		private java.util.Queue<Integer> queue = new java.util.ArrayDeque<Integer>();
		private java.util.ArrayDeque<Sound> soundqueue = new java.util.ArrayDeque<Sound>();
		
		@Override
		public void run() {
			for (;;) {
				boolean notempty;
				synchronized (this) {
					notempty = !queue.isEmpty();
				}
				while (notempty) {
					Sound sound;
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
								javax.sound.sampled.Clip clip = javax.sound.sampled.AudioSystem.getClip();
								sound.load(clip);
							}
							catch (javax.sound.sampled.LineUnavailableException e) {
								e.printStackTrace();
							}
						}
						else {
							java.util.Iterator<Sound> it = soundqueue.descendingIterator();
							while (true) {
								Sound last = it.next();
								if (last.isLoaded()) {
									javax.sound.sampled.Clip clip = last.unloadit();
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
		
		public synchronized int addSound(Sound sound) {
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
	
	private static SoundThread thread;
	private javax.sound.sampled.Clip clip;
	
	public javax.sound.sampled.Clip unloadit() {
		javax.sound.sampled.Clip clip = this.clip;
		this.clip = null;
		return clip;
	}
	
	public void load(javax.sound.sampled.Clip clip) {
		this.clip = clip;
		javax.sound.sampled.AudioInputStream stream;
		try {
			stream = javax.sound.sampled.AudioSystem.getAudioInputStream(new java.io.File(filename));
			clip.close();
			clip.open(stream);
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
')
class Sound extends kha.Sound {
	var index: Int;
	var filename: String;
	
	public function new(filename: String) {
		super();
		init(filename);
	}
	
	@:functionCode('
		this.filename = filename;
		if (thread == null) {
			thread = new SoundThread();
			Thread realthread = new Thread(thread);
			realthread.start();
		}
		index = thread.addSound(this);
	')
	function init(filename : String) {
		
	}
	
	@:functionCode('
		thread.play(index);
		return null;
	')
	public function play(): AudioChannel {
		return null;
	}
	
	@:functionCode('
		if (clip.isRunning()) {
			clip.stop();
		}
		thread.stop(index);
	')
	public function stop() : Void {
		
	}
	
	@:functionCode('
		return clip != null;
	')
	public function isLoaded() : Bool {
		return true;
	}
	
	@:functionCode('
		if (!clip.isRunning()) {
			clip.setFramePosition(0);
			clip.loop(0);
		}
		else clip.setFramePosition(0);
	')
	public function realplay() : Void {
		
	}
	
	@:functionCode('
		return clip.isRunning();
	')
	public function isRunning() : Bool {
		return true;
	}
}
