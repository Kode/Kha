package kha;

import haxe.io.Bytes;
import kha.graphics4.Graphics;
import kha.graphics4.DepthStencilFormat;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;

class Image implements Canvas implements Resource {
	public var id: Int;
	public var _rtid: Int;
	public static var _lastId: Int = -1;
	static var lastRtId: Int = -1;
	var w: Int;
	var h: Int;
	var rw: Int;
	var rh: Int;
	var format: TextureFormat;
	var bytes: Bytes = null;

	public function new(id: Int, rtid: Int, width: Int, height: Int, realWidth: Int, realHeight: Int, format: TextureFormat) {
		this.id = id;
		this._rtid = rtid;
		w = width;
		h = height;
		rw = realWidth;
		rh = realHeight;
		this.format = format;
	}

	public static function create(width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		if (format == null) format = TextureFormat.RGBA32;
		if (usage == null) usage = Usage.StaticUsage;
		var id = ++_lastId;
		Worker.postMessage({ command: 'createImage', id: id, width: width, height: height, format: format, usage: usage });
		return new Image(id, -1, width, height, width, height, format);
	}

	public static function create3D(width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function createRenderTarget(width: Int, height: Int, format: TextureFormat = null, depthStencil: DepthStencilFormat = DepthStencilFormat.NoDepthAndStencil, antiAliasingSamples: Int = 1, contextId: Int = 0): Image {
		if (format == null) format = TextureFormat.RGBA32;
		var rtid = ++lastRtId;
		Worker.postMessage({ command: 'createRenderTarget', id: rtid, width: width, height: height });
		return new Image(-1, rtid, width, height, width, height, format);
	}

	public static function fromBytes(bytes: Bytes, width: Int, height: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static function fromBytes3D(bytes: Bytes, width: Int, height: Int, depth: Int, format: TextureFormat = null, usage: Usage = null): Image {
		return null;
	}

	public static var maxSize(get, null): Int;

	public static function get_maxSize(): Int {
		return 1024 * 4;
	}

	public static var nonPow2Supported(get, null): Bool;

	public static function get_nonPow2Supported(): Bool {
		return true;
	}
	
	public static function renderTargetsInvertedY(): Bool {
		return true;
	}

	public function isOpaque(x: Int, y: Int): Bool { return false; }
	public function unload(): Void { }

	public function lock(level: Int = 0): Bytes {
		if (bytes == null) {
			switch (format) {
				case RGBA32:
					bytes = Bytes.alloc(4 * width * height);
				case L8:
					bytes = Bytes.alloc(width * height);
				case RGBA128:
					bytes = Bytes.alloc(16 * width * height);
				case DEPTH16:
					bytes = Bytes.alloc(2 * width * height);
				case RGBA64:
					bytes = Bytes.alloc(8 * width * height);
				case A32:
					bytes = Bytes.alloc(4 * width * height);
				case A16:
					bytes = Bytes.alloc(2 * width * height);
			}
		}
		return bytes;
	}

	public function unlock(): Void {
		Worker.postMessage({ command: 'unlockImage', id: id, bytes: bytes.getData() });
	}

	public function getPixels(): Bytes { return null; }
	public function generateMipmaps(levels: Int): Void { }
	public function setMipmaps(mipmaps: Array<Image>): Void { }
	public function setDepthStencilFrom(image: Image): Void { }
	public function clear(x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Color): Void { }
	public var width(get, null): Int;
	private function get_width(): Int { return w; }
	public var height(get, null): Int;
	private function get_height(): Int { return h; }
	public var depth(get, null): Int;
	private function get_depth(): Int { return 1; }
	public var realWidth(get, null): Int;
	private function get_realWidth(): Int { return rw; }
	public var realHeight(get, null): Int;
	private function get_realHeight(): Int { return rh; }

	var graphics1: kha.graphics1.Graphics;
	var graphics2: kha.graphics2.Graphics;
	var graphics4: kha.graphics4.Graphics;

	public var g1(get, null): kha.graphics1.Graphics;

	function get_g1(): kha.graphics1.Graphics {
		if (graphics1 == null) {
			graphics1 = new kha.graphics2.Graphics1(this);
		}
		return graphics1;
	}

	public var g2(get, null): kha.graphics2.Graphics;

	function get_g2(): kha.graphics2.Graphics {
		if (graphics2 == null) {
			graphics2 = new kha.graphics4.Graphics2(this);
		}
		return graphics2;
	}

	public var g4(get, null): kha.graphics4.Graphics;

	function get_g4(): kha.graphics4.Graphics {
		if (graphics4 == null) {
			graphics4 = new kha.html5worker.Graphics(this);
		}
		return graphics4;
	}
}
