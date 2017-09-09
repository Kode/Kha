package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class PipelineState extends PipelineStateBase {
	static var lastId: Int = -1;
	public var _id: Int;
	private var textures: Array<String>;
	private var textureValues: Array<Dynamic>;
	
	public function new() {
		super();
		_id = ++lastId;
		textures = new Array<String>();
		textureValues = new Array<Dynamic>();
	}
	
	public function delete(): Void {

	}
		
	public function compile(): Void {
		compileShader(vertexShader);
		compileShader(fragmentShader);
		
		var index = 0;
		for (structure in inputLayout) {
			for (element in structure.elements) {
				if (element.data == VertexData.Float4x4) {
					index += 4;
				}
				else {
					++index;
				}
			}
		}
		
		var layout = new Array<Dynamic>();
		for (input in inputLayout) {
			var elements = new Array<Dynamic>();
			for (element in input.elements) {
				elements.push({
					name: element.name,
					data: element.data.getIndex()
				});
			}
			layout.push({
				elements: elements
			});
		}
		
		Worker.postMessage({ command: 'compilePipeline', id: _id, frag: fragmentShader.files[0], vert: vertexShader.files[0], layout: layout });
	}
	
	public function set(): Void {

	}
	
	private function compileShader(shader: Dynamic): Void {

	}
	
	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		return null;
	}
	
	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		return null;
	}
}
