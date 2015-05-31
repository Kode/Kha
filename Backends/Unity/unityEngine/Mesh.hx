package unityEngine;

import cs.NativeArray;

@:native('UnityEngine.Mesh')
extern class Mesh {
	public function new();
	public var triangles: NativeArray<Int>;
	public var vertices: NativeArray<Vector3>;
	public var normals: NativeArray<Vector3>;
	public var tangents: NativeArray<Vector4>;
	public var uv: NativeArray<Vector2>;
	public var uv2: NativeArray<Vector2>;
	public var uv3: NativeArray<Vector2>;
	public var uv4: NativeArray<Vector2>;
	public function MarkDynamic(): Void;
	public function UploadMeshData(markNoLogerReadable: Bool): Void;
	public function Clear(keepVertexLayout: Bool): Void;
}
