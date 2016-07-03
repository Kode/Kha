package kha.capture;

import kha.audio2.Buffer;

class Audio {
	public static var audioCallback: Int->Buffer->Void;
	
	public static function init(initialized: Void->Void, error: Void->Void): Void {
		error();
	}
}
