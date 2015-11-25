package kha;

import haxe.io.Bytes;
import haxe.Json;
import haxe.Serializer;
import haxe.Unserializer;

/**
 * This class handles a file in the storage system.
 * Be aware that in some platforms files may be easily lost, such us Flash or HTML 5.
 */
class StorageFile {
	/**
	 * Read the file.
	 *
	 * @return		The data in blod format.
	 */
	public function read(): Blob { return null; }
	
	/**
	 * Write data to a file.
	 *
	 * @param data		The data to write.
	 */
	public function write(data: Blob): Void { }
	
	/**
	 * Append data to a file.
	 *
	 * @param data		The data to write.
	 */
	public function append(data: Blob): Void { }
	
	/**
	 * Returns true if we can happend data to a file.
	 */
	public function canAppend(): Bool { return false; }
	
	/**
	 * Returns the file max size.
	 */
	public function maxSize(): Int { return -1; }
	
	/**
	 * Write a string into the file.
	 *
	 * @param data		The string.
	 */
	public function writeString(data: String): Void {
		var bytes = Bytes.ofString(data);
		write(Blob.fromBytes(bytes));
	}
	
	/**
	 * Append a string into the file.
	 *
	 * @param data		The string.
	 */
	public function appendString(data: String): Void {
		var bytes = Bytes.ofString(data);
		append(Blob.fromBytes(bytes));
	}
	
	/**
	 * Read the file and return a string.
	 *
	 * @return		The file information as string.
	 */
	public function readString(): String {
		var blob = read();
		if (blob == null) return null;
		else return blob.toString();
	}
	
	/**
	 * Write an object into the file.
	 *
	 * @param data		The object.
	 */
	public function writeObject(object: Dynamic): Void {
		writeString(Serializer.run(object));
	}
	
	/**
	 * Read the file as an object
	 *
	 * @return		The file as an object.
	 */
	public function readObject(): Dynamic {
		var s = readString();
		if (s == null) return null;
		try {
			return Unserializer.run(s);
		}
		catch (e: Dynamic) {
			return null;
		}
	}
}
