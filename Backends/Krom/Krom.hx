extern class Krom {
	static inline var KROM_API: Int = 6;

	static function clear(flags: Int, color: Int, depth: Float, stencil: Int): Void;

	static function createVertexShader(data: haxe.io.BytesData, name: String): Dynamic;
	static function createVertexShaderFromSource(source: String): Dynamic;
	static function createFragmentShader(data: haxe.io.BytesData, name: String): Dynamic;
	static function createFragmentShaderFromSource(source: String): Dynamic;
	static function createGeometryShader(data: haxe.io.BytesData, name: String): Dynamic;
	static function createTessellationControlShader(data: haxe.io.BytesData, name: String): Dynamic;
	static function createTessellationEvaluationShader(data: haxe.io.BytesData, name: String): Dynamic;
	static function deleteShader(shader: Dynamic): Dynamic;
	static function createPipeline(): Dynamic;
	static function deletePipeline(pipeline: Dynamic): Dynamic;
	static function compilePipeline(pipeline: Dynamic, structure0: Dynamic, structure1: Dynamic, structure2: Dynamic, structure3: Dynamic, length: Int,
		vertexShader: Dynamic, fragmentShader: Dynamic, geometryShader: Dynamic, tessellationControlShader: Dynamic, tessellationEvaluationShader: Dynamic,
		state: Dynamic): Void;
	static function setPipeline(pipeline: Dynamic): Void;
	static function getConstantLocation(pipeline: Dynamic, name: String): Dynamic;
	static function getTextureUnit(pipeline: Dynamic, name: String): Dynamic;
	static function setTexture(stage: kha.graphics4.TextureUnit, texture: Dynamic): Void;
	static function setRenderTarget(stage: kha.graphics4.TextureUnit, renderTarget: Dynamic): Void;
	static function setTextureDepth(unit: kha.graphics4.TextureUnit, texture: Dynamic): Void;
	static function setImageTexture(stage: kha.graphics4.TextureUnit, texture: Dynamic): Void;
	static function setTextureParameters(texunit: kha.graphics4.TextureUnit, uAddressing: Int, vAddressing: Int, minificationFilter: Int,
		magnificationFilter: Int, mipmapFilter: Int): Void;
	static function setTexture3DParameters(texunit: kha.graphics4.TextureUnit, uAddressing: Int, vAddressing: Int, wAddressing: Int, minificationFilter: Int,
		magnificationFilter: Int, mipmapFilter: Int): Void;
	static function setTextureCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool): Void;
	static function setCubeMapCompareMode(texunit: kha.graphics4.TextureUnit, enabled: Bool): Void;
	static function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void;
	static function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void;
	static function setFloat(location: kha.graphics4.ConstantLocation, value: Float): Void;
	static function setFloat2(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float): Void;
	static function setFloat3(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float): Void;
	static function setFloat4(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float, value4: Float): Void;
	static function setFloats(location: kha.graphics4.ConstantLocation, values: js.lib.ArrayBuffer): Void;
	static function setMatrix(location: kha.graphics4.ConstantLocation, matrix: js.lib.ArrayBuffer): Void;
	static function setMatrix3(location: kha.graphics4.ConstantLocation, matrix: js.lib.ArrayBuffer): Void;

	static function begin(renderTarget: kha.Canvas, additionalRenderTargets: Array<kha.Canvas>): Void;
	static function beginFace(renderTarget: kha.Canvas, face: Int): Void;
	static function end(): Void;
	static function renderTargetsInvertedY(): Bool;
	static function viewport(x: Int, y: Int, width: Int, height: Int): Void;
	static function scissor(x: Int, y: Int, width: Int, height: Int): Void;
	static function disableScissor(): Void;
	static function createRenderTarget(width: Int, height: Int, format: Int, depthBufferBits: Int, stencilBufferBits: Int): Dynamic;
	static function createRenderTargetCubeMap(cubeMapSize: Int, format: Int, depthBufferBits: Int, stencilBufferBits: Int): Dynamic;
	static function createTexture(width: Int, height: Int, format: Int): Dynamic;
	static function createTexture3D(width: Int, height: Int, depth: Int, format: Int): Dynamic;
	static function createTextureFromBytes(data: haxe.io.BytesData, width: Int, height: Int, format: Int, readable: Bool): Dynamic;
	static function createTextureFromBytes3D(data: haxe.io.BytesData, width: Int, height: Int, depth: Int, format: Int, readable: Bool): Dynamic;
	static function createTextureFromEncodedBytes(data: haxe.io.BytesData, format: String, readable: Bool): Dynamic;
	static function getTexturePixels(texture: Dynamic): haxe.io.BytesData;
	static function getRenderTargetPixels(renderTarget: Dynamic, data: haxe.io.BytesData): Void;
	static function lockTexture(texture: Dynamic, level: Int): js.lib.ArrayBuffer;
	static function unlockTexture(texture: Dynamic): Void;
	static function generateTextureMipmaps(texture: Dynamic, levels: Int): Void;
	static function generateRenderTargetMipmaps(renderTarget: Dynamic, levels: Int): Void;
	static function setMipmaps(texture: Dynamic, mipmaps: Array<kha.Image>): Void;
	static function setDepthStencilFrom(target: Dynamic, source: Dynamic): Void;
	static function clearTexture(target: Dynamic, x: Int, y: Int, z: Int, width: Int, height: Int, depth: Int, color: Int): Void;
	static function createIndexBuffer(count: Int): Dynamic;
	static function deleteIndexBuffer(buffer: Dynamic): Dynamic;
	static function lockIndexBuffer(buffer: Dynamic): kha.arrays.Uint32Array;
	static function unlockIndexBuffer(buffer: Dynamic): Void;
	static function setIndexBuffer(buffer: Dynamic): Void;
	static function createVertexBuffer(count: Int, structure: Array<kha.graphics4.VertexElement>, usage: Int, instanceDataStepRate: Int): Dynamic;
	static function deleteVertexBuffer(buffer: Dynamic): Dynamic;
	static function lockVertexBuffer(buffer: Dynamic, start: Int, count: Int): js.lib.ArrayBuffer;
	static function unlockVertexBuffer(buffer: Dynamic, count: Int): Void;
	static function setVertexBuffer(buffer: Dynamic): Void;
	static function setVertexBuffers(vertexBuffers: Array<kha.graphics4.VertexBuffer>): Void;
	static function drawIndexedVertices(start: Int, count: Int): Void;
	static function drawIndexedVerticesInstanced(instanceCount: Int, start: Int, count: Int): Void;

	static function loadImage(file: String, readable: Bool): Dynamic;
	static function unloadImage(image: kha.Image): Void;
	static function loadSound(file: String): Dynamic;
	static function writeAudioBuffer(buffer: js.lib.ArrayBuffer, samples: Int): Void;
	static function loadBlob(file: String): js.lib.ArrayBuffer;

	static function init(title: String, width: Int, height: Int, samplesPerPixel: Int, vSync: Bool, windowMode: Int, windowFeatures: Int, kromApi: Int): Void;
	static function log(v: Dynamic): Void;
	static function setCallback(callback: Void->Void): Void;
	static function setDropFilesCallback(callback: String->Void): Void;
	static function setCutCopyPasteCallback(cutCallback: Void->String, copyCallback: Void->String, pasteCallback: String->Void): Void;
	static function setApplicationStateCallback(foregroundCallback: Void->Void, resumeCallback: Void->Void, pauseCallback: Void->Void,
		backgroundCallback: Void->Void, shutdownCallback: Void->Void): Void;
	static function setKeyboardDownCallback(callback: Int->Void): Void;
	static function setKeyboardUpCallback(callback: Int->Void): Void;
	static function setKeyboardPressCallback(callback: Int->Void): Void;
	static function setMouseDownCallback(callback: Int->Int->Int->Void): Void;
	static function setMouseUpCallback(callback: Int->Int->Int->Void): Void;
	static function setMouseMoveCallback(callback: Int->Int->Int->Int->Void): Void;
	static function setMouseWheelCallback(callback: Int->Void): Void;
	static function setPenDownCallback(callback: Int->Int->Float->Void): Void;
	static function setPenUpCallback(callback: Int->Int->Float->Void): Void;
	static function setPenMoveCallback(callback: Int->Int->Float->Void): Void;
	static function setGamepadAxisCallback(callback: Int->Int->Float->Void): Void;
	static function setGamepadButtonCallback(callback: Int->Int->Float->Void): Void;
	static function lockMouse(): Void;
	static function unlockMouse(): Void;
	static function canLockMouse(): Bool;
	static function isMouseLocked(): Bool;
	static function setMousePosition(windowId: Int, x: Int, y: Int): Void;
	static function showMouse(show: Bool): Void;
	static function setAudioCallback(callback: Int->Void): Void;
	static function getTime(): Float;
	static function windowWidth(id: Int): Int;
	static function windowHeight(id: Int): Int;
	static function setWindowTitle(id: Int, title: String): Void;
	static function screenDpi(): Int;
	static function systemId(): String;
	static function requestShutdown(): Void;
	static function displayCount(): Int;
	static function displayWidth(index: Int): Int;
	static function displayHeight(index: Int): Int;
	static function displayX(index: Int): Int;
	static function displayY(index: Int): Int;
	static function displayIsPrimary(index: Int): Bool;
	static function writeStorage(name: String, data: haxe.io.BytesData): Void;
	static function readStorage(name: String): haxe.io.BytesData;

	static function fileSaveBytes(path: String, bytes: haxe.io.BytesData): Void;
	static function sysCommand(cmd: String, ?args: Array<String>): Int;
	static function savePath(): String;
	static function getArgCount(): Int;
	static function getArg(index: Int): String;
	static function getFilesLocation(): String;

	static function setBoolCompute(location: kha.compute.ConstantLocation, value: Bool): Void;
	static function setIntCompute(location: kha.compute.ConstantLocation, value: Int): Void;
	static function setFloatCompute(location: kha.compute.ConstantLocation, value: Float): Void;
	static function setFloat2Compute(location: kha.compute.ConstantLocation, value1: Float, value2: Float): Void;
	static function setFloat3Compute(location: kha.compute.ConstantLocation, value1: Float, value2: Float, value3: Float): Void;
	static function setFloat4Compute(location: kha.compute.ConstantLocation, value1: Float, value2: Float, value3: Float, value4: Float): Void;
	static function setFloatsCompute(location: kha.compute.ConstantLocation, values: js.lib.ArrayBuffer): Void;
	static function setMatrixCompute(location: kha.compute.ConstantLocation, matrix: js.lib.ArrayBuffer): Void;
	static function setMatrix3Compute(location: kha.compute.ConstantLocation, matrix: js.lib.ArrayBuffer): Void;
	static function setTextureCompute(unit: kha.compute.TextureUnit, texture: Dynamic, access: Int): Void;
	static function setRenderTargetCompute(unit: kha.compute.TextureUnit, renderTarget: Dynamic, access: Int): Void;
	static function setSampledTextureCompute(unit: kha.compute.TextureUnit, texture: Dynamic): Void;
	static function setSampledRenderTargetCompute(unit: kha.compute.TextureUnit, renderTarget: Dynamic): Void;
	static function setSampledDepthTextureCompute(unit: kha.compute.TextureUnit, texture: Dynamic): Void;
	static function setTextureParametersCompute(texunit: kha.compute.TextureUnit, uAddressing: Int, vAddressing: Int, minificationFilter: Int,
		magnificationFilter: Int, mipmapFilter: Int): Void;
	static function setTexture3DParametersCompute(texunit: kha.compute.TextureUnit, uAddressing: Int, vAddressing: Int, wAddressing: Int,
		minificationFilter: Int, magnificationFilter: Int, mipmapFilter: Int): Void;
	static function setShaderCompute(shader: Dynamic): Void;
	static function deleteShaderCompute(shader: Dynamic): Void;
	static function createShaderCompute(bytes: haxe.io.BytesData): Dynamic;
	static function getConstantLocationCompute(shader: Dynamic, name: String): Dynamic;
	static function getTextureUnitCompute(shader: Dynamic, name: String): Dynamic;
	static function compute(x: Int, y: Int, z: Int): Void;
}
