package kha;

import haxe.io.Bytes;
import js.html.ImageElement;
import js.html.webgl.GL;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.Usage;

class Image implements Canvas implements Resource {
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		if (format == null) format = TextureFormat.RGBA32;
		if (usage == null) usage = Usage.StaticUsage;
		if (SystemImpl.gl == null) return new CanvasImage(width, height, format, false);
		else return new WebGLImage(width, height, format, false, DepthStencilFormat.NoDepthAndStencil);
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: DepthStencilFormat = DepthStencilFormat.NoDepthAndStencil, antiAliasingSamples: Int = 1, contextId: Int = 0): Image {
		if (format == null) format = TextureFormat.RGBA32;
		if (SystemImpl.gl == null) return new CanvasImage(width, height, format, true);
		else return new WebGLImage(width, height, format, true, depthStencil);
	}

	public static function fromImage(image: ImageElement, readable: Bool): Image {
		if (SystemImpl.gl == null) {
			var img = new CanvasImage(image.width, image.height, TextureFormat.RGBA32, false);
			img.image = image;
			img.createTexture();
			return img;
		}
		else {
			var img = new WebGLImage(image.width, image.height, TextureFormat.RGBA32, false, DepthStencilFormat.NoDepthAndStencil);
			img.image = image;
			img.createTexture();
			return img;
		}
	}
	
	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		if (format == null) format = TextureFormat.RGBA32;
		if (usage == null) usage = Usage.StaticUsage;
		if (SystemImpl.gl != null) {
			var img = new WebGLImage(width, height, format, false, DepthStencilFormat.NoDepthAndStencil);
			img.image = img.bytesToArray(bytes);
			img.createTexture();
			return img;
		}
		return null;
	}

	public static function fromVideo(video: kha.js.Video): Image {
		if (SystemImpl.gl == null) {
			var img = new CanvasImage(video.element.videoWidth, video.element.videoHeight, TextureFormat.RGBA32, false);
			img.video = video.element;
			img.createTexture();
			return img;
		}
		else {
			var img = new WebGLImage(video.element.videoWidth, video.element.videoHeight, TextureFormat.RGBA32, false, DepthStencilFormat.NoDepthAndStencil);
			img.video = video.element;
			img.createTexture();
			return img;
		}
	}

	public static var maxSize(get, null): Int;

	public static function get_maxSize(): Int {
		return SystemImpl.gl == null ? 1024 * 8 : SystemImpl.gl.getParameter(GL.MAX_TEXTURE_SIZE);
	}

	public static var nonPow2Supported(get, null): Bool;

	public static function get_nonPow2Supported(): Bool {
		return SystemImpl.gl != null;
	}

	public function isOpaque(x: Int, y: Int): Bool { return false; }
	public function at(x: Int, y: Int): Color { return Color.Black; }
	public function unload(): Void { }
	public function lock(level: Int = 0): Bytes { return null; }
	public function unlock(): Void { }
	public function generateMipmaps(levels: Int): Void { }
	public function setMipmaps(mipmaps: Array<Image>): Void { }
	public function setDepthStencilFrom(image: Image): Void { }
	public var width(get, null): Int;
	private function get_width(): Int { return 0; }
	public var height(get, null): Int;
	private function get_height(): Int { return 0; }
	public var realWidth(get, null): Int;
	private function get_realWidth(): Int { return 0; }
	public var realHeight(get, null): Int;
	private function get_realHeight(): Int { return 0; }
	public var g1(get, null): kha.graphics1.Graphics;
	private function get_g1(): kha.graphics1.Graphics { return null; }
	public var g2(get, null): kha.graphics2.Graphics;
	private function get_g2(): kha.graphics2.Graphics { return null; }
	public var g4(get, null): kha.graphics4.Graphics;
	private function get_g4(): kha.graphics4.Graphics { return null; }
}
