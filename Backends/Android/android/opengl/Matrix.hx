package android.opengl;

import java.NativeArray;

extern class Matrix {
	public static function orthoM(matrix : NativeArray<Single>, x : Int, y : Int, width : Int, height : Int, unknown : Int, znear : Single, zfar : Single) : Void;
}