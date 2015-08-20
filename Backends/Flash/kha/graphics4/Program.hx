package kha.graphics4;

import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import kha.flash.utils.AGALMiniAssembler;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

using StringTools;

class Program {
	private var program: Program3D;
	private var fragmentShader: FragmentShader;
	private var vertexShader: VertexShader;
	
	public function new() {
		program = kha.flash.graphics4.Graphics.context.createProgram();
	}

	public function setVertexShader(shader: VertexShader): Void {
		vertexShader = shader;
	}

	public function setFragmentShader(shader: FragmentShader): Void {
		fragmentShader = shader;
	}
	
	public function link(structure: VertexStructure): Void {
		var vertexAssembler = new AGALMiniAssembler();
		vertexAssembler.assemble(Context3DProgramType.VERTEX, vertexShader.source);
		
		var fragmentAssembler = new AGALMiniAssembler();
		fragmentAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader.source);
		
		program.upload(vertexAssembler.agalcode(), fragmentAssembler.agalcode());
	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		var type: Context3DProgramType;
		var value: Int;
		if (Reflect.hasField(vertexShader.names, name)) {
			type = Context3DProgramType.VERTEX;
			value = Reflect.field(vertexShader.names, name).substr(2);
		}
		else {
			type = Context3DProgramType.FRAGMENT;
			value = Reflect.field(fragmentShader.names, name).substr(2);
		}
		return new kha.flash.graphics4.ConstantLocation(value, type);
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		var unit = new kha.flash.graphics4.TextureUnit();
		if (Reflect.hasField(vertexShader.names, name)) {
			unit.unit = Reflect.field(vertexShader.names, name).substr(2);
		}
		else {
			unit.unit = Reflect.field(fragmentShader.names, name).substr(2);
		}
		return unit;
	}
	
	public function getAttributeLocation(name: String): kha.graphics4.AttributeLocation {
		return null;
	}
	
	public function set(): Void {
		kha.flash.graphics4.Graphics.context.setProgram(program);
		
		var vec = new flash.Vector<Float>(4);
		vec[0] = vertexShader.constants.vc0[0];
		vec[1] = vertexShader.constants.vc0[1];
		vec[2] = vertexShader.constants.vc0[2];
		vec[3] = vertexShader.constants.vc0[3];
		kha.flash.graphics4.Graphics.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vec);
		vec[0] = fragmentShader.constants.fc0[0];
		vec[1] = fragmentShader.constants.fc0[1];
		vec[2] = fragmentShader.constants.fc0[2];
		vec[3] = fragmentShader.constants.fc0[3];
		kha.flash.graphics4.Graphics.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, vec);
	}
}
