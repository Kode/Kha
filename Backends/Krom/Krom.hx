extern class Krom {
    static function clear(): Void;
    static function createVertexShader(data: haxe.io.BytesData): Dynamic;
    static function createFragmentShader(data: haxe.io.BytesData): Dynamic;
    static function createProgram(): Dynamic;
    static function compileProgram(program: Dynamic, structure: Array<kha.graphics4.VertexElement>, vertexShader: Dynamic, fragmentShader: Dynamic): Void;
    static function setProgram(program: Dynamic): Void;
    static function createIndexBuffer(count: Int): Dynamic;
    static function setIndices(buffer: Dynamic, indices: Array<Int>): Void;
    static function setIndexBuffer(buffer: Dynamic): Void;
    static function createVertexBuffer(count: Int, structure: Array<kha.graphics4.VertexElement>): Dynamic;
    static function setVertices(buffer: Dynamic, vertices: kha.arrays.Float32Array): Void;
    static function setVertexBuffer(buffer: Dynamic): Void;
    static function drawIndexedVertices(): Void;
    
    static function log(string: String): Void;
    static function setCallback(callback: Void->Void): Void;
}
