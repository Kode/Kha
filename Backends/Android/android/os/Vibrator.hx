package android.os;

extern class Vibrator {
	@:overload(function(arg0: haxe.Int64): Void {})
	public function vibrate(arg0: java.NativeArray<haxe.Int64>, arg1: Int): Void;
	public function cancel(): Void;
}
