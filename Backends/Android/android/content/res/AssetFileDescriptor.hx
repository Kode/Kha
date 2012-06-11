package android.content.res;

extern class AssetFileDescriptor {
	public function getFileDescriptor() : String;
	public function getStartOffset() : Int;
	public function getLength() : Int;
}