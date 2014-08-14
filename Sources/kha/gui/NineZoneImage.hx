package kha.gui;

import kha.graphics2.Graphics;
import kha.Image;

/**
	NineZoneImage like androids NinePatchDrawable (http://developer.android.com/guide/topics/graphics/2d-graphics.html#nine-patch)
**/
class NineZoneImage
{
	public var image(default, null): Image;
	
	var x_sections: Array<Int> = new Array();
	var x_scalings: Array<Float> = new Array();
	var y_sections: Array<Int> = new Array();
	var y_scalings: Array<Float> = new Array();
	
	public var min_width(default, null) : Int;
	public var min_height(default, null) : Int;
	
	public var padding_left: Int = 0;
	public var padding_top: Int = 0;
	public var padding_right: Int = 0;
	public var padding_bottom: Int = 0;
	
	/**
		NineZoneImages can be constructed in 3 different modes:
		1. Only specify image:
			Image must be a nine-patch image (http://developer.android.com/guide/topics/graphics/2d-graphics.html#nine-patch)
			Non streching
		2. left != null:
			Image is just boxed. The whole image will be streched.
		3. specify an inner rect (left,top,right,bottom):
			Only the specified rect will be scaled.
	**/
	public function new(image: Image, ?left: Int, ?top: Int, ?right: Int, ?bottom: Int) {
		this.image = image;
		if (left == null) {
			// Find the stretchable areas
			detectParts();
		} else if (bottom == null) {
			// just the image
			x_sections.push(0);
			x_scalings.push(1);
			x_sections.push(image.width);
			y_sections.push(0);
			y_scalings.push(1);
			y_sections.push(image.height);
			padding_left = padding_top = padding_right = padding_bottom = 0;
		} else {
			// image with scalable rect
			x_sections.push(0);
			x_scalings.push(0);
			x_sections.push(left);
			x_sections.push(right);
			x_scalings.push(1);
			x_sections.push(image.width);
			y_sections.push(0);
			y_sections.push(top);
			y_sections.push(bottom);
			y_scalings.push(1);
			y_sections.push(image.height);
			y_scalings.push(0);
			padding_left = left;
			padding_top = top;
			padding_right = right;
			padding_bottom = bottom;
		}
	}
	
