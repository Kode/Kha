package android.content.res;

import java.io.InputStream;

extern class AssetManager {
	public function openFd(filename : String) : AssetFileDescriptor;
	public function open(filename : String) : InputStream;
}