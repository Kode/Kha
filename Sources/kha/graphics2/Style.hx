package kha.graphics2;

import kha.Color;

class Style {
	public var fill: Bool;
	public var fillColor: Color;
	public var stroke: Bool;
	public var strokeColor: Color;
	public var strokeWeight: Float;

	inline public function new() {
		fill = true;
		fillColor = Color.White;
		stroke = true;
		strokeColor = Color.Black;
		strokeWeight = 1.0;
	}
}