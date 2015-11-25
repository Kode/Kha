package kha.audio2;

import flash.events.Event;
import flash.events.SampleDataEvent;

/*class HardwareMusicChannel implements kha.audio1.MusicChannel {
	private var music: flash.media.Sound;
	private var channel: flash.media.SoundChannel;
	private var running: Bool;
	private var loop: Bool;
	private var myVolume: Float;
	
	public function new(music: flash.media.Sound, loop: Bool) {
		this.music = music;
		this.loop = loop;
		running = false;
		myVolume = 1;
	}
	
	public function play(): Void {
		if (channel != null) channel.stop();
		running = true;
		channel = music.play(0, loop ? 2147483647 : 1);
		channel.addEventListener(Event.SOUND_COMPLETE, function(_) { running = false; } );
	}
	
	public function pause(): Void {
		
	}
	
	public function stop(): Void {
		if (channel != null) channel.stop();
	}
	
	public var length(get, null): Int;
	
	private function get_length(): Int {
		return Std.int(music.length * 10) * 10; // FIXME! there seems to be a timing issue.
	}
	
	public var position(get, null): Int;
	
	private function get_position(): Int {
		return Std.int(channel.position * 10) * 10; // FIXME! there seems to be a timing issue.
	}
	
	public var volume(get, set): Float;

	private function get_volume(): Float {
		return myVolume;
	}

	private function set_volume(value: Float): Float {
		return myVolume = value;
	}
	
	public var finished(get, null): Bool;
	
	private function get_finished(): Bool {
		return !running;
	}
}*/

class Audio {
	private static var buffer: Buffer;
	private static inline var bufferSize = 4096;
	
	@:noCompletion
	public static function _init(): Void {
		buffer = new Buffer(bufferSize * 4, 2, 44100);
		
		var sound = new flash.media.Sound();
		sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
		sound.play(0, 1, null);
	}
	
	private static function onSampleData(event: SampleDataEvent): Void {
		if (audioCallback != null) {
			audioCallback(bufferSize * 2, buffer);
			for (i in 0...bufferSize) {
				event.data.writeFloat(buffer.data.get(buffer.readLocation));
				buffer.readLocation += 1;
				event.data.writeFloat(buffer.data.get(buffer.readLocation));
				buffer.readLocation += 1;
				if (buffer.readLocation >= buffer.size) {
					buffer.readLocation = 0;
				}
			}
		}
		else {
			for (i in 0...bufferSize) {
				event.data.writeFloat(0);
				event.data.writeFloat(0);
			}
		}
    }
	
	public static var audioCallback: Int->Buffer->Void;
	
	public static function play(sound: Sound, loop: Bool = false): AudioChannel {
		/*if (music._nativemusic != null) {
			var channel = new HardwareMusicChannel(cast music._nativemusic, loop);
			channel.play();
			return channel;
		}*/
		return null;
	}
}
