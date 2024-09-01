package kha.audio2;

import kha.internal.IntBox;

extern class Audio {
	/**
	 * The samples per second natively used by the target system.
	 */
	public static var samplesPerSecond: Int;

	/**
	 * Requests additional audio data.
	 * Beware: This is called from a separate audio thread on some targets.
	 * See kha.audio2.Audio1 for sample code.
	 * This api is disabled on mobile for HTML5 target by default
	 * and can be enabled in `System.start` options.
	 */
	public static var audioCallback: (outputBufferLength:IntBox, buffer:Buffer)->Void;

	/**
	 * Similar to kha.audio1.Audio.stream, but only for hardware accelerated audio playback.
	 * Expect this to return null and provide a pure software alternative.
	 * @param music The music we want to play.
	 * @param loop  If we want the music to loop, default = false.
	 * @return On success returns a valid AudioChannel object. Otherwise returns null.
	 */
	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel;

	/**
	 * Used in Kinc based backends to untangle the audio thread from the garbage collector.
	 * Be very careful please.
	 */
	public static var disableGcInteractions: Bool;
}
