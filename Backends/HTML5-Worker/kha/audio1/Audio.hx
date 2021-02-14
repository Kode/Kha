package kha.audio1;

class Audio {
	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		Worker.postMessage({command: 'playSound', id: cast(sound, kha.html5worker.Sound)._id, loop: loop});
		return null;
	}

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		Worker.postMessage({command: 'streamSound', id: cast(sound, kha.html5worker.Sound)._id, loop: loop});
		return null;
	}
}
