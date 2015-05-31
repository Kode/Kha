package kha;

import haxe.io.Bytes;
import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;

class StorageFile {
	public function read(): Blob { return null; }
	public function write(data: Blob): Void { }
	public function append(data: Blob): Void { }
	public function canAppend(): Bool { return false; }
	public function maxSize(): Int { return -1; }
	
	public function writeString(data: String): Void {
		var bytes = Bytes.ofString(data);
		//write(new Blob(bytes));
	}
	
	public function appendString(data: String): Void {
		var bytes = Bytes.ofString(data);
		//append(new Blob(bytes));
	}
	
	public function readString(): String {
		var blob = read();
		if (blob == null) return null;
		else return blob.toString();
	}
	
	public function writeObject(object: Dynamic): Void {
		writeString(Serializer.run(object));
	}
	
	public function readObject(): Dynamic {
		var s = readString();
		if (s == null) return null;
		else return Unserializer.run(s);
	}
}
