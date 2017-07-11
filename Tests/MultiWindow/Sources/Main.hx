package;

import kha.Display;
import kha.System;
import kha.WindowMode;
import kha.WindowOptions;

class Main {
	public static function main() {
		for (i in 0...kha.Display.count) {
			trace('display${i}: ${kha.Display.x(i)};${kha.Display.y(i)} @ ${kha.Display.width(i)}x${kha.Display.height(i)} isPrimary=${kha.Display.isPrimary(i)}');
		}

		var displayWidth = Display.width(0);

        var pwo : WindowOptions = { title : ' | primary', width : 512, height : 512, x : Fixed(0) };
        var s1wo : WindowOptions = { title : ' | secondary 1', width : 256, height : 256, x : Center };
        var s2wo : WindowOptions = { title : ' | secondary 2', width : 512, height : 256, x : Fixed(displayWidth - 512), mode : WindowMode.BorderlessWindow };

		System.initEx('MultiWindow', [pwo, s1wo, s2wo], window_init, init);
	}

    static function window_init( id : Int ) {
		if (primary == null) {
			primary = new Primary(id);
		} else if (secondary1 == null) {
			secondary1 = new Secondary1(id);
		} else if (secondary2 == null) {
			secondary2 = new Secondary2(id);
		}
    }

	private static function init(): Void {
	}

	static var primary : Primary;
	static var secondary1 : Secondary1;
	static var secondary2 : Secondary2;
}
