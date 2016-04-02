package;

class PadExample {
    public function new() {
		kha.System.notifyOnRender(render);
    }

	function render( fb : kha.Framebuffer ) {
		var g = fb.g2;

		g.begin(true, kha.Color.Purple);
			for (pad in pads) {
				pad.render(g);
			}
		g.end();
	}

	var pads = [new AnalogPadDisplay(0, 32, 32), new AnalogPadDisplay(1, 448, 32), new AnalogPadDisplay(2, 32, 352), new AnalogPadDisplay(3, 448, 352)];
}

class Main {
	public static function main() {
		kha.System.init({ title : 'PadExample', width : 1024, height : 704 }, kha.Assets.loadEverything.bind(assets_loadedHandler));
	}

	static function assets_loadedHandler() {
        new PadExample();
	}
}
