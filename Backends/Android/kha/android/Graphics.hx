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
import kha.graphics4.PipelineState;
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
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.math.Matrix4;
import kha.math.Vector2;
import kha.math.Vector3;
import kha.math.Vector4;

class Graphics implements kha.graphics4.Graphics {
	private var framebuffer: Dynamic;
	private var indexBuffer: IndexBuffer;
	private var renderTarget: Image;
	
	public function new(renderTarget: Image = null) {
		this.renderTarget = renderTarget;
		GLES20.glEnable(GLES20.GL_BLEND);
		GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA);
		GLES20.glViewport(0, 0, System.pixelWidth, System.pixelHeight);
	}

	public function begin(additionalRenderTargets: Array<Canvas> = null): Void {
		if (renderTarget == null) {
			GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0);
			GLES20.glViewport(0, 0, System.pixelWidth, System.pixelHeight);
		}
		else {
			GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, renderTarget.framebuffer);
			GLES20.glViewport(0, 0, renderTarget.realWidth, renderTarget.realHeight);
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
		var clearMask: Int = 0;
		if (color != null) {
			clearMask |= GLES20.GL_COLOR_BUFFER_BIT;
			GLES20.glClearColor(color.R, color.G, color.B, color.A);
		}
		if (depth != null) {
			clearMask |= GLES20.GL_DEPTH_BUFFER_BIT;
			GLES20.glClearDepthf(depth);
		}
		if (stencil != null) {
			clearMask |= GLES20.GL_STENCIL_BUFFER_BIT;
		}
		GLES20.glClear(clearMask);
	}
	
	public function viewport(x: Int, y: Int, width: Int, height: Int): Void {
		GLES20.glViewport(x, y, width, height);
	}
	
	public function setDepthMode(write: Bool, mode: CompareMode): Void {
		switch (mode) {
		case Always:
			GLES20.glDisable(GLES20.GL_DEPTH_TEST);
			GLES20.glDepthFunc(GLES20.GL_ALWAYS);
		case Never:
			GLES20.glEnable(GLES20.GL_DEPTH_TEST);
			GLES20.glDepthFunc(GLES20.GL_NEVER);
		case Equal:
			GLES20.glEnable(GLES20.GL_DEPTH_TEST);
			GLES20.glDepthFunc(GLES20.GL_EQUAL);
		case NotEqual:
			GLES20.glEnable(GLES20.GL_DEPTH_TEST);
			GLES20.glDepthFunc(GLES20.GL_NOTEQUAL);
		case Less:
			GLES20.glEnable(GLES20.GL_DEPTH_TEST);
			GLES20.glDepthFunc(GLES20.GL_LESS);
		case LessEqual:
			GLES20.glEnable(GLES20.GL_DEPTH_TEST);
			GLES20.glDepthFunc(GLES20.GL_LEQUAL);
		case Greater:
			GLES20.glEnable(GLES20.GL_DEPTH_TEST);
			GLES20.glDepthFunc(GLES20.GL_GREATER);
		case GreaterEqual:
			GLES20.glEnable(GLES20.GL_DEPTH_TEST);
			GLES20.glDepthFunc(GLES20.GL_GEQUAL);
		}
		GLES20.glDepthMask(write);
	}
	
	private static function getBlendFunc(op: BlendingOperation): Int {
		switch (op) {
		case BlendZero, Undefined:
			return GLES20.GL_ZERO;
		case BlendOne:
			return GLES20.GL_ONE;
		case SourceAlpha:
			return GLES20.GL_SRC_ALPHA;
		case DestinationAlpha:
			return GLES20.GL_DST_ALPHA;
		case InverseSourceAlpha:
			return GLES20.GL_ONE_MINUS_SRC_ALPHA;
		case InverseDestinationAlpha:
			return GLES20.GL_ONE_MINUS_DST_ALPHA;
		}
	}
	
	public function setBlendingMode(source: BlendingOperation, destination: BlendingOperation): Void {
		if (source == BlendOne && destination == BlendZero) {
			GLES20.glDisable(GLES20.GL_BLEND);
		}
		else {
			GLES20.glEnable(GLES20.GL_BLEND);
			GLES20.glBlendFunc(getBlendFunc(source), getBlendFunc(destination));
		}
	}
	
	public function createVertexBuffer(vertexCount: Int, structure: VertexStructure, usage: Usage, canRead: Bool = false): kha.graphics4.VertexBuffer {
		return new VertexBuffer(vertexCount, structure, usage);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics4.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set();
	}
	
	public function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void {
		
	}
	
	public function createIndexBuffer(indexCount: Int, usage: Usage, canRead: Bool = false): kha.graphics4.IndexBuffer {
		return new IndexBuffer(indexCount, usage);
	}
	
	public function setIndexBuffer(indexBuffer: kha.graphics4.IndexBuffer): Void {
		//indicesCount = indexBuffer.count();
		//cast(indexBuffer, IndexBuffer).set();
		this.indexBuffer = indexBuffer;
	}
	
	public function createCubeMap(size: Int, format: TextureFormat, usage: Usage, canRead: Bool = false): CubeMap {
		return null;
	}
	
	public function setTexture(stage: kha.graphics4.TextureUnit, texture: kha.Image): Void {
		if (texture == null) {
			GLES20.glActiveTexture(GLES20.GL_TEXTURE0 + cast(stage, TextureUnit).value);
			GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, 0);
		}
		else {
			texture.set(cast(stage, TextureUnit).value);
		}
	}

	public function setVideoTexture(unit: kha.graphics4.TextureUnit, texture: kha.Video): Void {

	}
	
	public function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: TextureAddressing, vAddressing: TextureAddressing, minificationFilter: TextureFilter, magnificationFilter: TextureFilter, mipmapFilter: MipMapFilter): Void {
		GLES20.glActiveTexture(GLES20.GL_TEXTURE0 + cast(texunit, TextureUnit).value);
		
		switch (uAddressing) {
		case Clamp:
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE);
		case Repeat:
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_REPEAT);
		case Mirror:
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_MIRRORED_REPEAT);
		}
		
		switch (vAddressing) {
		case Clamp:
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE);
		case Repeat:
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_REPEAT);
		case Mirror:
			GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_MIRRORED_REPEAT);
		}
	
		switch (minificationFilter) {
		case PointFilter:
			switch (mipmapFilter) {
			case NoMipFilter:
				GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST);
			case PointMipFilter:
				GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST_MIPMAP_NEAREST);
			case LinearMipFilter:
				GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST_MIPMAP_LINEAR);
			}
		case LinearFilter, AnisotropicFilter:
			switch (mipmapFilter) {
			case NoMipFilter:
				GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR);
			case PointMipFilter:
				GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR_MIPMAP_NEAREST);
			case LinearMipFilter:
				GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR_MIPMAP_LINEAR);
			}
		}
		
		switch (magnificationFilter) {
			case PointFilter:
				GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_NEAREST);
			case LinearFilter, AnisotropicFilter:
				GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR);
		}
	}
	
	public function setCullMode(mode: CullMode): Void {
		switch (mode) {
		case None:
			GLES20.glDisable(GLES20.GL_CULL_FACE);
		case Clockwise:
			GLES20.glEnable(GLES20.GL_CULL_FACE);
			GLES20.glCullFace(GLES20.GL_FRONT);
		case CounterClockwise:
			GLES20.glEnable(GLES20.GL_CULL_FACE);
			GLES20.glCullFace(GLES20.GL_BACK);
		}
	}

	public function setPipeline(pipeline: PipelineState): Void {
		pipeline.set();
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
	
	public function setFloats(location: kha.graphics4.ConstantLocation, values: Vector<FastFloat>): Void {
		for (i in 0...values.length) {
			valuesCache[i] = values[i];
		}
		GLES20.glUniform1fv(cast(location, ConstantLocation).value, values.length, valuesCache, 0);
	}
	
	public function setVector2(location: kha.graphics4.ConstantLocation, value: FastVector2): Void {
		GLES20.glUniform2f(cast(location, ConstantLocation).value, value.x, value.y);
	}
	
	public function setVector3(location: kha.graphics4.ConstantLocation, value: FastVector3): Void {
		GLES20.glUniform3f(cast(location, ConstantLocation).value, value.x, value.y, value.z);
	}
	
	public function setVector4(location: kha.graphics4.ConstantLocation, value: FastVector4): Void {
		GLES20.glUniform4f(cast(location, ConstantLocation).value, value.x, value.y, value.z, value.w);
	}
	
	private var matrixCache = new NativeArray<Single>(16);
	
	public inline function setMatrix(location: kha.graphics4.ConstantLocation, matrix: FastMatrix4): Void {
		matrixCache[ 0] = matrix._00; matrixCache[ 1] = matrix._01; matrixCache[ 2] = matrix._02; matrixCache[ 3] = matrix._03;
		matrixCache[ 4] = matrix._10; matrixCache[ 5] = matrix._11; matrixCache[ 6] = matrix._12; matrixCache[ 7] = matrix._13;
		matrixCache[ 8] = matrix._20; matrixCache[ 9] = matrix._21; matrixCache[10] = matrix._22; matrixCache[11] = matrix._23;
		matrixCache[12] = matrix._30; matrixCache[13] = matrix._31; matrixCache[14] = matrix._32; matrixCache[15] = matrix._33;
		GLES20.glUniformMatrix4fv(cast(location, ConstantLocation).value, 1, false, matrixCache, 0);
	}

	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		GLES20.glDrawElements(GLES20.GL_TRIANGLES, count == -1 ? indexBuffer.count() : count, GLES20.GL_UNSIGNED_SHORT, indexBuffer.data);
	}
	
	public function drawIndexedVerticesInstanced(instanceCount: Int, start: Int = 0, count: Int = -1): Void {
		
	}
	
	public function instancedRenderingAvailable(): Bool {
		return false;
	}
	
	public function setStencilParameters(compareMode: CompareMode, bothPass: StencilAction, depthFail: StencilAction, stencilFail: StencilAction, referenceValue: Int, readMask: Int = 0xff, writeMask: Int = 0xff): Void {
		
	}

	public function scissor(x: Int, y: Int, width: Int, height: Int): Void {
		
	}

	public function disableScissor(): Void {
		
	}
	
	public function renderTargetsInvertedY(): Bool {
		return true;
	}
}
