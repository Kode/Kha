package kha.graphics5;

#if kha_dxr

@:headerCode('
#include <Kore/Graphics5/RayTrace.h>
')

@:headerClassCode("Kore::Graphics5::RayTraceTarget* target;")
class RayTraceTarget {

	public function new(width: Int, height: Int) {
		init(width, height);
	}

	function init(width: Int, height: Int) {
		untyped __cpp__("target = new Kore::Graphics5::RayTraceTarget(width, height);");
	}
}

#end
