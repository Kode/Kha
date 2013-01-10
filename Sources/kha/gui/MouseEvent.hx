package kha.gui;

class MouseEvent {
	public var x: Int;
	public var y: Int;
	public var globalX: Int;
	public var globalY: Int;
	
	public function new(x: Int, y: Int) {
		globalX = this.x = x;
		globalY = this.y = y;
	}
	
	public function translate(tx: Int, ty: Int): Void {
		x += tx;
		y += ty;
	}
}