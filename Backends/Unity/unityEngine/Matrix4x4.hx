package unityEngine;

@:native('UnityEngine.Matrix4x4')
extern class Matrix4x4 {
	public static var identity: Matrix4x4;
	public static var zero: Matrix4x4;
	public function SetColumn(i: Int, v: Vector4): Void;
	public function SetRow(i: Int, v: Vector4): Void;
}
