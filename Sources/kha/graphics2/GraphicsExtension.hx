package kha.graphics2;

import kha.math.Vector2;
import kha.graphics2.Graphics;

/**
 * Static extension functions for Graphics2.
 * Usage: "using kha.graphics2.GraphicsExtension;"
 */
class GraphicsExtension {
	/**
	 * Draws a circle.
	 * @param	segments (optional) The amount of lines that should be used to draw the circle. 
	 */
	public static function drawCircle(g2: Graphics, cx: Float, cy: Float, radius: Float, strength: Float = 1, segments: Int = 0): Void {
		#if sys_html5
			if (kha.SystemImpl.gl == null) {
				var g: kha.js.CanvasGraphics = cast g2;
				radius -= strength/2; // reduce radius to fit the line thickness within image width/height
				g.drawCircle(cx, cy, radius, strength);
				return;
			}
		#end

		if (segments <= 0)
			segments = Math.floor(10 * Math.sqrt(radius));
			
		var theta = 2 * Math.PI / segments;
		var c = Math.cos(theta);
		var s = Math.sin(theta);
		
		var x = radius;
		var y = 0.0;
		
		for (n in 0...segments) {
			var px = x + cx;
			var py = y + cy;
			
			var t = x;
			x = c * x - s * y;
			y = c * y + s * t;
			
			g2.drawLine(px, py, x + cx, y + cy, strength);
		}
	}
	
	/**
	 * Draws a filled circle.
	 * @param	segments (optional) The amount of lines that should be used to draw the circle. 
	 */
	public static function fillCircle(g2: Graphics, cx: Float, cy: Float, radius: Float, segments: Int = 0): Void {
		#if sys_html5
			if (kha.SystemImpl.gl == null) {
				var g: kha.js.CanvasGraphics = cast g2;
				g.fillCircle(cx, cy, radius);
				return;
			}
		#end

		if (segments <= 0) {
			segments = Math.floor(10 * Math.sqrt(radius));
		}
			
		var theta = 2 * Math.PI / segments;
		var c = Math.cos(theta);
		var s = Math.sin(theta);
		
		var x = radius;
		var y = 0.0;
		
		for (n in 0...segments) {
			var px = x + cx;
			var py = y + cy;
			
			var t = x;
			x = c * x - s * y;
			y = c * y + s * t;
			
			g2.fillTriangle(px, py, x + cx, y + cy, cx, cy);
		}
	}
	
	/**
	 * Draws a convex polygon.
	 */
	public static function drawPolygon(g2: Graphics, x: Float, y: Float, vertices: Array<Vector2>, strength: Float = 1) {
		var iterator = vertices.iterator();
		var v0 = iterator.next();
		var v1 = v0;
		
		while (iterator.hasNext()) {
			var v2 = iterator.next();
			g2.drawLine(v1.x + x, v1.y + y, v2.x + x, v2.y + y, strength);
			v1 = v2;
		}
		g2.drawLine(v1.x + x, v1.y + y, v0.x + x, v0.y + y, strength);
	}
	
	/**
	 * Draws a filled convex polygon.
	 */
	public static function fillPolygon(g2: Graphics, x: Float, y: Float, vertices: Array<Vector2>) {
		var iterator = vertices.iterator();
		var v0 = iterator.next();
		var v1 = v0;
		
		while (iterator.hasNext()) {
			var v2 = iterator.next();
			g2.fillTriangle(v1.x + x, v1.y + y, v2.x + x, v2.y + y, x, y);
			v1 = v2;
		}
		g2.fillTriangle(v1.x + x, v1.y + y, v0.x + x, v0.y + y, x, y);
	}
}
