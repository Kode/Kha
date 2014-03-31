package kha.scene;

import kha.graphics.IndexBuffer;
import kha.graphics.Texture;
import kha.graphics.Usage;
import kha.graphics.VertexBuffer;
import kha.graphics.VertexData;
import kha.graphics.VertexStructure;
import kha.Loader;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.Sys;

class StaticMesh extends Mesh {
	private var vertices: Array<Float>;
	private var tangents: Array<Vector3>;
	private var normalmap: Texture;
	private var vb: VertexBuffer;
	private var ib: IndexBuffer;
	
	private static function calculateTangents(vertexCount: Int, vertices: Array<Float>, triangleCount: Int, indices: Array<Int>, tangents: Array<Vector3>) {
		var tan1 = new Array<Vector3>();
		tan1[vertexCount - 1] = new Vector3();
		var tan2 = new Array<Vector3>();
		tan2[vertexCount - 1] = new Vector3();
		
		for (a in 0...triangleCount) {
			var i1 = indices[a * 3 + 0];
			var i2 = indices[a * 3 + 1];
			var i3 = indices[a * 3 + 2];
        
			var v1 = new Vector3(vertices[i1 * 8 + 0], vertices[i1 * 8 + 1], vertices[i1 * 8 + 2]);
			var v2 = new Vector3(vertices[i2 * 8 + 0], vertices[i2 * 8 + 1], vertices[i2 * 8 + 2]);
			var v3 = new Vector3(vertices[i3 * 8 + 0], vertices[i3 * 8 + 1], vertices[i3 * 8 + 2]);
        
			var w1 = new Vector2(vertices[i1 * 8 + 6], vertices[i1 * 8 + 7]);
			var w2 = new Vector2(vertices[i2 * 8 + 6], vertices[i2 * 8 + 7]);
			var w3 = new Vector2(vertices[i3 * 8 + 6], vertices[i3 * 8 + 7]);
        
			var x1 = v2.x - v1.x;
			var x2 = v3.x - v1.x;
			var y1 = v2.y - v1.y;
			var y2 = v3.y - v1.y;
			var z1 = v2.z - v1.z;
			var z2 = v3.z - v1.z;
        
			var s1 = w2.x - w1.x;
			var s2 = w3.x - w1.x;
			var t1 = w2.y - w1.y;
			var t2 = w3.y - w1.y;
        
			var r = 1.0 / (s1 * t2 - s2 * t1);
			var sdir = new Vector3((t2 * x1 - t1 * x2) * r, (t2 * y1 - t1 * y2) * r,
					(t2 * z1 - t1 * z2) * r);
			var tdir = new Vector3((s1 * x2 - s2 * x1) * r, (s1 * y2 - s2 * y1) * r,
					(s1 * z2 - s2 * z1) * r);
        
			tan1[i1] = tan1[i1].add(sdir);
			tan1[i2] = tan1[i2].add(sdir);
			tan1[i3] = tan1[i3].add(sdir);
        
			tan2[i1] = tan2[i1].add(tdir);
			tan2[i2] = tan2[i2].add(tdir);
			tan2[i3] = tan2[i3].add(tdir);
		}
    
		tangents[vertexCount] = new Vector3();
		for (a in 0...vertexCount) {
			var n = new Vector3(vertices[a * 8 + 3], vertices[a * 8 + 4], vertices[a * 8 + 5]);
			var t = tan1[a];
        
			// Gram-Schmidt orthogonalize
			var tang = t.sub(n).mult(n.dot(t));
			tang.normalize();

			// Calculate handedness
			var w = n.cross(t).dot(tan2[a]) < 0.0 ? -1.0 : 1.0;
			if (w < 0) tang = tang.mult(-1);
			tangents[a] = tang;
		}
	}

	public function new(filename: String, texFilename: String = null, normalmapFilename: String = null) {
		super();
		
		if (texFilename == null) texFilename = filename;

		zmin = 1000;
		zmax = -1000;
		xmin = 1000;
		xmax = -1000;
		ymin = 1000;
		ymax = -1000;

		var file = Loader.the.getBlob(filename + ".k3d");
		
		var vertexcount = file.readU32LE();
		//vertices.reserve(vertexcount * 8);
		for (i in 0...vertexcount) {
			var fv: {
				x: Float, y: Float, z: Float,
				nx: Float, ny: Float, nz: Float,
				u: Float, v: Float
			} = { x: 0, y: 0, z: 0, nx: 0, ny: 0, nz: 0, u: 0, v: 0 };
			
			fv.x = file.readF32LE();
			fv.y = file.readF32LE();
			fv.z = file.readF32LE();
			fv.nx = file.readF32LE();
			fv.ny = file.readF32LE();
			fv.nz = file.readF32LE();
			fv.u = file.readF32LE();
			fv.v = file.readF32LE();
			
			vertices.push(fv.x);
			vertices.push(fv.y);
			vertices.push(fv.z);
			vertices.push(fv.nx);
			vertices.push(fv.ny);
			vertices.push(fv.nz);
			vertices.push(fv.u);
			vertices.push(fv.v);

			if (fv.x < xmin) xmin = fv.x;
			if (fv.x > xmax) xmax = fv.x;
			if (fv.y < ymin) ymin = fv.y;
			if (fv.y > ymax) ymax = fv.y;
			if (fv.z < zmin) zmin = fv.z;
			if (fv.z > zmax) zmax = fv.z;
		}

		var indexcount = file.readU32LE();
		//indices.reserve(indexcount);
		for (i in 0...indexcount) {
			indices.push(file.readS32LE());
		}

		material.texture = cast Loader.the.getImage(texFilename);
		if (normalmapFilename != null) normalmap = cast Loader.the.getImage(normalmapFilename);

		calculateTangents(vertexcount, vertices, Std.int(indexcount / 3), indices, tangents);

		var structure = new VertexStructure();
		structure.add("vPos", VertexData.Float4);
		structure.add("vCol", VertexData.Float4);
		structure.add("vTex", VertexData.Float2);
		structure.add("vNormal", VertexData.Float4);
		structure.add("vTangent", VertexData.Float3);
		vb = Sys.graphics.createVertexBuffer(vertexcount, structure, Usage.StaticUsage);
		var vbdata = vb.lock();
		for (i in 0...vertexcount) {
			vbdata[i * 12 + 0] = vertices[i * 8 + 0];
			vbdata[i * 12 + 1] = vertices[i * 8 + 1];
			vbdata[i * 12 + 2] = vertices[i * 8 + 2];
			vbdata[i * 12 + 3] = vertices[i * 8 + 3];
			vbdata[i * 12 + 4] = vertices[i * 8 + 4];
			vbdata[i * 12 + 5] = vertices[i * 8 + 5];
			//((unsigned*)vbdata)[i * 12 + 6] = 0xffffffff;
			//vbdata[i * 12 + 7] = material.texture.Tex()->getU(data->vertices[i * 8 + 6]); 
			//vbdata[i * 12 + 8] = material.texture.Tex()->getV(data->vertices[i * 8 + 7]);
			vbdata[i * 12 + 9] = tangents[i].x;
			vbdata[i * 12 + 10] = tangents[i].y;
			vbdata[i * 12 + 11] = tangents[i].z;
		}
		vb.unlock();
		ib = Sys.graphics.createIndexBuffer(indexcount, Usage.StaticUsage);
		var ibdata = ib.lock();
		for (i in 0...indexcount) {
			ibdata[i] = indices[i];
		}
		ib.unlock();
	}
}
