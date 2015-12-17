package kha.vr;

import kha.arrays.Float32Array;
import kha.graphics4.FragmentShader;
import kha.graphics4.Graphics;
import kha.Framebuffer;
import kha.graphics4.ConstantLocation;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexData;
import kha.input.Keyboard;
import kha.math.FastMatrix4;
import kha.math.Matrix4;
import kha.math.Quaternion;
import kha.math.Vector4;
import kha.math.Vector3;
import kha.math.Vector2;
import kha.Shaders;
import kha.vr.Pose;
import kha.vr.PoseState;
import kha.vr.SensorState;
import kha.vr.TimeWarpParms;

import kha.input.Gamepad;
import kha.input.Mouse;

class VrInterfaceEmulated extends kha.vr.VrInterface {	
	public var framebuffer: Framebuffer;
	
	private var orientation: Quaternion;
	
	// private var f: Float = 0.0;
	
	private var pitchDegrees: Float = 0.0;
	private var yawDegrees: Float = 0.0;
	
	private var pitchDelta: Float = 0.0;
	private var yawDelta: Float = 0.0;
	
	private static inline var keyboardSpeed: Float = 2.0;
	
	private static inline var mouseSpeed: Float = 0.1;
	
	private static inline var minPitchDegrees: Float = -80;
	private static inline var maxPitchDegrees: Float = 80;
	
	private function degreesToRadians(degrees: Float): Float {
		return degrees * Math.PI / 180.0;
	}
	
	
	private function updateOrientation(): Void {
		// Update from keyboard input
		yawDegrees += yawDelta;
		pitchDegrees += pitchDelta;
		
		if (pitchDegrees < minPitchDegrees)
			pitchDegrees = minPitchDegrees;
		if (pitchDegrees > maxPitchDegrees)
			pitchDegrees = maxPitchDegrees;
		
		
		// Compute from pitch and yaw
		
		var pitchQuat = Quaternion.fromAxisAngle(new Vector3(1, 0, 0), degreesToRadians(pitchDegrees));
		
		var yawQuat = Quaternion.fromAxisAngle(new Vector3(0, 1, 0), degreesToRadians(yawDegrees));
		orientation = yawQuat.mult(pitchQuat);
		
	}
	
	private function buttonEvent(button: Int, value: Float): Void {
		
	}
	
	private function axisEvent(axis: Int, value: Float): Void {
		
	}
	
	private function keyDownEvent(key: Key, char: String): Void {
		switch(key) {
			case Key.LEFT:
				yawDelta = keyboardSpeed;
				
			case Key.RIGHT:
				yawDelta = -keyboardSpeed;
				
			case Key.UP:
				pitchDelta = keyboardSpeed;
				
			case Key.DOWN:
				pitchDelta = -keyboardSpeed;
				
			default:
				
				
		}
		
	}
	
	private function keyUpEvent(key: Key, char: String): Void {
		switch(key) {
			case Key.LEFT:
				yawDelta = 0.0;
				
			case Key.RIGHT:
				yawDelta = 0.0;
				
			case Key.UP:
				pitchDelta = 0.0;
				
			case Key.DOWN:
				pitchDelta = 0.0;
				
			default:
				
				
		}
	}
	
	private var oldMouseX: Int = 0;
	private var oldMouseY: Int = 0;
	
	private function mouseMoveEvent(x: Int, y: Int, movementX : Int, movementY : Int) {
		if (!mouseButtonDown) return;
		
		var mouseDeltaX: Int = x - oldMouseX;
		var mouseDeltaY: Int = y - oldMouseY;
		oldMouseX = x;
		oldMouseY = y;
		
		
		yawDegrees += mouseDeltaX * mouseSpeed;
		pitchDegrees += mouseDeltaY * mouseSpeed;
		
		if (pitchDegrees < minPitchDegrees)
			pitchDegrees = minPitchDegrees;
		if (pitchDegrees > maxPitchDegrees)
			pitchDegrees = maxPitchDegrees;
	}
	
	var mouseButtonDown: Bool = false;
	
	private function mouseButtonDownEvent(button: Int, x: Int, y: Int) {
		if (button == 0) {
			mouseButtonDown = true;
			oldMouseX = x;
			oldMouseY = y;
		}
	}
	
	private function mouseButtonUpEvent(button: Int, x: Int, y: Int) {
		if (button == 0) {
			mouseButtonDown = false;
		}
	}
	
	
	
	// Returns the current sensor state
	// Returns the predicted sensor state at the specified time
	public override function GetSensorState(): SensorState {
		return GetPredictedSensorState(0.0);
	}
	
	
	// Returns the predicted sensor state at the specified time
	public override function GetPredictedSensorState(time: Float): SensorState {
		// TODO: Would be better if the interface was called independently each frame - we don't know how often this function is called.
		updateOrientation();
		
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
		g.setPipeline(pipeline);
		g.setVertexBuffer(vb);
		g.setIndexBuffer(ib);
		var matrixLocation: ConstantLocation = pipeline.getConstantLocation("projectionMatrix");
		var p: FastMatrix4 = FastMatrix4.identity();
		g.setMatrix(matrixLocation, p);
		var texture: TextureUnit = pipeline.getTextureUnit("tex");
		
		g.setTexture(texture, parms.RightImage.Image);
		g.drawIndexedVertices();
		
		// Check for an overlay image
		/* if (parms.LeftImage.Image != null) {
			g.setTexture(texture, parms.RightOverlay.Image);
			g.drawIndexedVertices();
		}
		*/
		g.end();
		
		
		
	}
	
	public override function GetTimeInSeconds(): Float {
		// TODO: Is it in seconds?
		return System.time;
	}
	
	
	var vb: VertexBuffer;
	var ib: IndexBuffer;
	
	var pipeline: PipelineState;
	
	private function setVertex(a: Float32Array, index: Int, pos: Vector3, uv: Vector2, color: Vector4) {
		var base: Int = index * 9;
		a.set(base + 0, pos.x);
		a.set(base + 1, pos.y);
		a.set(base + 2, pos.z);
		base += 3;
		a.set(base + 0, uv.x);
		a.set(base + 1, uv.y);
		base += 2;
		a.set(base + 0, color.x);
		a.set(base + 1, color.y);
		a.set(base + 2, color.z);
		a.set(base + 3, color.w);
	}
	
	public function new() {
		super();
		
		Gamepad.get(0).notify(axisEvent, buttonEvent);
		Keyboard.get(0).notify(keyDownEvent, keyUpEvent);
		Mouse.get(0).notify(mouseButtonDownEvent, mouseButtonUpEvent, mouseMoveEvent, null);
		
		
		var structure: VertexStructure = new VertexStructure();
		
		orientation = new Quaternion();
		updateOrientation();
		
		
		
		structure.add("vertexPosition", VertexData.Float3);
		structure.add("texPosition", VertexData.Float2);
		structure.add("vertexColor", VertexData.Float4);
		
		vb = new VertexBuffer(4, structure, Usage.StaticUsage);
		var verts = vb.lock();
		
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
		
		pipeline = new PipelineState();
		
		pipeline.vertexShader = Shaders.painter_image_vert;
		pipeline.fragmentShader = Shaders.painter_image_frag;
		pipeline.inputLayout = [structure];
		pipeline.compile();
	}
}
