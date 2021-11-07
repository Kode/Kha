package kha.kore.graphics4;

class Graphics2 extends kha.graphics4.Graphics2 {
	override public function drawVideoInternal(video: kha.Video, x: Float, y: Float, width: Float, height: Float): Void {
		// color = Color.Blue;
		// fillRect(x, y, width, height);

		color = Color.White;
		drawScaledSubImage(Image.fromVideo(video), 0, 0, video.width(), video.height() * 0.66, x, y, width, height);
	}
}
