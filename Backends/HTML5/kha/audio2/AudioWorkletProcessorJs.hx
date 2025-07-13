package kha.audio2;

@:noDoc
class AudioWorkletProcessorJs {
	public static function getProcessorJs(name: String): String {
		return '
			class KhaAudioProcessor extends AudioWorkletProcessor {
				needMoreData = 0
				constructor() {
					super();
					this.buffer = [];
					this.nextBuffer = [];
					this.port.onmessage = (event) => {
						this.nextBuffer = event.data;
					};
				}
				process(inputs, outputs, parameters) {
					const output = outputs[0];
					if (this.buffer.length < output[0].length * 2) {
						this.buffer = this.nextBuffer;
						this.port.postMessage(this.needMoreData);
					}
					if (this.buffer.length >= output[0].length * 2) {
						for (let i = 0; i < output[0].length; i++) {
							output[0][i] = this.buffer[i * 2];
							output[1][i] = this.buffer[i * 2 + 1];
						}
						this.buffer = this.buffer.slice(output[0].length * 2);
					} else {
						for (let i = 0; i < output[0].length; i++) {
							output[0][i] = 0;
							output[1][i] = 0;
						}
					}
					return true;
				}
			}
			registerProcessor("$name", KhaAudioProcessor);
		';
	}
}
