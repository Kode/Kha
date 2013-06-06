package kha.cpp.graphics;

import kha.Blob;
import kha.Color;
import kha.graphics.FragmentShader;
import kha.graphics.Texture;
import kha.graphics.TextureFormat;
import kha.graphics.VertexShader;
import kha.graphics.VertexStructure;
import kha.graphics.TextureWrap;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
')

class Graphics implements kha.graphics.Graphics {
	public function new() {
		
	}
	
	public function clear(?color: Color, ?z: Float, ?stencil: Int): Void {
		var flags: Int = 0;
		if (color != null) flags |= 1;
		if (z != null) flags |= 2;
		if (stencil != null) flags |= 4;
		clear2(flags, color, z, stencil);
	}
	
	@:functionCode('
		Kore::Graphics::clear(flags, color->value, z, stencil);
	')
	private function clear2(flags: Int, color: Color, z: Float, stencil: Int): Void {
		
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
	
	public function createTexture(width: Int, height: Int, format: TextureFormat): Texture {
		return Image.create(width, height, format);
	}
	
	@:functionCode('
		Kore::Graphics::setTextureAddressing(unit->unit, Kore::U, (Kore::TextureAddressing)uWrap);
		Kore::Graphics::setTextureAddressing(unit->unit, Kore::V, (Kore::TextureAddressing)vWrap);
	')
	private function setTextureWrapNative(unit: TextureUnit, uWrap: Int, vWrap: Int): Void {
		
	}
	
	//enum TextureAddressing {
	//	Repeat,
	//	Mirror,
	//	Clamp,
	//	Border
	//};
	public function setTextureWrap(unit: kha.graphics.TextureUnit, u: TextureWrap, v: TextureWrap): Void {
		setTextureWrapNative(cast unit, u == TextureWrap.ClampToEdge ? 2 : 0, v == TextureWrap.ClampToEdge ? 2 : 0);
	}
	
	public function setTexture(unit: kha.graphics.TextureUnit, texture: kha.Image): Void {
		cast(texture, Image).set(cast unit);
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
		Kore::Graphics::setInt(location->location, value);
	')
	private function setIntPrivate(location: ConstantLocation, value: Int): Void {
		
	}

	public function setFloat(location: kha.graphics.ConstantLocation, value: Float): Void {
		setFloatPrivate(cast(location, ConstantLocation), value);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat(location->location, value);
	')
	private function setFloatPrivate(location: ConstantLocation, value: Float): Void {
		
	}
	
	public function setFloat2(location: kha.graphics.ConstantLocation, value1: Float, value2: Float): Void {
		setFloat2Private(cast(location, ConstantLocation), value1, value2);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat2(location->location, value1, value2);
	')
	private function setFloat2Private(location: ConstantLocation, value1: Float, value2: Float): Void {
		
	}
	
	public function setFloat3(location: kha.graphics.ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		setFloat3Private(cast(location, ConstantLocation), value1, value2, value3);
	}
	
	@:functionCode('
		Kore::Graphics::setFloat3(location->location, value1, value2, value3);
	')
	private function setFloat3Private(location: ConstantLocation, value1: Float, value2: Float, value3: Float): Void {
		
	}
	
	@:functionCode('
		Kore::mat4 value;
		for (int y = 0; y < 4; ++y) {
			for (int x = 0; x < 4; ++x) {
				value.Set(x, y, matrix[y * 4 + x]);
			}
		}
		::kha::cpp::graphics::ConstantLocation_obj* loc = dynamic_cast< ::kha::cpp::graphics::ConstantLocation_obj*>(location->__GetRealObject());
		Kore::Graphics::setMatrix(loc->location, value);
	')
	public function setMatrix(location: kha.graphics.ConstantLocation, matrix: Array<Float>): Void {
		
	}
	
	public function drawIndexedVertices(start: Int = 0, count: Int = -1): Void {
		if (count < 0) drawAllIndexedVertices();
		else drawSomeIndexedVertices(start, count);
	}
	
	@:functionCode('
		Kore::Graphics::drawIndexedVertices();
	')
	private function drawAllIndexedVertices(): Void {
		
	}
	
	@:functionCode('
		Kore::Graphics::drawIndexedVertices(start, count);
	')
	public function drawSomeIndexedVertices(start: Int, count: Int): Void {
		
	}
}
