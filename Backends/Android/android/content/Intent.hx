package android.content;

extern class Intent {
	@:overload public function new();
	@:overload public function new(action: String);
	
	public function setPackage(packageName: String): Intent;
	public function getIntExtra(name: String, defaultValue: Int): Int;
	public function getStringExtra(name: String): String;
}
