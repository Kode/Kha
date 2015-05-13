package kha.kore.vr;

import kha.graphics4.FragmentShader;
import kha.graphics4.Graphics;
import kha.graphics4.ConstantLocation;
import kha.graphics4.TextureUnit;
import kha.Framebuffer;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Program;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;
import kha.graphics4.TextureFormat;
import kha.graphics4.CullMode;
import kha.graphics4.BlendingOperation;
import kha.Image;
import kha.math.Matrix4;
import kha.math.Quaternion;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.vr.Pose;
import kha.vr.PoseState;
import kha.vr.SensorState;
import kha.vr.TimeWarpParms;

import kha.Loader;


#if ANDROID

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Vr/VrInterface.h>
')

#end 

#if VR_CARDBOARD

class CardboardVrInterfaceTest extends kha.vr.VrInterface {
	
	// We draw directly to the screen
	public var framebuffer: Framebuffer;
	
	private var image: Image;
	
	@:functionCode('
		return Kore::VrInterface::getGaze();
	')
	private function GetGaze(): Quaternion {
		return null;		
	}
	
	
	
	public override function GetSensorState(): SensorState {
		// Return from cardboard api
		
		var s: SensorState = new SensorState();
		s.Predicted = s.Recorded = new PoseState();
		s.Predicted.Pose = new Pose();
		s.Predicted.Pose.Orientation = GetGaze();
		
		return s;
	}
	
	
	
	public override function GetPredictedSensorState(time: Float): SensorState {
		// Return using cardboard api
		return GetSensorState();
	}
	
	
	public override function WarpSwapBlack(): Void {
		// Oculus-specific
	}
	
	
	
	public override function WarpSwapLoadingIcon(): Void {
		// Oculus-specific
	}
	
	
	public override function WarpSwap(parms: TimeWarpParms): Void {
		// Draw the two images, side-by-side
		//parms.LeftImage.Image = Loader.the.getImage("use.png");
		
		
		if (image == null) {
			image = Image.createRenderTarget(Sys.pixelWidth, Sys.pixelHeight, TextureFormat.RGBA32);
		}
		
		var g: Graphics = image.g4;
		g.begin();
		
		g.clear(Color.Orange);
		
		g.setCullMode(CullMode.None);
		// g.setBlendingMode(BlendingOperation.BlendOne, BlendingOperation.BlendZero);
		
		
		
		
		g.setProgram(program);
		g.setVertexBuffer(vb);
		g.setIndexBuffer(ib);
		
		
		var texture: TextureUnit = program.getTextureUnit("tex");
		var matrixLocation: ConstantLocation = program.getConstantLocation("projectionMatrix");
		
		
		var t: Matrix4 = Matrix4.translation( -0.5, 0, 0);
		var s: Matrix4 = Matrix4.scale(0.5, 1, 1);
		var m: Matrix4 = s.multmat(t);
		g.setMatrix(matrixLocation, m);
		
		
		g.setTexture(texture, parms.LeftImage.Image);
		g.drawIndexedVertices();
		
		t = Matrix4.translation(0.5, 0, 0);
		m = s.multmat(t);
		
		g.setMatrix(matrixLocation, m);
		
		
		g.setTexture(texture, parms.RightImage.Image);
		g.drawIndexedVertices();
		
		
		
		
		g.end();
		
		framebuffer.g4.begin();
		SendTextureToDistortion(image);
		
		framebuffer.g4.end();
	}
	
	@:functionCode('
	Kore::VrInterface::DistortTexture(image.mPtr);
	')
	private function SendTextureToDistortion(image: Image) {
		// TODO: Add a function to CPP VrInterface
		// TODO: Check how large the texture should be
		
	}
	
	
	public override function GetTimeInSeconds(): Float {
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

#end
