package kha.graphics4;

import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import kha.flash.utils.AGALMiniAssembler;
import kha.graphics4.FragmentShader;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

using StringTools;

class PipelineState extends PipelineStateBase {
	private var program: Program3D;
	private var vc: haxe.ds.Vector<flash.Vector<Float>>;
	private var fc: haxe.ds.Vector<flash.Vector<Float>>;
	
	public function new() {
		super();
		program = kha.flash.graphics4.Graphics.context.createProgram();
	}

	public function compile(): Void {
		var vclength: Int = 0;
		for (i in 0...128) {
			var name = "vc" + i;
			if (Reflect.hasField(vertexShader.constants, name)) {
				vclength = i + 1;
			}
		}
		
		var fclength: Int = 0;
		for (i in 0...28) {
			var name = "fc" + i;
			if (Reflect.hasField(fragmentShader.constants, name)) {
				fclength = i + 1;
			}
		}
	
		vc = new haxe.ds.Vector<flash.Vector<Float>>(vclength);
		for (i in 0...vclength) {
			var name = "vc" + i;
			if (Reflect.hasField(vertexShader.constants, name)) {
				var field = Reflect.field(vertexShader.constants, name);
				vc[i] = new flash.Vector<Float>(4);
				vc[i][0] = field[0];
				vc[i][1] = field[1];
				vc[i][2] = field[2];
				vc[i][3] = field[3];
			}
		}

		fc = new haxe.ds.Vector<flash.Vector<Float>>(fclength);
		for (i in 0...fclength) {
			var name = "fc" + i;
			if (Reflect.hasField(fragmentShader.constants, name)) {
				var field = Reflect.field(fragmentShader.constants, name);
				fc[i] = new flash.Vector<Float>(4);
				fc[i][0] = field[0];
				fc[i][1] = field[1];
				fc[i][2] = field[2];
				fc[i][3] = field[3];
			}
		}
		
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
		
	public function set(): Void {
		kha.flash.graphics4.Graphics.context.setProgram(program);
		
		for (i in 0...vc.length) {
			if (vc[i] != null) {
				kha.flash.graphics4.Graphics.context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, i, vc[i]);
			}
		}
		
		for (i in 0...fc.length) {
			if (fc[i] != null) {
				kha.flash.graphics4.Graphics.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, i, fc[i]);
			}
		}
	}
}
