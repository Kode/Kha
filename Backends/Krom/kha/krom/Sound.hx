package kha.krom;

class Sound extends kha.Sound {
	public function new() {
		super();
	}
	
	override public function uncompress(done: Void->Void): Void {
		compressedData = null;
		done();
	}
	
	override public function unload(): Void {
		super.unload();
	}
}
