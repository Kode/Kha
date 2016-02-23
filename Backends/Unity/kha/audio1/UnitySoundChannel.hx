package kha.audio1;

import unityEngine.AudioSource;
import unityEngine.GameObject;

class UnitySoundChannel implements kha.audio1.AudioChannel {
	static private var gameobject: GameObject = new GameObject("Audio Source");
	private var source: AudioSource;
	
	public function new(filename: String, loop: Bool = false) {
		source = untyped __cs__("global::kha.audio1.UnitySoundChannel.gameobject.AddComponent<global::UnityEngine.AudioSource>()");
		source.clip = UnityBackend.loadSound(filename);
		source.loop = loop;
		play();
	}
	
	public function play(): Void {
		source.Play();
	}
	
	public function pause(): Void {
		source.Pause();
	}
	
	public function stop(): Void {
		source.Stop();
	}
	
	public var length(get, null): Float;
	
	public function get_length(): Float {
		return source.clip.length;
	}
	
	public var position(get, null): Float;
	
	public function get_position(): Float {
		return source.time;
	}
	
	public var volume(get, set): Float;
	
	public function get_volume(): Float {
		return source.volume;
	}
	
	public function set_volume(value: Float): Float {
		return source.volume = untyped __cs__("(float)value");
	}
	
	public var finished(get, null): Bool;
	
	public function get_finished(): Bool {
		return !source.isPlaying;
	}
}
