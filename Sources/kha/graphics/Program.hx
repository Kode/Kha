package kha.graphics;

interface Program {
	function setVertexShader(shader: VertexShader): Void;
	function setFragmentShader(shader: FragmentShader): Void;
	function link(structure: VertexStructure): Void;
	
	function getConstantLocation(name: String): ConstantLocation;
}
