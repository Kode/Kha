package kha.audio2;

class Buffer {
	public var channels: Int;
	public var samplesPerSecond: Int;

	public var data: kha.arrays.Float32Array;
	public var size: Int;
	public var readLocation: Int;
	public var writeLocation: Int;

	public function new(size: Int, channels: Int, samplesPerSecond: Int) {
		this.size = size;
		this.data = new kha.arrays.Float32Array(size);
		this.channels = channels;
		this.samplesPerSecond = samplesPerSecond;
		readLocation = 0;
		writeLocation = 0;
	}
}
