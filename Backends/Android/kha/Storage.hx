package kha;

import android.content.Context;
import com.ktxsoftware.kha.KhaActivity;
import haxe.io.Bytes;
import java.NativeArray;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.types.Int8;

using StringTools;

@:access(haxe.io.Bytes)
class AndroidStorageFile extends StorageFile {
	private var DEFAULT_BUFFER_SIZE = 1024 * 4;
	
	private var name: String;
	
	public function new(name: String) {
		this.name = name;
	}
	
	private inline function writeInMode(data: Blob, mode: Int): Void {
		try {
			var context = KhaActivity.the().getApplicationContext();
			var outputStream = context.openFileOutput(name, mode);
			outputStream.write(data.toBytes().b);
			outputStream.close();
		} catch (e: IOException) {
			e.printStackTrace();
		}
	}
	
	override public function read(): Blob {
		var context = KhaActivity.the().getApplicationContext();
		
		try {
			var inputStream = context.openFileInput(name);
			if (inputStream == null) return null;
			
			var output = new ByteArrayOutputStream();
			var buffer = new NativeArray<Int8>(DEFAULT_BUFFER_SIZE);
			
			var n = 0;
			while (-1 != (n = inputStream.read(buffer))) {
				output.write(buffer, 0, n);
			}
			
			return Blob.fromBytes(Bytes.ofData(output.toByteArray()));
		} catch (e: IOException) {
			e.printStackTrace();
			return null;
		}
	}

	override public function write(data: Blob): Void {
		writeInMode(data, Context.MODE_PRIVATE);
	}
	
	override public function append(data: Blob): Void {
		writeInMode(data, Context.MODE_APPEND);
	}
	
	override public function canAppend(): Bool { return true; }
}

class Storage {
	public static function namedFile(name: String): StorageFile {
		name = name.replace("\\", ".");
		name = name.replace("/", ".");
		
		return new AndroidStorageFile(name);
	}

	public static function defaultFile(): StorageFile {
		return namedFile("default.kha");
	}
}
