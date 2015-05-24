package kha.audio2;

import haxe.ds.Vector;

class Buffer {
	public var channels: Int;
	public var samplesPerSecond: Int;
	
	public var data: Vector<Float>;
	public var size: Int;
	public var readLocation: Int;
	public var writeLocation: Int;
	
	public function new(size: Int, channels: Int, samplesPerSecond: Int) {
		this.size = size;
		this.data = new Vector<Float>(size);
		this.channels = channels;
		this.samplesPerSecond = samplesPerSecond;
		readLocation = 0;
		writeLocation = 0;
	}
}
