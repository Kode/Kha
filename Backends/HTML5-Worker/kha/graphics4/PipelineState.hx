package kha.graphics4;

import kha.graphics4.FragmentShader;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

class PipelineState extends PipelineStateBase {
	static var lastId: Int = -1;

	public var _id: Int;

	var textures: Array<String>;
	var textureValues: Array<Dynamic>;

	public function new() {
		super();
		_id = ++lastId;
		textures = new Array<String>();
		textureValues = new Array<Dynamic>();
	}

	public function delete(): Void {}

	public function compile(): Void {
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
					data: element.data
				});
			}
			layout.push({
				elements: elements
			});
		}

		var state = {
			cullMode: cullMode,
			depthWrite: depthWrite,
			depthMode: depthMode,
			stencilMode: stencilMode,
			stencilBothPass: stencilBothPass,
			stencilDepthFail: stencilDepthFail,
			stencilFail: stencilFail,
			stencilReferenceValue: stencilReferenceValue,
			stencilReadMask: stencilReadMask,
			stencilWriteMask: stencilWriteMask,
			blendSource: blendSource,
			blendDestination: blendDestination,
			alphaBlendSource: alphaBlendSource,
			alphaBlendDestination: alphaBlendDestination,
			colorWriteMaskRed: colorWriteMaskRed,
			colorWriteMaskGreen: colorWriteMaskGreen,
			colorWriteMaskBlue: colorWriteMaskBlue,
			colorWriteMaskAlpha: colorWriteMaskAlpha,
			conservativeRasterization: conservativeRasterization
		};

		Worker.postMessage({
			command: 'compilePipeline',
			id: _id,
			frag: fragmentShader.files[0],
			vert: vertexShader.files[0],
			layout: layout,
			state: state
		});
	}

	public function getConstantLocation(name: String): kha.graphics4.ConstantLocation {
		var loc = new kha.html5worker.ConstantLocation();
		Worker.postMessage({
			command: 'createConstantLocation',
			id: loc._id,
			name: name,
			pipeline: _id
		});
		return loc;
	}

	public function getTextureUnit(name: String): kha.graphics4.TextureUnit {
		var unit = new kha.html5worker.TextureUnit();
		Worker.postMessage({
			command: 'createTextureUnit',
			id: unit._id,
			name: name,
			pipeline: _id
		});
		return unit;
	}
}
