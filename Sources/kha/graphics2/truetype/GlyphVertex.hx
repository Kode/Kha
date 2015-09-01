package kha.graphics2.truetype;

class GlyphVertex {
	public var X: Int;
	public var Y: Int;
	public var CX: Int;
	public var CY: Int;

	public var Type: GlyphVertexType;
	
	public function new() {
		X = 0;
		Y = 0;
		CX = 0;
		CY = 0;
		GlyphVertexType = null;
	}
}
