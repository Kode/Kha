package kha.graphics2;

import kha.graphics2.Graphics;

/**
 * Static extension functions for Graphics2.
 * Usage: "using kha.graphics2.GraphicsExtension;"
 */
class GraphicsExtension {
	/**
	 * Draws a cubic bezier using 4 pairs of points. If the x and y arrays have a length bigger then 4, the additional
	 * points will be ignored. With a length smaller of 4 a error will occur, there is no check for this.
	 * You can construct the curves visually in Inkscape with a path using default nodes.
	 * Reference: http://devmag.org.za/2011/04/05/bzier-curves-a-tutorial/
	 */
	public static function drawCubicBezier(g2:Graphics, x:Array<Float>, y:Array<Float>, segments:Int = 20, style:Style):Void {
		var t:Float;
		
		var q0 = calculateCubicBezierPoint(0, x, y);
		var q1:Array<Float>;
		
		for (i in 1...(segments + 1)) {
			t = i / segments;
			q1 = calculateCubicBezierPoint(t, x, y);
			g2.line(q0[0], q0[1], q1[0], q1[1], style);
			q0 = q1;
		}
	}
	
	/**
	 * Draws multiple cubic beziers joined by the end point. The minimum size is 4 pairs of points (a single curve).	 
	 */
	public static function drawCubicBezierPath(g2:Graphics, x:Array<Float>, y:Array<Float>, segments:Int = 20, style:Style):Void {
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
				g2.line(q0[0], q0[1], q1[0], q1[1], style);
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
