package android.content;

import android.net.Uri;

extern class Intent {
	public static var ACTION_VIEW: String;
	
	@:overload public function new();
	@:overload public function new(action: String);
	@:overload public function new(action: String, uri: Uri);
	
	public function setPackage(packageName: String): Intent;
	public function getIntExtra(name: String, defaultValue: Int): Int;
	public function getStringExtra(name: String): String;
}
