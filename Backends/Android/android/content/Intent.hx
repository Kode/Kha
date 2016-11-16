package android.content;

import android.net.Uri;
import java.lang.CharSequence;
import java.NativeArray;

extern class Intent {
	public static var ACTION_VIEW: String;
	public static var ACTION_SEND: String;
	public static var EXTRA_EMAIL: String;
	public static var EXTRA_SUBJECT: String;
	public static var EXTRA_TEXT: String;
	
	public static var FLAG_ACTIVITY_NO_HISTORY: Int;
	public static var FLAG_ACTIVITY_NEW_DOCUMENT: Int;
	public static var FLAG_ACTIVITY_MULTIPLE_TASK: Int;
	
	@:overload public function new();
	@:overload public function new(action: String);
	@:overload public function new(action: String, uri: Uri);
	
	public static function createChooser(target: Intent, title: CharSequence): Intent;
	
	public function setType(type: String): Intent;
	public function setPackage(packageName: String): Intent;
	
	@:overload public function putExtra(name: String, value: String): Intent;
	@:overload public function putExtra(name: String, value: NativeArray<String>): Intent;
	
	public function getIntExtra(name: String, defaultValue: Int): Int;
	public function getStringExtra(name: String): String;
	
	public function addFlags(flags: Int): Intent;
}
