package kha.vr;

import kha.graphics4.FragmentShader;
import kha.graphics4.Graphics;
import kha.Framebuffer;
import kha.graphics4.ConstantLocation;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Program;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.math.Matrix4;
import kha.math.Quaternion;
import kha.math.Vector4;
import kha.math.Vector3;
import kha.math.Vector2;
import kha.vr.Pose;
import kha.vr.PoseState;
import kha.vr.SensorState;
import kha.vr.TimeWarpParms;


class VrInterfaceEmulated extends kha.vr.VrInterface {
	
	public var framebuffer: Framebuffer;
	
	private var orientation: Quaternion;
	
	private var f: Float = 0.0;
	
	
	// Returns the current sensor state
	// Returns the predicted sensor state at the specified time
	public override function GetSensorState(): SensorState {
		return GetPredictedSensorState(0.0);
	}
	
	
	// Returns the predicted sensor state at the specified time
	public override function GetPredictedSensorState(time: Float): SensorState {
		orientation = Quaternion.fromAxisAngle(new Vector3(0, 0, 1), f);
		
		f += 0.1;
		
		var result: SensorState = new SensorState();
		// TODO: Check values
		result.Status = 0;
		result.Temperature = 75;
		result.Predicted = new PoseState();
		result.Recorded = result.Predicted;
		
		result.Predicted.AngularAcceleration = new Vector3();
		result.Predicted.AngularVelocity = new Vector3();
		result.Predicted.LinearAcceleration = new Vector3();
		result.Predicted.LinearVelocity = new Vector3();
		result.Predicted.TimeInSeconds = time;
		result.Predicted.Pose = new Pose();
		result.Predicted.Pose.Orientation = orientation;
		result.Predicted.Pose.Position = new Vector3();
		
		// TODO: Simulate the head movement using the mouse
		
		return result;

	}
	
	// Sends a black image to the warp swap thread
	public override function WarpSwapBlack(): Void {
		// TODO: Implement
	}
	
	
	// Sends the Oculus loading symbol to the warp swap thread
	public override function WarpSwapLoadingIcon(): Void {
		// TODO: Implement
	}
	
	// Sends the set of images to the warp swap thread
	public override function WarpSwap(parms: TimeWarpParms): Void {
		
		var g: Graphics = framebuffer.g4;
		g.begin();
		g.setProgram(program);
		g.setVertexBuffer(vb);
		g.setIndexBuffer(ib);
		var matrixLocation: ConstantLocation = program.getConstantLocation("projectionMatrix");
		var p: Matrix4 = Matrix4.identity();
		g.setMatrix(matrixLocation, p);
		var texture: TextureUnit = program.getTextureUnit("tex");
		
		g.setTexture(texture, parms.RightImage.Image);
		g.drawIndexedVertices();
		
		g.end();
		
		
		
	}
	
	public override function GetTimeInSeconds(): Float {
		// TODO: Is it in seconds?
		return Sys.getTime();
	}
	
	
	var vb: VertexBuffer;
	var ib: IndexBuffer;
	
	var program: Program;
	
	private function setVertex(a: Array<Float>, index: Int, pos: Vector3, uv: Vector2, color: Vector4) {
		var base: Int = index * 9;
		a[base + 0] = pos.x;
		a[base + 1] = pos.y;
		a[base + 2] = pos.z;
		base += 3;
		a[base + 0] = uv.x;
		a[base + 1] = uv.y;
		base += 2;
		for (i in 0...4) {
			a[base + i] = color.get(i);
		}
	}
	
	public function new() {
		super();
		
		var structure: VertexStructure = new VertexStructure();
		
		orientation = new Quaternion();
		
		
		
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		
		vb = new VertexBuffer(4, structure, Usage.StaticUsage);
		var verts: Array<Float> = vb.lock();
		
		setVertex(verts, 0, new Vector3(-1, -1, 0), new Vector2(0, 0), new Vector4(1, 1, 1, 1));
		setVertex(verts, 1, new Vector3(-1, 1, 0), new Vector2(0, 1), new Vector4(1, 1, 1, 1));
		setVertex(verts, 2, new Vector3(1, -1, 0), new Vector2(1, 0), new Vector4(1, 1, 1, 1));
		setVertex(verts, 3, new Vector3(1, 1, 0), new Vector2(1, 1), new Vector4(1, 1, 1, 1));
		
		vb.unlock();
		
		ib = new IndexBuffer(6, Usage.StaticUsage);
		var indices: Array<Int> = ib.lock();
		
		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		indices[3] = 1;
		indices[4] = 3;
		indices[5] = 2;
		
		
		ib.unlock(); 
		
		program = new Program();
		
		program.setVertexShader(new VertexShader(Loader.the.getShader("painter-image.vert")));
		program.setFragmentShader(new FragmentShader(Loader.the.getShader("painter-image.frag")));
		program.link(structure);
		
		
	}
	
}

