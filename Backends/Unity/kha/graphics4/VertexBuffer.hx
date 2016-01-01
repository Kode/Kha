package kha.graphics4;

import cs.NativeArray;
import kha.arrays.Float32Array;
import unityEngine.Mesh;
import unityEngine.Vector2;
import unityEngine.Vector3;
import unityEngine.Vector4;

class VertexBuffer {
	public var mesh: Mesh;
	private var array: Float32Array;
	private var structure: VertexStructure;
	private var vertexCount: Int;
	private var myStride: Int;
	
	private var vertices: NativeArray<Vector3>;
	private var normals: NativeArray<Vector3>;
	private var tangents: NativeArray<Vector4>;
	private var uv: NativeArray<Vector2>;
	private var uv2: NativeArray<Vector2>;
	private var uv3: NativeArray<Vector2>;
	private var uv4: NativeArray<Vector2>;
	
	public function new(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false) {
		mesh = new Mesh();
		mesh.MarkDynamic();
		this.vertexCount = vertexCount;
		this.structure = structure;
		
		vertices = new NativeArray<Vector3>(vertexCount);
		normals = new NativeArray<Vector3>(vertexCount);
		tangents = new NativeArray<Vector4>(vertexCount);
		uv = new NativeArray<Vector2>(vertexCount);
		uv2 = new NativeArray<Vector2>(vertexCount);
		uv3 = new NativeArray<Vector2>(vertexCount);
		uv4 = new NativeArray<Vector2>(vertexCount);
		
		myStride = 0;
		for (element in structure.elements) {
			switch (element.data) {
			case VertexData.Float1:
				myStride += 1;
			case VertexData.Float2:
				myStride += 2;
			case VertexData.Float3:
				myStride += 3;
			case VertexData.Float4:
				myStride += 4;
			case VertexData.Float4x4:
				myStride += 4 * 4;
			}
		}
		array = new Float32Array(vertexCount * myStride);
	}

	public function lock(?start: Int, ?count: Int): Float32Array {
		return array;
	}

	public function unlock(): Void {
		var array = this.array.data();
		//mesh.Clear(true);
		var offset: Int = 0;
		var uvindex: Int = 0;
		var threeindex: Int = 0;
		for (element in structure.elements) {
			switch (element.data) {
			case Float1:
				switch (uvindex) {
				case 0:
					for (i in 0...vertexCount) {
						uv[i] = new Vector2(array[offset + i * myStride], array[offset + i * myStride]);
					}
					mesh.uv = uv;
				case 1:
					for (i in 0...vertexCount) {
						uv2[i] = new Vector2(array[offset + i * myStride], array[offset + i * myStride]);
					}
					mesh.uv2 = uv2;
				case 2:
					for (i in 0...vertexCount) {
						uv3[i] = new Vector2(array[offset + i * myStride], array[offset + i * myStride]);
					}
					mesh.uv3 = uv3;
				case 3:
					for (i in 0...vertexCount) {
						uv4[i] = new Vector2(array[offset + i * myStride], array[offset + i * myStride]);
					}
					mesh.uv4 = uv4;
				}
				++uvindex;
				offset += 1;
			case Float2:
				switch (uvindex) {
				case 0:
					for (i in 0...vertexCount) {
						uv[i] = new Vector2(array[offset + i * myStride], array[offset + 1 + i * myStride]);
					}
					mesh.uv = uv;
				case 1:
					for (i in 0...vertexCount) {
						uv2[i] = new Vector2(array[offset + i * myStride], array[offset + 1 + i * myStride]);
					}
					mesh.uv2 = uv2;
				case 2:
					for (i in 0...vertexCount) {
						uv3[i] = new Vector2(array[offset + i * myStride], array[offset + 1 + i * myStride]);
					}
					mesh.uv3 = uv3;
				case 3:
					for (i in 0...vertexCount) {
						uv4[i] = new Vector2(array[offset + i * myStride], array[offset + 1 + i * myStride]);
					}
					mesh.uv4 = uv4;
				}
				++uvindex;
				offset += 2;
			case Float3:
				switch (threeindex) {
				case 0:
					for (i in 0...vertexCount) {
						vertices[i] = new Vector3(array[offset + i * myStride], array[offset + 1 + i * myStride], array[offset + 2 + i * myStride]);
					}
					mesh.vertices = vertices;
				case 1:
					for (i in 0...vertexCount) {
						normals[i] = new Vector3(array[offset + i * myStride], array[offset + 1 + i * myStride], array[offset + 2 + i * myStride]);
					}
					mesh.normals = normals;
				}
				++threeindex;
				offset += 3;
			case Float4:
				for (i in 0...vertexCount) {
					tangents[i] = new Vector4(array[offset + i * myStride], array[offset + 1 + i * myStride], array[offset + 2 + i * myStride], array[offset + 3 + i * myStride]);
				}
				mesh.tangents = tangents;
				offset += 4;
			case Float4x4:
				offset += 4 * 4;
			}
		}
		//mesh.UploadMeshData(true);
	}

	public function count(): Int {
		return vertexCount;
	}

	public function stride(): Int {
		return myStride;
	}
}
