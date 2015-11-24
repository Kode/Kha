package kha.audio2;

extern class Audio {
	/**
	 * Requests additional audio data.
	 * Beware: This is called from a separate audio thread on some targets.
	 * See kha.audio2.Audio1 for sample code.
	 */
	public static var audioCallback: Int->Buffer->Void;
	
	/**
	 * Similar to kha.audio1.Audio.play, but only for hardware accelerated audio playback.
	 * Expect this to return null and provide a pure software alternative.
	 * @param music The music we want to play.
	 * @param loop  If we want the music to loop, default = false.
	 * @return On success returns a valid MusicChannel object. Otherwise returns null.
	 */
	public static function play(sound: Sound, loop: Bool = false): AudioChannel;
}
