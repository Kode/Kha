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
	
	/**
	 * Draws a cubic bezier using 4 pairs of points. If the x and y arrays have a length bigger then 4, the additional
	 * points will be ignored. With a length smaller of 4 a error will occur, there is no check for this.
	 * You can construct the curves visually in Inkscape with a path using default nodes.
	 * Reference: http://devmag.org.za/2011/04/05/bzier-curves-a-tutorial/
	 */
	public static function drawCubicBezier(g2:Graphics, x:Array<Float>, y:Array<Float>, segments:Int = 20, strength:Float = 1.0):Void {
		var t:Float;
		
		var q0 = calculateCubicBezierPoint(0, x, y);
		var q1:Array<Float>;
		
		for (i in 1...(segments + 1)) {
			t = i / segments;
			q1 = calculateCubicBezierPoint(t, x, y);
			g2.drawLine(q0[0], q0[1], q1[0], q1[1], strength);
			q0 = q1;
		}
	}
	
	/**
	 * Draws multiple cubic beziers joined by the end point. The minimum size is 4 pairs of points (a single curve).	 
	 */
	public static function drawCubicBezierPath(g2:Graphics, x:Array<Float>, y:Array<Float>, segments:Int = 20, strength:Float = 1.0):Void {
		var i = 0;
		var t:Float;
		var q0:Array<Float> = null;
		var q1:Array<Float> = null;

		while (i < x.length - 3) {
			if (i == 0)
				q0 = calculateCubicBezierPoint(0, [x[i], x[i + 1], x[i + 2], x[i + 3]], [y[i], y[i + 1], y[i + 2], y[i + 3]]);

			for (j in 1...(segments + 1)) {
				t = j / segments;
				q1 = calculateCubicBezierPoint(t, [x[i], x[i + 1], x[i + 2], x[i + 3]], [y[i], y[i + 1], y[i + 2], y[i + 3]]);
				g2.drawLine(q0[0], q0[1], q1[0], q1[1], strength);
				q0 = q1;
			}
			
			i += 3;
		}
	}
	
	static function calculateCubicBezierPoint(t:Float, x:Array<Float>, y:Array<Float>):Array<Float> {
		var u:Float = 1 - t;
		var tt:Float = t * t;
		var uu:Float = u * u;
		var uuu:Float = uu * u;
		var ttt:Float = tt * t;
	 		
		// first term
		var p:Array<Float> = [uuu * x[0], uuu * y[0]];
			
		// second term				
		p[0] += 3 * uu * t * x[1];
		p[1] += 3 * uu * t * y[1];
			
		// third term				
		p[0] += 3 * u * tt * x[2];
		p[1] += 3 * u * tt * y[2];		
			
		// fourth term				
		p[0] += ttt * x[3];
		p[1] += ttt * y[3];

		return p;
	}
}