	private function detectParts() {
		{
			// x - Axis
			min_width = 0;
			var x_streched : Int = 0;
			var firstXIsScaled = image.isOpaque(1, 0);
			x_sections.push(1);
			var currentIsScaled = firstXIsScaled;
			for (x in 2...(image.width-1)) {
				if (image.isOpaque(x, 0) != currentIsScaled) {
					if (currentIsScaled) {
						x_streched += x - x_sections[x_sections.length - 1];
					} else {
						min_width += x - x_sections[x_sections.length - 1];
					}
					currentIsScaled = !currentIsScaled;
					x_sections.push(x);
				}
			}
			if (currentIsScaled) {
				x_streched += (image.width - 1) - x_sections[x_sections.length - 1];
				if (x_streched == 0) {
					throw "ERROR: No parts allow scaling!";
				}
			} else {
				min_width += (image.width-1) - x_sections[x_sections.length - 1];
			}
			x_sections.push(image.width-1);
			
			if (min_width + x_streched != (image.width-2)) {
				throw 'Something went wrong:\nmin_width = $min_width\nx_streched = $x_streched\nimage.width = ${image.width}';
			}
			currentIsScaled = firstXIsScaled;
			for (i in 0...(x_sections.length - 1)) {
				if (currentIsScaled) {
					x_scalings[i] = (x_sections[i + 1] - x_sections[i]) / x_streched;
				} else {
					x_scalings[i] = 0;
				}
				currentIsScaled = !currentIsScaled;
			}
			x_sections[0] = 2;
		}
		{ 
			// y - Axis
			min_height = 0;
			var y_streched : Int = 0;
			var firstYIsScaled = image.isOpaque(0, 1);
			y_sections.push(1);
			var currentIsScaled = firstYIsScaled;
			for (y in 2...(image.height-1)) {
				if (image.isOpaque(0, y) != currentIsScaled) {
					if (currentIsScaled) {
						y_streched += y - y_sections[y_sections.length - 1];
					} else {
						min_height += y - y_sections[y_sections.length - 1];
					}
					currentIsScaled = !currentIsScaled;
					y_sections.push(y);
				}
			}
			if (currentIsScaled) {
				y_streched += (image.height-1) - y_sections[y_sections.length - 1];
				if (y_streched == 0) {
					throw "ERROR: No parts allow scaling!";
				}
			} else {
				min_height += (image.height-1) - y_sections[y_sections.length - 1];
			}
			y_sections.push(image.height-1);
			
			if (min_height + y_streched != (image.height-2)) {
				throw 'Something went wrong:\nmin_height = $min_height\ny_streched = $y_streched\nimage.height = ${image.height}';
			}
			currentIsScaled = firstYIsScaled;
			for (i in 0...(y_sections.length - 1)) {
				if (currentIsScaled) {
					y_scalings[i] = (y_sections[i + 1] - y_sections[i]) / y_streched;
				} else {
					y_scalings[i] = 0;
				}
				currentIsScaled = !currentIsScaled;
			}
			y_sections[0] = 2;
		}
		{
			{
				// x - axis padding:
				var foundPadding = false;
				var y = image.height - 1;
				for (x in 1...(image.width-1)) {
					if (image.isOpaque(x, y)) {
						padding_left = x - 1;
						for (x in 2...image.width) {
							if (image.isOpaque(image.width - x, y)) {
								padding_right = x-2;
								foundPadding = image.width - x - 1 > padding_left;
								break;
							}
						}
						break;
					}
				}
				if (!foundPadding) {
					if (x_sections.length == 2) {
						padding_left = 0;
						padding_right = 0;
					} else {
						if (x_scalings[0] > 0) {
							padding_left = 0;
							if ((x_sections.length % 2) == 0) {
								padding_right = image.width - x_sections[x_sections.length - 2] - 1;
							} else {
								padding_right = 0;
							}
						} else {
							padding_left = x_sections[1] - 1;
							if ((x_sections.length % 2) == 0) {
								padding_right = 0;
							} else {
								padding_right = image.width - x_sections[x_sections.length - 2] - 1;
							}
						}
					}
				}
			}
			{
				// y - axis padding:
				var foundPadding = false;
				var x = image.width - 1;
				for (y in 1...(image.height-1)) {
					if (image.isOpaque(x, y)) {
						padding_top = y - 1;
						for (y in 2...image.height) {
							if (image.isOpaque(x, image.height-y)) {
								padding_bottom = y-2;
								foundPadding = image.height - y - 1 > padding_top;
								break;
							}
						}
						break;
					}
				}
				if (!foundPadding) {
					if (y_sections.length == 2) {
						padding_top = 0;
						padding_bottom = 0;
					} else {
						if (y_scalings[0] > 0) {
							padding_top = 0;
							if ((y_sections.length % 2) == 0) {
								padding_bottom = image.width - y_sections[y_sections.length - 2] - 1;
							} else {
								padding_bottom = 0;
							}
						} else {
							padding_left = y_sections[1] - 1;
							if ((y_sections.length % 2) == 0) {
								padding_bottom = 0;
							} else {
								padding_bottom = image.width - y_sections[y_sections.length - 2] - 1;
							}
						}
					}
				}
			}
		}
	}
	
	public function render(g : Graphics, x : Float, y : Float, width : Float, height : Float) : Void {
		var x_stretch = width - (image.width - 2 * y_sections[0]);
		var y_stretch = height - (image.height - 2 * y_sections[0]);
		
		var sx = x_sections[0];
		var sx_off = sx;
		var dx = x;
		var dw = x_scalings[0] * x_stretch;
		for (xi in 1...x_sections.length) {
			var next_sx = x_sections[xi];
			var sw = next_sx - sx;
			dw += sw;
			
			var sy = y_sections[0];
			var dh = y_scalings[0] * y_stretch;
			var sy_off = sy;
			var dy = y;
			for (yi in 1...y_sections.length) {
				var next_sy = y_sections[yi];
				var sh = next_sy - sy;
				dh += sh;
				g.drawScaledSubImage(image, sx, sy, sw, sh, dx, dy, dw, dh);
				
				sy = next_sy;
				dy += dh;
				dh = y_scalings[yi] * y_stretch;
			}
			
			sx = next_sx;
			dx += dw;
			dw = x_scalings[xi] * x_stretch;
		}
	}
}