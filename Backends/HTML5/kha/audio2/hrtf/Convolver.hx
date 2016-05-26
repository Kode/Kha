package kha.audio2.hrtf;

class Convolver {
	public var buffer: Dynamic;
	public var convolver: Dynamic;
	public var gainNode: Dynamic;
	
	public function new(audioContext: Dynamic, sourceNode: Dynamic, hrtfContainer: Dynamic) {
		this.buffer = audioContext.createBuffer(2, 200, audioContext.sampleRate);
		this.convolver = audioContext.createConvolver();
		this.convolver.normalize = false;
		this.convolver.buffer = this.buffer;
		this.gainNode = audioContext.createGain();

		this.convolver.connect(this.gainNode);
	}
	
	public function fillBuffer(hrirLR) {
		var bufferL = buffer.getChannelData(0);
		var bufferR = buffer.getChannelData(1);
		for (i in 0...buffer.length) {
			bufferL[i] = hrirLR[0][i];
			bufferR[i] = hrirLR[1][i];
		}
		convolver.buffer = buffer;
	}
}
