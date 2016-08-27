package kha.graphics2;

import kha.Color;
import kha.Font;
import kha.graphics4.PipelineState;

class Style {
	public var fill: Bool;
	public var fillColor: Color;
	public var stroke: Bool;
	public var strokeColor: Color;
	public var strokeWeight: Float;

	public var circleSegments: Int;

	public var font: Font;
	public var fontSize: Int;
	public var fontGlyphs: Array<Int>;

	#if sys_g4
	public var pipeline: PipelineState;
	#end

	inline public function new() {
		fill = true;
		fillColor = Color.White;
		stroke = true;
		strokeColor = Color.Black;
		strokeWeight = 1.0;

		circleSegments = 32;

		font = null;
		fontSize = 12;
		fontGlyphs = [ for (i in 32...256) i ];
		
		#if sys_g4
		pipeline = null;
		#end
	}
}