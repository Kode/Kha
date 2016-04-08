package kha;

import haxe.io.Bytes;

using StringTools;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/IO/FileReader.h>
#include <Kore/IO/FileWriter.h>
')

class KoreStorageFile extends StorageFile {
	private var name: String;
	
	public function new(name: String) {
		this.name = name;
	}
	
	@:functionCode('
		Kore::FileReader reader;
		if (!reader.open(name, Kore::FileReader::Save)) return null();
		::kha::Blob blob = createBlob(reader.size());
		for (int i = 0; i < reader.size(); ++i) {
			blob->bytes->b->Pointer()[i] = reader.readU8();
		}
		return blob;
	')
	override public function read(): Blob {
		return null;
	}
	
	@:functionCode('
		Kore::FileWriter writer;
		if (!writer.open(name)) return;
		writer.write(data->bytes->b->Pointer(), data->get_length());
	')
	private function writeInternal(data: Blob): Void {

	}

	override public function write(data: Blob): Void {
		if (data != null) {
			writeInternal(data);
		}
	}
	
	private static function createBlob(size: Int): Blob {
		return Blob.alloc(size);
	}
	
	private static function unused(): Void {
		Bytes.alloc(0);
	}
}

class Storage {	
	public static function namedFile(name: String): StorageFile {
		name = name.replace("\\", ".");
		name = name.replace("/", ".");
		return new KoreStorageFile(name);
	}

	public static function defaultFile(): StorageFile {
		return namedFile("default.kha");
	}
}
