package kha.audio2.hrtf;

class Panner {
	private var audioContext: Dynamic;
	private var hrtfContainer: Dynamic;
	private var currentConvolver: Dynamic;
	private var targetConvolver: Dynamic;
	private var loPass: Dynamic;
	private var hiPass: Dynamic;
	private var source: Dynamic;
	
	public function new(audioContext: Dynamic, sourceNode: Dynamic, hrtfContainer: Dynamic) {
		this.audioContext = audioContext;
		this.hrtfContainer = hrtfContainer;
		
		currentConvolver = new Convolver(audioContext, sourceNode, hrtfContainer);
		targetConvolver = new Convolver(audioContext, sourceNode, hrtfContainer);

		loPass = audioContext.createBiquadFilter();
		hiPass = audioContext.createBiquadFilter();
		loPass.type = "lowpass";
		loPass.frequency.value = 200;
		hiPass.type = "highpass";
		hiPass.frequency.value = 200;

		var source = sourceNode;
		source.channelCount = 1;
		source.connect(loPass);
		source.connect(hiPass);
		hiPass.connect(currentConvolver.convolver);
		hiPass.connect(targetConvolver.convolver);
	}

	public function connect(destination) {
		loPass.connect(destination);
		currentConvolver.gainNode.connect(destination);
		targetConvolver.gainNode.connect(destination);
	}

	public function setSource(newSource) {
		source.disconnect(loPass);
		source.disconnect(hiPass);
		newSource.connect(loPass);
		newSource.connect(hiPass);
		source = newSource;
	}

	public function setCrossoverFrequency(freq) {
		loPass.frequency.value = freq;
		hiPass.frequency.value = freq;
	}

	public function update(azimuth, elevation) {
		targetConvolver.fillBuffer(hrtfContainer.interpolateHRIR(azimuth, elevation));
		// start crossfading
		var crossfadeDuration = 25;
		targetConvolver.gainNode.gain.setValueAtTime(0, audioContext.currentTime);
		targetConvolver.gainNode.gain.linearRampToValueAtTime(1,
			audioContext.currentTime + crossfadeDuration / 1000);
		currentConvolver.gainNode.gain.setValueAtTime(1, audioContext.currentTime);
		currentConvolver.gainNode.gain.linearRampToValueAtTime(0,
			audioContext.currentTime + crossfadeDuration / 1000);
		// swap convolvers
		var t = targetConvolver;
		targetConvolver = currentConvolver;
		currentConvolver = t;
	}
}
