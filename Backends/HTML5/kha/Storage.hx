package kha;

import haxe.io.Bytes;
import haxe.io.BytesData;
import js.html.ArrayBuffer;
import kha.Storage.WebStorage;

typedef WebStorage = 
{
	var length : Int;
    var key : Int -> String;
	var getItem : String -> String;
	var setItem : String -> String -> Void;
	var removeItem : String -> Void;
	var clear : Void -> Void;
}

class LocalStorageFile extends StorageFile {
	private var name: String;
	
	public function new(name: String) {
		this.name = name;
	}
	
	override public function read(): Blob {
		var storage: WebStorage = untyped __js__("window.localStorage");
		var value: String = storage.getItem(name);
		if (value == null) return null;
		else return new Blob(decode(value));
	}
	
	override public function write(data: Blob): Void {
		var storage: WebStorage = untyped __js__("window.localStorage");
		storage.setItem(name, encode(data.bytes.getData()));
	}
	
	private static function indexOf(data: Array<Int>, value: Int): Int {
		for (i in 0...data.length) {
			if (data[i] == value) return i;
		}
		return -1;
	}
	
	/**
	 * Encodes byte array to yEnc string (from SASStore).
	 * @param  {Array}  source Byte array to convert to yEnc.
	 * @return {string}        Resulting yEnc string from byte array.
	 */
	private static function encode(source: BytesData) {
		var reserved = [0, 10, 13, 61];
		var output = '';
		var converted, ele;
		for (i in 0...source.length) {
			ele = source[i];
			converted = (ele + 42) % 256;
			if (indexOf(reserved, converted) < 0) {
				output += String.fromCharCode(converted);
			} else {
				converted = (converted + 64) % 256;
				output += "="+ String.fromCharCode(converted);
			}
		}
		return output;
	}

	/**
	 * Decodes yEnc string to byte array (from SASStore).
	 * @param  {string} source yEnc string to decode to byte array.
	 * @return {Array}         Resulting byte array from yEnc string.
	 */
	private static function decode(source: String): Bytes {
		var output = new js.html.Uint8Array(new ArrayBuffer(), 0, source.length);
		var ck = false;
		var c;
		var index = 0;
		for (i in 0...source.length) {
			c = source.charCodeAt(i);
			// ignore newlines
			if (c == 13 || c == 10) { continue; }
			// if we're an "=" and we haven't been flagged, set flag
			if (c == 61 && !ck) {
				ck = true;
				continue;
			}
			if (ck) {
				ck = false;
				c = c - 64;
			}
			if (c < 42 && c > 0) {
				output[index++] = c + 214;
			}
			else {
				output[index++] = c - 42;
			}
		}
		return Bytes.ofData(output);
	}
}

class Storage {
	public static function namedFile(name: String): StorageFile {
		return new LocalStorageFile(name);
	}

	public static function defaultFile(): StorageFile {
		return namedFile("default.kha");
	}
}
