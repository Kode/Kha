package kha.graphics2;

import kha.Color;

class Style {
	public var fill:Color;
	public var stroke:Color;
	public var strokeWeight:Float;

	inline public function new() {
		fill = Color.White;
		stroke = Color.Black;
		strokeWeight = 1.0;
	}
}