package android.os;

extern class VibrationEffect implements Parcelable {
	public static var DEFAULT_AMPLITUDE: Int;
	public function createOneShot(ms: haxe.Int64, amplitude: Int): VibrationEffect;
}
