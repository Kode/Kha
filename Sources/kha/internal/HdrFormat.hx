package kha.internal;

import haxe.io.UInt8Array;
import haxe.io.Float32Array;
import haxe.io.Bytes;

// Based on https://github.com/vorg/pragmatic-pbr/blob/master/local_modules/parse-hdr/parse-hdr.js
class HdrFormat {
	static var radiancePattern = new EReg("#\\?RADIANCE", "i");
	static var commentPattern = new EReg("#.*", "i");
	static var gammaPattern = new EReg("GAMMA=", "i");
	static var exposurePattern = new EReg("EXPOSURE=\\s*([0-9]*[.][0-9]*)", "i");
	static var formatPattern = new EReg("FORMAT=32-bit_rle_rgbe", "i");
	static var widthHeightPattern = new EReg("-Y ([0-9]+) \\+X ([0-9]+)", "i");
	static var buffer: UInt8Array;
	static var bufferLength: Int;
	static var fileOffset: Int;
	function new() {}

	static function readBuf(buf: UInt8Array): Int {
		var bytesRead = 0;
		do {
			buf[bytesRead++] = buffer[fileOffset];
		} while(++fileOffset < bufferLength && bytesRead < buf.length);
		return bytesRead;
	}

	static function readBufOffset(buf: UInt8Array, offset: Int, length: Int): Int {
		var bytesRead = 0;
		do {
			buf[offset + bytesRead++] = buffer[fileOffset];
		} while(++fileOffset < bufferLength && bytesRead < length);
		return bytesRead;
	}

	static function readPixelsRaw(buffer: UInt8Array, data: UInt8Array, offset: Int, numpixels: Int) {
		var numExpected = 4 * numpixels;
		var numRead = readBufOffset(data, offset, numExpected);
		if (numRead < numExpected) {
			trace("Error reading raw pixels: got " + numRead + " bytes, expected " + numExpected);
			return;
		}
	}

	static function readPixelsRawRLE(buffer: UInt8Array, data: UInt8Array, offset: Int, scanline_width: Int, num_scanlines: Int) {
		var rgbe = new UInt8Array(4);
		var scanline_buffer: UInt8Array = null;
		var ptr: Int;
		var ptr_end: Int;
		var count: Int;
		var buf = new UInt8Array(2);
		var bufferLength = buffer.length;

		while (num_scanlines > 0) {
			if (readBuf(rgbe) < rgbe.length) {
				trace("Error reading bytes: expected " + rgbe.length);
				return;
			}

			if ((rgbe[0] != 2)||(rgbe[1] != 2)||((rgbe[2] & 0x80) != 0)) {
				// This file is not run length encoded
				data[offset++] = rgbe[0];
				data[offset++] = rgbe[1];
				data[offset++] = rgbe[2];
				data[offset++] = rgbe[3];
				readPixelsRaw(buffer, data, offset, scanline_width * num_scanlines - 1);
				return;
			}

			if ((((rgbe[2] & 0xFF)<<8) | (rgbe[3] & 0xFF)) != scanline_width) {
				trace("Wrong scanline width " + (((rgbe[2] & 0xFF)<<8) | (rgbe[3] & 0xFF)) + ", expected " + scanline_width);
				return;
			}

			if (scanline_buffer == null) {
				scanline_buffer = new UInt8Array(4 * scanline_width);
			}

			ptr = 0;
			// Read each of the four channels for the scanline into the buffer
			for (i in 0...4) {
				ptr_end = (i + 1) * scanline_width;
				while (ptr < ptr_end) {
					if (readBuf(buf) < buf.length) {
						trace("Error reading 2-byte buffer");
						return;
					}
					if ((buf[0] & 0xFF) > 128) {
						// A run of the same value
						count = (buf[0] & 0xFF) - 128;
						if ((count == 0) || (count > ptr_end - ptr)) {
							trace("Bad scanline data");
							return;
						}
						while(count-- > 0) {
							scanline_buffer[ptr++] = buf[1];
						}
					}
					else {
						// A non-run
						count = buf[0] & 0xFF;
						if ((count == 0) || (count > ptr_end - ptr)) {
							trace("Bad scanline data");
							return;
						}
						scanline_buffer[ptr++] = buf[1];
						if (--count > 0) {
							if (readBufOffset(scanline_buffer, ptr, count) < count) {
								trace("Error reading non-run data");
								return;
							}
							ptr += count;
						}
					}
				}
			}

			// Copy byte data to output
			for (i in 0...scanline_width) {
				data[offset + 0] = scanline_buffer[i];
				data[offset + 1] = scanline_buffer[i + scanline_width];
				data[offset + 2] = scanline_buffer[i + 2 * scanline_width];
				data[offset + 3] = scanline_buffer[i + 3 * scanline_width];
				offset += 4;
			}

			num_scanlines--;
		}
	}

	static function readLine(): String {
		var buf = "";
		do {
			var b = buffer[fileOffset];
			if (b == 10) { // New line
				++fileOffset;
				break;
			}
			buf += String.fromCharCode(b);
		} while(++fileOffset < bufferLength);
		return buf;
	}

	public static function parse(bytes:Bytes) {
		buffer = UInt8Array.fromBytes(bytes);
		bufferLength = buffer.length;
		fileOffset = 0;
		var width = 0;
		var height = 0;
		var exposure = 1.0;
		var gamma = 1.0;
		var rle = false;

		for (i in 0...20) {
			var line = readLine();
			if (formatPattern.match(line)) {
				rle = true;
			}
			else if (exposurePattern.match(line)) {
				exposure = Std.parseFloat(exposurePattern.matched(1));
			}
			else if (widthHeightPattern.match(line)) {
				height = Std.parseInt(widthHeightPattern.matched(1));
				width = Std.parseInt(widthHeightPattern.matched(2));
				break;
			}
			//else if (radiancePattern.match(line)) {}
			//else if (commentPattern.match(line)) {}
		}

		if (!rle) {
			trace("File is not run length encoded!");
			return null;
		}

		var data = new UInt8Array(width * height * 4);
		var scanline_width = width;
		var num_scanlines = height;

		readPixelsRawRLE(buffer, data, 0, scanline_width, num_scanlines);

		// TODO: should be Float16
		var floatData = new Float32Array(width * height * 4);
		var offset = 0;
		while (offset < data.length) {
			var r = data[offset + 0] / 255;
			var g = data[offset + 1] / 255;
			var b = data[offset + 2] / 255;
			var e = data[offset + 3];
			var f = Math.pow(2.0, e - 128.0);
			r *= f;
			g *= f;
			b *= f;

			floatData[offset + 0] = r;
			floatData[offset + 1] = g;
			floatData[offset + 2] = b;
			floatData[offset + 3] = 1.0;
			offset += 4;
		}

		return {
			width: width,
			height: height,
			// exposure: exposure,
			// gamma: gamma,
			data: floatData
		}
	}
}
