package android.content.res;
import haxe.Int64;

extern class AssetFileDescriptor {
	public function getFileDescriptor() : String;
	public function getStartOffset() : Int;
	public function getLength() : Int;
	public function createInputStream(): java.io.FileInputStream;
}