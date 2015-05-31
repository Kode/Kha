package unityEngine;

@:native('UnityEngine.Material')
extern class Material {
	public function new(shader: Shader);
	public function SetPass(pass: Int): Bool;
	public var passCount: Int;
	public function SetMatrix(propertyName: String, matrix: Matrix4x4): Void;
	public function GetMatrix(propertyName: String): Matrix4x4;
	public function SetVector(propertyName: String, vector: Vector4): Void;
	public function SetFloat(propertyName: String, value: Single): Void;
	public function SetInt(propertyName: String, value: Int): Void;
	public function SetTexture(propertyName: String, texture: Texture): Void;
}
