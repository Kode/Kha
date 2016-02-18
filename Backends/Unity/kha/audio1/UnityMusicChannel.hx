package kha.audio1;

class UnityMusicChannel extends UnitySoundChannel implements kha.audio1.MusicChannel {
	public function new(filename: String, looping: Bool) {
		super(filename);
		source.loop = looping;
	}
}
