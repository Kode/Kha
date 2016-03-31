package;

using kha.graphics2.GraphicsExtension;

class DigitalPadDisplay {
	var id : Int;
	var x : Float;
	var y : Float;
	var available = false;

	var axis = [for (i in 0...6) 0.0];
	var buttons = [for (i in 0...16) false];

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
		var dz = 0.2;

		// rect
		g.color = lg;
		g.fillRect(x + 64, y + 16, 192, 80);
		g.color = bl;
		g.drawRect(x + 64, y + 16, 192, 80, 4);

		// big left
		g.color = lg;
		g.fillCircle(x + 64, y + 64, 64);
		g.color = bl;
		g.drawCircle(x + 64, y + 64, 64, 4);

			// dpad left
			g.color = axis[0] > -dz ? lg : gr;
			g.fillRect(x + 16, y + 48, 24, 24);
			g.color = bl;
			g.drawRect(x + 16, y + 48, 24, 24, 2);

			// dpad right
			g.color = axis[0] < dz ? lg : gr;
			g.fillRect(x + 88, y + 48, 24, 24);
			g.color = bl;
			g.drawRect(x + 88, y + 48, 24, 24, 2);

			// dpad top
			g.color = axis[1] > -dz ? lg : gr;
			g.fillRect(x + 52, y + 16, 24, 24);
			g.color = bl;
			g.drawRect(x + 52, y + 16, 24, 24, 2);

			// dpad bottom
			g.color = axis[1] < dz ? lg : gr;
			g.fillRect(x + 52, y + 80, 24, 24);
			g.color = bl;
			g.drawRect(x + 52, y + 80, 24, 24, 2);

		// big right
		g.color = lg;
		g.fillCircle(x + 256, y + 64, 64);
		g.color = bl;
		g.drawCircle(x + 256, y + 64, 64, 4);

			// button left
			g.color = !buttons[0] ? lg : gr;
			g.fillCircle(x + 224, y + 64, 16);
			g.color = bl;
			g.drawCircle(x + 224, y + 64, 16, 2);

			// button top
			g.color = !buttons[1] ? lg : gr;
			g.fillCircle(x + 256, y + 32, 16);
			g.color = bl;
			g.drawCircle(x + 256, y + 32, 16, 2);

			// button right
			g.color = !buttons[2] ? lg : gr;
			g.fillCircle(x + 288, y + 64, 16);
			g.color = bl;
			g.drawCircle(x + 288, y + 64, 16, 2);

			// button bottom
			g.color = !buttons[3] ? lg : gr;
			g.fillCircle(x + 256, y + 96, 16);
			g.color = bl;
			g.drawCircle(x + 256, y + 96, 16, 2);
	}
}
