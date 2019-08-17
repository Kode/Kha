package android.content.res;
import haxe.Int64;
import java.io.FileDescriptor;

extern class AssetFileDescriptor {
	public function getFileDescriptor() : FileDescriptor;
	public function getStartOffset() : Int;
	public function getLength() : Int;
	public function createInputStream(): java.io.FileInputStream;
}