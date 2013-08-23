package kha;

import kha.graphics.Graphics;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/System.h>
')

class Sys {
	public static var needs3d: Bool = false;
	
	public static var graphics(default, null): Graphics;
	
	public static function init(): Void {
		graphics = new kha.cpp.graphics.Graphics();
	}
	
	@:functionCode("return Kore::System::frequency();")
	public static function getFrequency(): Float {
		return 1000;
	}
	
	@:functionCode("
		static Kore::System::ticks start = Kore::System::timestamp();
		return static_cast<double>(Kore::System::timestamp() - start);
	")
	public static function getTimestamp(): Float {
		return 0;
	}
}
