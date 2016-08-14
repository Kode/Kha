package kha.js;

import js.Browser;
import kha.Color;
import kha.FontStyle;
import kha.graphics2.Graphics;
import kha.Kravur;
import kha.math.Matrix3;
import kha.Rotation;

class EmptyGraphics2 extends Graphics {
	private var width: Int;
	private var height: Int;
	private var myColor: Color;
	private var myFont: kha.Font;
	private static var instance: EmptyGraphics2;
	
	public function new(width: Int, height: Int) {
		super();
		this.width = width;
		this.height = height;
		instance = this;
		myColor = Color.fromBytes(0, 0, 0);
	}
}
