package android.opengl;

import java.NativeArray;
import java.nio.Buffer;
import java.nio.FloatBuffer;

extern class GLES20 {
	public static var GL_COLOR_BUFFER_BIT : Int;
	public static var GL_NO_ERROR : Int;
	public static var GL_TEXTURE0 : Int;
	public static var GL_TEXTURE_2D : Int;
	public static var GL_TEXTURE_MIN_FILTER : Int;
	public static var GL_TEXTURE_MAG_FILTER : Int;
	public static var GL_NEAREST : Int;
	public static var GL_TEXTURE_WRAP_S : Int;
	public static var GL_TEXTURE_WRAP_T : Int;
	public static var GL_CLAMP_TO_EDGE : Int;
	public static var GL_FLOAT : Int;
	public static var GL_TRIANGLES : Int;
	public static var GL_FRAGMENT_SHADER : Int;
	public static var GL_VERTEX_SHADER : Int;
	public static var GL_BLEND : Int;
	public static var GL_SRC_ALPHA : Int;
	public static var GL_ONE_MINUS_SRC_ALPHA : Int;
	public static var GL_ARRAY_BUFFER : Int;
	public static var GL_DYNAMIC_DRAW : Int;
	public static var GL_ELEMENT_ARRAY_BUFFER : Int;
	public static var GL_STATIC_DRAW : Int;
	
	public static function glClear(bits : Int) : Void;
	public static function glGetError() : Int;
	public static function glBindBuffer(type : Int, buffer : Int) : Void;
	public static function glActiveTexture(texture : Int) : Void;
	public static function glBindTexture(type : Int, texture : Int) : Void;
	public static function glTexParameteri(textype : Int, type : Int, value : Int) : Void;
	public static function glEnableVertexAttribArray(attribute : Int) : Void;
	public static function glCreateShader(shader : Int) : Int;
	public static function glDrawArrays(type : Int, start : Int, count : Int) : Void;
	public static function glUniform1i(uniform : Int, value : Int) : Void;
	public static function glLinkProgram(program : Int) : Void;
	public static function glUseProgram(program : Int) : Void;
	public static function glCreateProgram() : Int;
	public static function glEnable(state : Int) : Void;
	public static function glShaderSource(shader : Int, source : String) : Void;
	public static function glCompileShader(shader : Int) : Void;
	public static function glBlendFunc(srcfunc : Int, destfunc : Int) : Void;
	public static function glViewport(x : Int, y : Int, width : Int, height : Int) : Void;
	public static function glClearColor(r : Single, g : Single, b : Single, a : Single) : Void;
	public static function glClearDepthf(depth : Single) : Void;
	public static function glAttachShader(program : Int, shader : Int) : Void;
	public static function glBindAttribLocation(program : Int, unknown : Int, name : String) : Void;
	public static function glGetUniformLocation(program : Int, name : String) : Int;
	public static function glGetAttribLocation(program : Int, name : String) : Int;
	public static function glVertexAttribPointer(attribute: Int, count: Int, type: Int, unknown: Bool, bytes: Int, offset: Int): Void;
	public static function glBufferData(type : Int, size : Int, vertices : Buffer, draw : Int) : Void;
	public static function glGenTextures(unknown1 : Int, textures : NativeArray<Int>, unknown2 : Int) : Void;
	public static function glGenBuffers(unknown1 : Int, textures : NativeArray<Int>, unknown2 : Int) : Void;
	public static function glUniformMatrix4fv(location : Int, unknown1 : Int, unknown2 : Bool, matrix : NativeArray<Single>, unknown3 : Int) : Void;
}
