package kha.scene;

import kha.graphics.IndexBuffer;
import kha.graphics.VertexBuffer;
import kha.graphics.Usage;
import kha.Loader;
import kha.math.Matrix4;
import kha.math.Vector3;
import kha.Scheduler;
import kha.Sys;

class VertexMesh extends Mesh {
	public function new(model: String, texture: String = null) {
		super();
		
		zmin = 1000;
		zmax = -1000;
		xmin = 1000;
		xmax = -1000;
		ymin = 1000;
		ymax = -1000;

		var data = Loader.the.getBlob(model + ".k3d");

		vertexcount = data.readU32LE();
		
		var vertices = modelvertices;
		//vertices.reserve(vertexcount * 8);
		//posvertices.reserve(vertexcount * 3);
		for (i in 0...vertexcount) {
			var fv: {
				x: Float,
				y: Float,
				z: Float,
				nx: Float,
				ny: Float,
				nz: Float,
				u: Float,
				v: Float
			} = {x: 0, y: 0, z: 0, nx: 0, ny: 0, nz: 0, u: 0, v: 0};

			fv.x = data.readF32LE();
			fv.y = data.readF32LE();
			fv.z = data.readF32LE();
			fv.nx = data.readF32LE();
			fv.ny = data.readF32LE();
			fv.nz = data.readF32LE();
			fv.u = data.readF32LE();
			fv.v = data.readF32LE();
			
			vertices.push(fv.x);
			vertices.push(fv.y);
			vertices.push(fv.z);
			vertices.push(fv.nx);
			vertices.push(fv.ny);
			vertices.push(fv.nz);
			vertices.push(fv.u);
			vertices.push(fv.v);

			posvertices.push(fv.x);
			posvertices.push(fv.y);
			posvertices.push(fv.z);

			if (fv.x < xmin) xmin = fv.x;
			if (fv.x > xmax) xmax = fv.x;
			if (fv.y < ymin) ymin = fv.y;
			if (fv.y > ymax) ymax = fv.y;
			if (fv.z < zmin) zmin = fv.z;
			if (fv.z > zmax) zmax = fv.z;
		}

		var indexcount: Int = data.readU32LE();
		//indices.reserve(indexcount);
		for (i in 0...indexcount) {
			indices.push(data.readS32LE());
		}

		animcount = data.readU32LE();
		this.vertices = new Array<Float>(); //[vertexcount * 6 * animcount];
		for (i in 0...animcount) {
			for (vi in 0...vertexcount) {
				var fv: { x: Float, y: Float, z: Float } = { x: 0, y: 0, z: 0 };

				fv.x = data.readF32LE();
				fv.y = data.readF32LE();
				fv.z = data.readF32LE();
				
				// ignore nx, ny, nz
				data.readF32LE();
				data.readF32LE();
				data.readF32LE();

				this.vertices[i * vertexcount * 6 + vi * 6 + 0] = fv.x;
				this.vertices[i * vertexcount * 6 + vi * 6 + 1] = fv.y;
				this.vertices[i * vertexcount * 6 + vi * 6 + 2] = fv.z;
			}
		}

		material.texture = cast Loader.the.getImage(texture == null ? model : texture);

		vb = Sys.graphics.createVertexBuffer(vertexcount, null, Usage.StaticUsage);
		var vbdata = vb.lock();
		for (i in 0...vertexcount) {
			vbdata[i * 9 + 0] = vertices[i * 8 + 0];
			vbdata[i * 9 + 1] = vertices[i * 8 + 1];
			vbdata[i * 9 + 2] = vertices[i * 8 + 2];
			vbdata[i * 9 + 3] = vertices[i * 8 + 3];
			vbdata[i * 9 + 4] = vertices[i * 8 + 4];
			vbdata[i * 9 + 5] = vertices[i * 8 + 5];
			//((unsigned*)vbdata)[i * 9 + 6] = 0xffffffff;
			//vbdata[i * 9 + 7] = material.texture.Tex()->getU(vertices[i * 8 + 6]); 
			//vbdata[i * 9 + 8] = material.texture.Tex()->getV(vertices[i * 8 + 7]);
		}
		vb.unlock();
		ib = Sys.graphics.createIndexBuffer(indexcount, Usage.StaticUsage);
		var ibdata = ib.lock();
		for (i in 0...indexcount) {
			ibdata[i] = indices[i];
		}
		ib.unlock();

		start = Scheduler.time();
		var animtime: Float = 2.0;
		end = start + animtime;

		animframe = 38;
	}
	
	override public function render(anim: Int = -1) {
		if (animcount > 0 && anim > 0) {
			anim = anim % animcount;
			var animtime: Float = 2.0;
		
			while (Scheduler.time() > end) {
				start = end;
				end = start + animtime;
			}
			var dif = Scheduler.time() - start;
			var frametime = animtime / (animcount - 1);
			var frame = dif / frametime;
			var index1 = Std.int(frame);
			var index2 = Std.int(frame + 1.0);
			
			++animframe;
			if (animframe > 58) animframe = 38;
			var vbdata = vb.lock();
			for (i in 0...vertexcount) {
				index1 = index2 = anim;
				var first = new Vector3(this.vertices[index1 * vertexcount * 6 + i * 6 + 0], this.vertices[index1 * vertexcount * 6 + i * 6 + 1], this.vertices[index1 * vertexcount * 6 + i * 6 + 2]);
				var firstn = new Vector3(this.vertices[index1 * vertexcount * 6 + i * 6 + 3], this.vertices[index1 * vertexcount * 6 + i * 6 + 4], this.vertices[index1 * vertexcount * 6 + i * 6 + 5]);
				
				vbdata[i * 9 + 0] = first.x;
				vbdata[i * 9 + 1] = first.y;
				vbdata[i * 9 + 2] = first.z;
				
				vbdata[i * 9 + 3] = modelvertices[i * 8 + 3];
				vbdata[i * 9 + 4] = modelvertices[i * 8 + 4];
				vbdata[i * 9 + 5] = modelvertices[i * 8 + 5];
				//((unsigned*)vbdata)[i * 9 + 6] = 0xffffffff;
				//vbdata[i * 9 + 7] = material.texture.Tex()->getU(modelvertices[i * 8 + 6]); 
				//vbdata[i * 9 + 8] = material.texture.Tex()->getV(modelvertices[i * 8 + 7]);
			}
			vb.unlock();
		}
		Sys.graphics.setTexture(null, material.texture);
		//Sys.graphics.setMaterial(material);

		Sys.graphics.setVertexBuffer(vb);
		Sys.graphics.setIndexBuffer(ib);
		Sys.graphics.drawIndexedVertices();
	}
	
	override public function get_size(): Vector3 {
		return new Vector3(xmax - xmin, ymax - ymin, zmax - zmin);
	}
	
	public var vb: VertexBuffer;
	public var ib: IndexBuffer;
	private var animframe: Int;
	private var animcount: Int;
	private var vertexcount: Int;
	private var vertices: Array<Float>;
	private var modelvertices: Array<Float>;
	private var start: Float;
	private var end: Float;
	private var trans: Matrix4;
}
