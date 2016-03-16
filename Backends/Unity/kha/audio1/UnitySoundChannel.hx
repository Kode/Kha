package kha.audio1;

import unityEngine.AudioClip;
import unityEngine.AudioSource;
import unityEngine.GameObject;
import unityEngine.MonoBehaviour;

private class SourceMonitor extends unityEngine.MonoBehaviour {
	@:functionCode('
		var sources = GetComponents<UnityEngine.AudioSource>();
		foreach (var source in sources) {
			if (!source.isPlaying) {
				Destroy(source);
			}
		}
	')
	public function Update(): Void {
	}
}

class UnitySoundChannel implements kha.audio1.AudioChannel {
	static private var gameObject: GameObject = new GameObject("Audio Source");
	static private var monitor = untyped __cs__("global::kha.audio1.UnitySoundChannel.gameObject.AddComponent<global::kha.audio1._UnitySoundChannel.SourceMonitor>()");
	private var source: AudioSource;
	private var clip: AudioClip;
	private var loop: Bool;
	
	public function new(filename: String, loop: Bool = false) {
		clip = UnityBackend.loadSound(filename);
		this.loop = loop;
		play();
	}
	
	public function play(): Void {
		source = untyped __cs__("global::kha.audio1.UnitySoundChannel.gameObject.AddComponent<global::UnityEngine.AudioSource>()");
		source.clip = clip;
		source.loop = loop;
		source.Play();
	}
	
	public function pause(): Void {
		if (source != null) {
			source.Pause();
		}
	}
	
	public function stop(): Void {
		if (source != null) {
			source.Stop();
			source = null;
		}
	}
	
	public var length(get, null): Float;
	
	public function get_length(): Float {
		return clip.length;
	}
	
	public var position(get, null): Float;
	
	public function get_position(): Float {
		return source != null ? source.time : 0;
	}
	
	public var volume(get, set): Float;
	
	public function get_volume(): Float {
		return source != null ? source.volume : 0;
	}
	
	public function set_volume(value: Float): Float {
		return source != null ? (source.volume = untyped __cs__("(float)value")) : 0;
	}
	
	public var finished(get, null): Bool;
	
	public function get_finished(): Bool {
		return source == null || !source.isPlaying;
	}
}
