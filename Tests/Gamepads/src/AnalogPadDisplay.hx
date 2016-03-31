package;

using kha.graphics2.GraphicsExtension;

class AnalogPadDisplay {
	var id : Int;
	var x : Float;
	var y : Float;
	var available = false;

	var axis = [for (i in 0...6) 0.0];
	var buttons = [for (i in 0...36) false];

	var dz = 0.2;

	public function new( id : Int, x : Float, y : Float ) {
		this.id = id;
		this.x = x;
		this.y = y;

		if (kha.input.Gamepad.get(id) != null) {
			available = true;
			kha.input.Gamepad.get(id).notify(gamepad_axisHandler, gamepad_buttonHandler);
		}
	}

	function gamepad_axisHandler( axisId : Int, value : Float ) {
		axis[axisId] = value;
		trace('gamepad_axisHandler ${axisId} - ${value}');
	}

	function gamepad_buttonHandler( buttonId : Int, value : Float ) {
		buttons[buttonId] = value > dz || value < -dz;
		trace('gamepad_buttonHandler ${buttonId} - ${value}');
	}

    public function render( g : kha.graphics2.Graphics ) {
		var lg = kha.Color.fromBytes(200, 200, 200);
		var bl = kha.Color.Black;
		var gr = kha.Color.Green;
		var dg = kha.Color.fromBytes(100, 100, 100);
		var dz = 0.2;

		// rect
		g.color = lg;
		g.fillRect(x + 64, y + 16, 288, 256);
		g.color = bl;
		g.drawRect(x + 64, y + 16, 288, 256, 4);

		// big left
		g.color = lg;
		g.fillCircle(x + 64, y + 64, 64);
		g.color = bl;
		g.drawCircle(x + 64, y + 64, 64, 4);
		g.color = dg;
		g.fillRect(x + 32, y + 32, 64, 64);

		// analog left
		g.color = gr;
		g.fillCircle(x + 64 + axis[0] * 32, y + 64 + axis[1] * 32, 8);
		g.color = bl;
		g.fillCircle(x + 64 + axis[0] * 32, y + 64 + axis[1] * 32, 1);

		// buttons
		for (by in 0...6) {
			for (bx in 0...6) {
				var buttonIndex = by * 6 + bx;
				g.color = !buttons[buttonIndex] ? lg : gr;
				g.fillCircle(160 + x + bx * 32, 64 + y + by * 32, 12);
				g.color = bl;
				g.drawCircle(160 + x + bx * 32, 64 + y + by * 32, 12, 2);
			}
		}
	}
}
