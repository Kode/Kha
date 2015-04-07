package kha.js;

import js.Browser;
import kha.Color;
import kha.FontStyle;
import kha.graphics2.Graphics;
import kha.Kravur;
import kha.math.Matrix3;
import kha.Rotation;

class WorkerGraphics extends Graphics {
	var width: Int;
	var height: Int;
	private var myColor: Color;
	private static var instance: WorkerGraphics;
	
	public function new(width: Int, height: Int) {
		super();
		this.width = width;
		this.height = height;
		instance = this;
		myColor = Color.fromBytes(0, 0, 0);
	}
	
	override public function begin(clear: Bool = true, clearColor: Color = null): Void {
		//if (clear) this.clear(clearColor);
	}
	
	override public function clear(color: Color = null): Void {
		
	}
	
	override public function end(): Void {
		Worker.postMessage( { command: 'end' } );
	}
	
	override public function drawImage(img: kha.Image, x: Float, y: Float) {
		Worker.postMessage( { command: 'drawImage', id: img.id, x: x, y: y } );
	}
	
	override public function drawScaledSubImage(image: kha.Image, sx: Float, sy: Float, sw: Float, sh: Float, dx: Float, dy: Float, dw: Float, dh: Float) {
		Worker.postMessage( { command: 'drawScaledSubImage', id: image.id, sx: sx, sy: sy, sw: sw, sh: sh, dx: dx, dy: dy, dw: dw, dh: dh } );
	}
	
	override public function set_color(color: Color): Color {
		myColor = color;
		
		return color;
	}
	
	override public function get_color(): Color {
		return myColor;
	}
	
	override public function drawRect(x: Float, y: Float, width: Float, height: Float, strength: Float = 1.0) {
		
	}
	
	override public function fillRect(x: Float, y: Float, width: Float, height: Float) {
		
	}
	
	override public function drawString(text: String, x: Float, y: Float) {
		
	}

	override public function set_font(font: kha.Font): kha.Font {
		return font;
	}
	
	override public function get_font(): kha.Font {
		return null;
	}

	override public function drawLine(x1: Float, y1: Float, x2: Float, y2: Float, strength: Float = 1.0) {
		
	}

	override public function fillTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float) {
		
	}
	
	override public function drawVideo(video: kha.Video, x: Float, y: Float, width: Float, height: Float): Void {
		
	}
	
	override public function setTransformation(transformation: Matrix3): Void {
		Worker.postMessage( { command: 'setTransformation',
		_0: transformation[0], _1: transformation[1], _2: transformation[2],
		_3: transformation[3], _4: transformation[4], _5: transformation[5],
		_6: transformation[6], _7: transformation[7], _8: transformation[8] } );
	}
}
