package android.content;

import android.content.res.AssetManager;

extern class Context {
	public static var INPUT_METHOD_SERVICE: String;
	public function getAssets(): AssetManager;
}
