package kha.cpp.graphics;

import kha.Blob;
import kha.graphics.FragmentShader;
import kha.graphics.VertexShader;
import kha.graphics.VertexStructure;
import kha.graphics.TextureWrap;

@:headerCode('
#include <Kt/stdafx.h>
#include <Kt/Graphics/Graphics.h>
')

class Graphics implements kha.graphics.Graphics {
	public function new() {
		
	}
	
	public function createVertexBuffer(vertexCount: Int, structure: VertexStructure): kha.graphics.VertexBuffer {
		return new VertexBuffer(vertexCount, structure);
	}
	
	public function setVertexBuffer(vertexBuffer: kha.graphics.VertexBuffer): Void {
		cast(vertexBuffer, VertexBuffer).set();
	}
	
	public function createIndexBuffer(indexCount: Int): kha.graphics.IndexBuffer {
		return new IndexBuffer(indexCount);
	}
	
	public function setIndexBuffer(indexBuffer: kha.graphics.IndexBuffer): Void {
		cast(indexBuffer, IndexBuffer).set();
	}
	
	@:functionCode('
		Kt::Graphics::setTextureAddressing(stage, Kt::U, (Kt::TextureAddressing)uWrap);
		Kt::Graphics::setTextureAddressing(stage, Kt::V, (Kt::TextureAddressing)vWrap);
	')
	private function setTextureWrapNative(stage: Int, uWrap: Int, vWrap: Int): Void {
		
	}
	
	//enum TextureAddressing {
	//	Repeat,
	//	Mirror,
	//	Clamp,
	//	Border
	//};
	public function setTextureWrap(stage: Int, u: TextureWrap, v: TextureWrap): Void {
		setTextureWrapNative(stage, u == TextureWrap.ClampToEdge ? 2 : 0, v == TextureWrap.ClampToEdge ? 2 : 0);
	}
	
	public function setTexture(texture: kha.Image, stage: Int): Void {
		cast(texture, Image).set(stage);
	}
	
	public function createVertexShader(source: Blob): VertexShader {
		return new Shader(source, ShaderType.VertexShader);
	}
	
	public function createFragmentShader(source: Blob): FragmentShader {
		return new Shader(source, ShaderType.FragmentShader);
	}
	
	public function createProgram(): kha.graphics.Program {
		return new Program();
	}
	
	public function setProgram(program: kha.graphics.Program): Void {
		cast(program, Program).set();
	}
	
	public function setInt(location: kha.graphics.ConstantLocation, value: Int): Void {
		setIntPrivate(cast(location, ConstantLocation), value);
	}
	
	@:functionCode('
		Kt::Graphics::setInt(location->location, value);
	')
	private function setIntPrivate(location: ConstantLocation, value: Int): Void {
		
	}

	public function setFloat(location: kha.graphics.ConstantLocation, value: Float): Void {
		setFloatPrivate(cast(location, ConstantLocation), value);
	}
	
	@:functionCode('
		Kt::Graphics::setFloat(location->location, value);
	')
	private function setFloatPrivate(location: ConstantLocation, value: Float): Void {
		
	}
	
	public function setFloat2(location: kha.graphics.ConstantLocation, value1: Float, value2: Float): Void {
		setFloat2Private(cast(location, ConstantLocation), value1, value2);
	}
	
	@:functionCode('
		Kt::Graphics::setFloat2(location->location, value1, value2);
	')
	private function setFloat2Private(location: ConstantLocation, value1: Float, value2: Float): Void {
		
	}
	
	public function setFloat3(location: kha.graphics.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		setFloat3Private(cast(location, ConstantLocation), value1, value2, value3);
	}
	
	@:functionCode('
		Kt::Graphics::setFloat3(location->location, value1, value2, value3);
	')
	private function setFloat3Private(location: ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		
	}
	
	@:functionCode('
		Kt::Matrix4x4f value;
		for (int y = 0; y < 4; ++y) {
			for (int x = 0; x < 4; ++x) {
				value.Set(x, y, matrix[y * 4 + x]);
			}
		}
		::kha::cpp::graphics::ConstantLocation_obj* loc = dynamic_cast< ::kha::cpp::graphics::ConstantLocation_obj*>(location->__GetRealObject());
		Kt::Graphics::setMatrix(loc->location, value);
	')
	public function setMatrix(location: kha.graphics.ConstantLocation, matrix: Array<Float>): Void {
		
	}
	
	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		if (count < 0) drawAllIndexedVertices();
		else drawSomeIndexedVertices(start, count);
	}
	
	@:functionCode('
		Kt::Graphics::drawIndexedVertices();
	')
	private function drawAllIndexedVertices(): Void {
		
	}
	
	@:functionCode('
		Kt::Graphics::drawIndexedVertices(start, count);
	')
	public function drawSomeIndexedVertices(start: Int, count: Int): Void {
		
	}
}
