extern class Krom {
    static function clear(): Void;
    
    static function createVertexShader(data: haxe.io.BytesData, name: String): Dynamic;
    static function createFragmentShader(data: haxe.io.BytesData, name: String): Dynamic;
    static function createProgram(): Dynamic;
    static function compileProgram(program: Dynamic, structure: Array<kha.graphics4.VertexElement>, vertexShader: Dynamic, fragmentShader: Dynamic): Void;
    static function setProgram(program: Dynamic): Void;
    static function getConstantLocation(program: Dynamic, name: String): Dynamic;
    static function getTextureUnit(program: Dynamic, name: String): Dynamic;
    static function setTexture(stage: kha.graphics4.TextureUnit, texture: Dynamic): Void;
	static function setBool(location: kha.graphics4.ConstantLocation, value: Bool): Void;
	static function setInt(location: kha.graphics4.ConstantLocation, value: Int): Void;
	static function setFloat(location: kha.graphics4.ConstantLocation, value: Float): Void;
	static function setFloat2(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float): Void;
	static function setFloat3(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float): Void;
	static function setFloat4(location: kha.graphics4.ConstantLocation, value1: Float, value2: Float, value3: Float, value4: Float): Void;
	static function setMatrix(location: kha.graphics4.ConstantLocation, matrix: kha.math.FastMatrix4): Void;
    
    static function begin(renderTarget: kha.Image): Void;
    static function end(): Void;
    static function createRenderTarget(width: Int, height: Int): Dynamic;
    static function createIndexBuffer(count: Int): Dynamic;
    static function setIndices(buffer: Dynamic, indices: Array<Int>): Void;
    static function setIndexBuffer(buffer: Dynamic): Void;
    static function createVertexBuffer(count: Int, structure: Array<kha.graphics4.VertexElement>): Dynamic;
    static function setVertices(buffer: Dynamic, vertices: kha.arrays.Float32Array): Void;
    static function setVertexBuffer(buffer: Dynamic): Void;
    static function drawIndexedVertices(start: Int, count: Int): Void;
    
    static function loadImage(file: String): Dynamic;
    static function loadSound(file: String): Dynamic;
    static function loadBlob(file: String): js.html.ArrayBuffer;
    
    static function log(string: String): Void;
    static function setCallback(callback: Void->Void): Void;
    static function setKeyboardDownCallback(callback: Int->Void): Void;
    static function setKeyboardUpCallback(callback: Int->Void): Void;
    static function setMouseDownCallback(callback: Int->Int->Int->Void): Void;
    static function setMouseUpCallback(callback: Int->Int->Int->Void): Void;
    static function setMouseMoveCallback(callback: Int->Int->Void): Void;
    static function getTime(): Float;
}
