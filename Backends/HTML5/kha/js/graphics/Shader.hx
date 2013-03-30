package kha.js.graphics;

import kha.graphics.FragmentShader;
import kha.graphics.VertexShader;

class Shader implements VertexShader, implements FragmentShader {
	public var source: String;
	public var type: Dynamic;
	public var shader: Dynamic;
	
	public function new(source: String, type: Dynamic) {
		this.source = source;
		this.type = type;
		this.shader = null;
	}
	
	public function setInt(name: String, value: Int): Void {
		//Sys.gl.uniform1i(cast(Sys.graphics, Graphics).getLocation(name), value);
	}
	
	public function setFloat(name: String, value: Float): Void {
		//Sys.gl.uniform1f(cast(Sys.graphics, Graphics).getLocation(name), value);
	}
	
	public function setFloat2(name: String, value1: Float, value2: Float): Void {
		//Sys.gl.uniform2f(cast(Sys.graphics, Graphics).getLocation(name), value1, value2);
	}
	
	public function setFloat3(name: String, value1: Float, value2: Float, value3: Float): Void {
		//Sys.gl.uniform3f(cast(Sys.graphics, Graphics).getLocation(name), value1, value2, value3);
	}
}
