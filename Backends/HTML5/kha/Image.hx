package kha;

import js.html.FileReader;
import haxe.io.Bytes;
import js.html.ImageElement;
import js.html.CanvasElement;
import js.html.webgl.GL;
import kha.graphics4.TextureFormat;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.Usage;

class Image implements Canvas implements Resource {
	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, readable: Bool = false): Image {
		if (format == null)
			format = TextureFormat.RGBA32;
		if (usage == null)
			usage = Usage.StaticUsage;
		if (SystemImpl.gl == null)
			return new CanvasImage(width, height, format, false);
		else
			return new WebGLImage(width, height, format, false, DepthStencilFormat.NoDepthAndStencil, 1, readable);
	}

	public static function create3D(width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null, readable: Bool = false): Image {
		return null;
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null,
			depthStencil: DepthStencilFormat = DepthStencilFormat.NoDepthAndStencil, antiAliasingSamples: Int = 1): Image {
		if (format == null)
			format = TextureFormat.RGBA32;
		if (SystemImpl.gl == null)
			return new CanvasImage(width, height, format, true);
		else
			return new WebGLImage(width, height, format, true, depthStencil, antiAliasingSamples, false);
	}

	public static function fromCanvas(canvas: CanvasElement): Image {
		if (SystemImpl.gl == null) {
			var img = new CanvasImage(canvas.width, canvas.height, TextureFormat.RGBA32, false);
			img.image = canvas;
			img.createTexture();
			return img;
		}
		else {
			var img = new WebGLImage(canvas.width, canvas.height, TextureFormat.RGBA32, false, DepthStencilFormat.NoDepthAndStencil, 1, false);
			img.image = canvas;
			img.createTexture();
			return img;
		}
	}

	public static function fromImage(image: ImageElement, readable: Bool): Image {
		if (SystemImpl.gl == null) {
			var img = new CanvasImage(image.width, image.height, TextureFormat.RGBA32, false);
			img.image = image;
			img.createTexture();
			return img;
		}
		else {
			var img = new WebGLImage(image.width, image.height, TextureFormat.RGBA32, false, DepthStencilFormat.NoDepthAndStencil, 1, readable);
			img.image = image;
			img.createTexture();
			return img;
		}
	}

	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null, readable: Bool = false): Image {
		if (format == null)
			format = TextureFormat.RGBA32;
		if (usage == null)
			usage = Usage.StaticUsage;
		if (SystemImpl.gl != null) {
			var img = new WebGLImage(width, height, format, false, DepthStencilFormat.NoDepthAndStencil, 1, readable);
			img.image = img.bytesToArray(bytes);
			img.createTexture();
			return img;
		}
		var img = new CanvasImage(width, height, format, false);
		var g2: kha.js.CanvasGraphics = cast img.g2;
		@:privateAccess var canvas = g2.canvas;
		var imageData = new js.html.ImageData(new js.lib.Uint8ClampedArray(bytes.getData()), width, height);
		canvas.putImageData(imageData, 0, 0);
		return img;
	}

	public static function fromBytes3D(bytes: Bytes, width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null,
			readable: Bool = false): Image {
		return null;
	}

	public static function fromEncodedBytes(bytes: Bytes, fileExtention: String, doneCallback: Image->Void, errorCallback: String->Void,
			readable: Bool = false): Void {
		bufferToBase64(cast bytes.getData(), dataUrl -> {
			final imageElement = js.Browser.document.createImageElement();
			imageElement.onload = () -> doneCallback(fromImage(imageElement, readable));
			imageElement.onerror = () -> errorCallback("Image was not created");
			imageElement.src = 'data:image;base64,$dataUrl';
		}, () -> {
			errorCallback("Image was not created");
		});
	}

	static function bufferToBase64(buffer:js.lib.Uint8Array, onLoad:(base64:String)->Void, onError:()->Void) {
		final reader = new FileReader();
		reader.onload = () -> {
			final result:String = reader.result;
			// remove the `data:application/octet-stream;base64,` part from the start
			onLoad(result.substr(result.indexOf(',') + 1));
		}
		reader.onerror = () -> onError();
		reader.readAsDataURL(new js.html.Blob([buffer]));
	}

	public static function fromVideo(video: kha.Video): Image {
		final jsvideo: kha.js.Video = cast video;

		if (SystemImpl.gl == null) {
			var img = new CanvasImage(jsvideo.element.videoWidth, jsvideo.element.videoHeight, TextureFormat.RGBA32, false);
			img.video = jsvideo.element;
			img.createTexture();
			return img;
		}
		else {
			var img = new WebGLImage(jsvideo.element.videoWidth, jsvideo.element.videoHeight, TextureFormat.RGBA32, false,
				DepthStencilFormat.NoDepthAndStencil, 1, false);
			img.video = jsvideo.element;
			img.createTexture();
			return img;
		}
	}

	public static var maxSize(get, never): Int;

	static function get_maxSize(): Int {
		return SystemImpl.gl == null ? 1024 * 8 : SystemImpl.gl.getParameter(GL.MAX_TEXTURE_SIZE);
	}

	public static var nonPow2Supported(get, never): Bool;

	static function get_nonPow2Supported(): Bool {
		return SystemImpl.gl != null;
	}

	public static function renderTargetsInvertedY(): Bool {
		return true;
	}

	public function isOpaque(x: Int, y: Int): Bool {
		return false;
	}

	public function at(x: Int, y: Int): Color {
		return Color.Black;
	}

	public function unload(): Void {}

	public function lock(level: Int = 0): Bytes {
		return null;
	}

	public function unlock(): Void {}

	public function getPixels(): Bytes {
		return null;
	}

	public function generateMipmaps(levels: Int): Void {}

	public function setMipmaps(mipmaps: Array<Image>): Void {}

	public function setDepthStencilFrom(image: Image): Void {}

	public function clear(x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Color): Void {}

	public var width(get, never): Int;

	function get_width(): Int {
		return 0;
	}

	public var height(get, never): Int;

	function get_height(): Int {
		return 0;
	}

	public var depth(get, never): Int;

	function get_depth(): Int {
		return 1;
	}

	public var format(get, never): TextureFormat;

	function get_format(): TextureFormat {
		return TextureFormat.RGBA32;
	}

	public var realWidth(get, never): Int;

	function get_realWidth(): Int {
		return 0;
	}

	public var realHeight(get, never): Int;

	function get_realHeight(): Int {
		return 0;
	}

	public var stride(get, never): Int;

	function get_stride(): Int {
		return 0;
	}

	public var g1(get, never): kha.graphics1.Graphics;

	function get_g1(): kha.graphics1.Graphics {
		return null;
	}

	public var g2(get, never): kha.graphics2.Graphics;

	function get_g2(): kha.graphics2.Graphics {
		return null;
	}

	public var g4(get, never): kha.graphics4.Graphics;

	function get_g4(): kha.graphics4.Graphics {
		return null;
	}
}
