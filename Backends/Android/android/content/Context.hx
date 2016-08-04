package android.content;

import android.content.res.AssetManager;
import java.io.FileInputStream;
import java.io.FileOutputStream;

extern class Context {
	public static var MODE_PRIVATE: Int;
	public static var MODE_APPEND: Int;
	
	public static var INPUT_METHOD_SERVICE: String;
	
	public function getAssets(): AssetManager;
	
	public function openFileOutput (name: String, mode: Int): FileOutputStream;
	public function openFileInput (name: String): FileInputStream;
}
