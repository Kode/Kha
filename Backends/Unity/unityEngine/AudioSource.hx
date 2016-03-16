package unityEngine;

@:native('UnityEngine.AudioSource')
extern class AudioSource {
	public function new() : Void { }
	public function Play() : Void { }
	public function Pause() : Void { }
	public function Stop() : Void { }
	public var clip: AudioClip;
	public var volume: Float;
	public var time: Float;
	public var isPlaying: Bool;
	public var loop: Bool;
}
