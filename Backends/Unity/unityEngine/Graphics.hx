package unityEngine;

@:native('UnityEngine.Graphics')
extern class Graphics {
	public static function DrawMeshNow(mesh: Mesh, matrix: Matrix4x4): Void;
}
