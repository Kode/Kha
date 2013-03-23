package kha;

import kha.graphics.Graphics;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Scheduler.h>
')

class Sys {
	public static var needs3d: Bool = false;
	
	public static var graphics(default, null): Graphics;
	
	public static function init(): Void {
		graphics = new kha.cpp.graphics.Graphics();
	}
	
	@:functionCode("return Kt::Scheduler::getFrequency();")
	public static function getFrequency(): Float {
		return 1000;
	}
	
	@:functionCode("
		static Kt::Scheduler::ticks start = Kt::Scheduler::getTimestamp();
		return scast<double>(Kt::Scheduler::getTimestamp() - start);
	")
	public static function getTimestamp(): Float {
		return 0;
	}
}