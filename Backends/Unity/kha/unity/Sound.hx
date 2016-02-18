package kha.unity;

class Sound extends kha.Sound {
	public var filename: String;
	
	public function new(filename: String): Void {
		super();
		this.filename = filename;
	}
}
