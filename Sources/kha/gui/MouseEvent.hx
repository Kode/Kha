package kha.gui;

class MouseEvent {
	public var x: Float;
	public var y: Float;
	public var globalX: Float;
	public var globalY: Float;
	
	public function new(x: Int, y: Int) {
		globalX = this.x = x;
		globalY = this.y = y;
	}
	
	public function translate(tx: Float, ty: Float): Void {
		x += tx;
		y += ty;
	}
}