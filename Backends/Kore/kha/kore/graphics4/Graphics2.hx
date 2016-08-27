package kha.kore.graphics4;

import kha.Canvas;
import kha.graphics4.Graphics;
import kha.graphics4.Graphics2;
import kha.graphics4.TextureFormat;
import kha.graphics2.Style;

class Graphics2 extends kha.graphics4.Graphics2 {
	public function new(canvas: Canvas) {
		super(canvas);
	}

	override public function drawVideoInternal(video: kha.Video, x: Float, y: Float, width: Float, height: Float, ?style: Style): Void {
		if (style == null)
			style = this.style;
			
		style.fillColor = Color.Blue;
		rect(x, y, width, height);
		style.fillColor = Color.White;
		scaledSubImage(Image.createFromVideo(video), 0, 0, video.width(), video.height(), x, y, width, height);
	}
}
