package kha;

class DisplayMode {
	public var width: Int;
	public var height: Int;
	public var frequency: Int;
	public var bitsPerPixel: Int;

	public function new(width: Int, height: Int, frequency: Int, bitsPerPixel: Int) {
		this.width = width;
		this.height = height;
		this.frequency = frequency;
		this.bitsPerPixel = bitsPerPixel;
	}
}
