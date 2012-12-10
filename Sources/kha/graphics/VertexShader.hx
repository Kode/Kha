package kha.graphics;

interface VertexShader {
	function setInt(name: String, value: Int): Void;
	function setFloat(name: String, value: Float): Void;
	function setFloat2(name: String, value1: Float, value2: Float): Void;
	function setFloat3(name: String, value1: Float, value2: Float, value3: Float): Void;
}