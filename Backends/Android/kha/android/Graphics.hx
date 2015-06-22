package kha.android;

import android.opengl.GLES20;
import haxe.ds.Vector;
import java.NativeArray;
import kha.android.graphics4.ConstantLocation;
import kha.android.graphics4.TextureUnit;
import kha.Blob;
import kha.graphics4.BlendingOperation;
import kha.graphics4.CompareMode;
import kha.graphics4.CubeMap;
import kha.graphics4.CullMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.MipMapFilter;
import kha.graphics4.StencilAction;
import kha.graphics4.TexDir;
import kha.graphics4.TextureAddressing;
import kha.graphics4.TextureFilter;
import kha.graphics4.TextureFormat;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexStructure;
import kha.graphics4.VertexShader;
import kha.Image;
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;
import kha.Rectangle;

class Graphics implements kha.graphics4.Graphics {
	private var framebuffer: Dynamic;
	private var indexBuffer: IndexBuffer;
	private var renderTarget: Image;
	
	public function new(renderTarget: Image = null) {
		this.renderTarget = renderTarget;
		GLES20.glEnable(GLES20.GL_BLEND);
		GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA);
		GLES20.glViewport(0, 0, Sys.pixelWidth, Sys.pixelHeight);
	}

	public function begin(): Void {
		if (renderTarget == null) {
			//Sys.gl.bindFramebuffer(Sys.gl.FRAMEBUFFER, null);
			GLES20.glViewport(0, 0, Sys.pixelWidth, Sys.pixelHeight);
		}
		else {
			//Sys.gl.bindFramebuffer(Sys.gl.FRAMEBUFFER, renderTarget.frameBuffer);
			GLES20.glViewport(0, 0, renderTarget.width, renderTarget.height);
		}
	}
	
	public function end(): Void {
		/*if (GLES20.glGetError() != GLES20.GL_NO_ERROR) {
			trace('GL Error.');
		}*/
	}
	
	public function flush(): Void {
		
	}
	
	public function vsynced(): Bool {
		return true;
	}
	
	public function refreshRate(): Int {
		return 60;
	}
	
	public function clear(?color: Color, ?depth: Float, ?stencil: Int): Void {
		/*var clearMask: Int = 0;
		if (color != null) {
			clearMask |= GLES20.GL_COLOR_BUFFER_BIT;
			GLES20.glClearColor(color.R, color.G, color.B, color.A);
		}
		if (depth != null) {
			//clearMask |= GLES20.DEPTH_BUFFER_BIT;
			GLES20.glClearDepthf(depth);
		}
		if (stencil != null) {
			//clearMask |= GLES20.GL_STENCIL_BUFFER_BIT;
		}
		GLES20.glClear(clearMask);*/
	}
	
	public function setDepthMode(write: Bool, mode: CompareMode): Void {
		/*switch (mode) {
		case Always:
			Sys.gl.disable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.ALWAYS);
		case Never:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.NEVER);
		case Equal:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.EQUAL);
		case NotEqual:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.NOTEQUAL);
		case Less:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.LESS);
		case LessEqual:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.LEQUAL);
		case Greater:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.GREATER);
		case GreaterEqual:
			Sys.gl.enable(Sys.gl.DEPTH_TEST);
			Sys.gl.depthFunc(Sys.gl.GEQUAL);
		}
		Sys.gl.depthMask(write);*/
	}
	
	/*private function getBlendFunc(op: BlendingOperation): Int {
		switch (op) {
		case BlendZero, Undefined:
			return Sys.gl.ZERO;
		case BlendOne:
			return Sys.gl.ONE;
		case SourceAlpha:
			return Sys.gl.SRC_ALPHA;
		case DestinationAlpha:
			return Sys.gl.DST_ALPHA;
		case InverseSourceAlpha:
			return Sys.gl.ONE_MINUS_SRC_ALPHA;
		case InverseDestinationAlpha:
			return Sys.gl.ONE_MINUS_DST_ALPHA;
		}
	}*/
	
	public function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void {
		/*if (source == BlendOne && destination == BlendZero) {
			Sys.gl.disable(Sys.gl.BLEND);
		}
		else {
			Sys.gl.enable(Sys.gl.BLEND);
			Sys.gl.blendFunc(getBlendFunc(source), getBlendFunc(destination));
		}*/
	}
	
	public function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics4.VertexBuffer {
		return new VertexBuffer(vertexCount, structure, usage);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set();
	}
	
	public function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): kha.graphics4.IndexBuffer {
		return new IndexBuffer(indexCount, usage);
	}
	
	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
		//indicesCount = indexBuffer.count();
		//cast(indexBuffer, IndexBuffer).set();
		this.indexBuffer = indexBuffer;
	}
	
	//public function maxTextureSize(): Int {
	//	return Sys.gl == null ? 8192 : Sys.gl.getParameter(Sys.gl.MAX_TEXTURE_SIZE);
	//}
	
	//public function supportsNonPow2Textures(): Bool {
	//	return false;
	//}
	
	public function createCubeMap(size: Int, format: TextureFormat, usage: Usage, canRead: Bool = false): CubeMap {
		return null;
	}
	
	public function setTexture(stage: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) {
			//GLES20.glActiveTexture(GLES20.GL_TEXTURE0 + cast(stage, TextureUnit).value);
			//GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, -1);
		}
		else {
			texture.set(cast(stage, TextureUnit).value);
		}
	}
	
	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		/*Sys.gl.activeTexture(Sys.gl.TEXTURE0 + cast(texunit, TextureUnit).value);
		
		switch (uAddressing) {
		case Clamp:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.CLAMP_TO_EDGE);
		case Repeat:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.REPEAT);
		case Mirror:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_S, Sys.gl.MIRRORED_REPEAT);
		}
		
		switch (vAddressing) {
		case Clamp:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.CLAMP_TO_EDGE);
		case Repeat:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.REPEAT);
		case Mirror:
			Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_WRAP_T, Sys.gl.MIRRORED_REPEAT);
		}
	
		switch (minificationFilter) {
		case PointFilter:
			switch (mipmapFilter) {
			case NoMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.NEAREST);
			case PointMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.NEAREST_MIPMAP_NEAREST);
			case LinearMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.NEAREST_MIPMAP_LINEAR);
			}
		case LinearFilter, AnisotropicFilter:
			switch (mipmapFilter) {
			case NoMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR);
			case PointMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR_MIPMAP_NEAREST);
			case LinearMipFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MIN_FILTER, Sys.gl.LINEAR_MIPMAP_LINEAR);
			}
		}
		
		switch (magnificationFilter) {
			case PointFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MAG_FILTER, Sys.gl.NEAREST);
			case LinearFilter, AnisotropicFilter:
				Sys.gl.texParameteri(Sys.gl.TEXTURE_2D, Sys.gl.TEXTURE_MAG_FILTER, Sys.gl.LINEAR);
		}*/
	}
	
	public function setCullMode(mode: CullMode): Void {
		/*switch (mode) {
		case None:
			Sys.gl.disable(Sys.gl.CULL_FACE);
		case Clockwise:
			Sys.gl.enable(Sys.gl.CULL_FACE);
			Sys.gl.cullFace(Sys.gl.FRONT);
		case CounterClockwise:
			Sys.gl.enable(Sys.gl.CULL_FACE);
			Sys.gl.cullFace(Sys.gl.BACK);
		}*/
	}

	public function setProgram(program: kha.graphics4.Program): Void {
		program.set();
	}
	
	public function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void {
		GLES20.glUniform1i(cast(location, ConstantLocation).value, value ? 1 : 0);
	}
	
	public function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void {
		GLES20.glUniform1i(cast(location, ConstantLocation).value, value);
	}
	
	public function setFloat(location: kha.graphics4.ConstantLocation, value: Float): Void {
		GLES20.glUniform1f(cast(location, ConstantLocation).value, value);
	}
	
	public function setFloat2(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float): Void {
		GLES20.glUniform2f(cast(location, ConstantLocation).value, value1, value2);
	}
	
	public function setFloat3(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		GLES20.glUniform3f(cast(location, ConstantLocation).value, value1, value2, value3);
	}
	
	public function setFloat4(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float, value4: Float): Void {
		GLES20.glUniform4f(cast(location, ConstantLocation).value, value1, value2, value3, value4);
	}
	
	private var valuesCache = new NativeArray<Single>(128);
	
	public function setFloats(location: kha.graphics4.ConstantLocation, values: Array<Float>): Void {
		for (i in 0...values.length) {
			valuesCache[i] = values[i];
		}
		GLES20.glUniform1fv(cast(location, ConstantLocation).value, values.length, valuesCache, 0);
	}
	
	public function setVector2(location: kha.graphics4.ConstantLocation, value: Vector2): Void {
		GLES20.glUniform2f(cast(location, ConstantLocation).value, value.x, value.y);
	}
	
	public function setVector3(location: kha.graphics4.ConstantLocation, value: Vector3): Void {
		GLES20.glUniform3f(cast(location, ConstantLocation).value, value.x, value.y, value.z);
	}
	
	public function setVector4(location: kha.graphics4.ConstantLocation, value: Vector4): Void {
		GLES20.glUniform4f(cast(location, ConstantLocation).value, value.x, value.y, value.z, value.w);
	}
	
	private var matrixCache = new NativeArray<Single>(16);
	
	public inline function setMatrix(location: kha.graphics4.ConstantLocation, matrix: Matrix4): Void {
		matrixCache[ 0] = matrix._00; matrixCache[ 1] = matrix._01; matrixCache[ 2] = matrix._02; matrixCache[ 3] = matrix._03;
		matrixCache[ 4] = matrix._10; matrixCache[ 5] = matrix._11; matrixCache[ 6] = matrix._12; matrixCache[ 7] = matrix._13;
		matrixCache[ 8] = matrix._20; matrixCache[ 9] = matrix._21; matrixCache[10] = matrix._22; matrixCache[11] = matrix._23;
		matrixCache[12] = matrix._30; matrixCache[13] = matrix._31; matrixCache[14] = matrix._32; matrixCache[15] = matrix._33;
		GLES20.glUniformMatrix4fv(cast(location, ConstantLocation).value, 1, false, matrixCache, 0);
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		GLES20.glDrawElements(GLES20.GL_TRIANGLES, count == -1 ? indexBuffer.count() : count, GLES20.GL_UNSIGNED_SHORT, indexBuffer.data);
	}
	
	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {
		
	}

	public function setScissor(rect: Rectangle): Void {
		
	}
	
	public function renderTargetsInvertedY(): Bool {
		return true;
	}
}
