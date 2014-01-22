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
	
	@:functionCode('
		return Kore::System::time();
	')
	public static function getTime(): Float {
		return 0;
	}
}
