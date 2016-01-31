package kha;
import kha.arrays.Float32Array;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;

class Float32ArrayExtensions {
	
	public static inline function setVector2(array: Float32Array, index: Int, vector: FastVector2) {
		array.set(index +  0, vector.x);
		array.set(index +  1, vector.y);
	}
	
	public static inline function setVector3(array: Float32Array, index: Int, vector: FastVector3) {
		array.set(index +  0, vector.x);
		array.set(index +  1, vector.y);
		array.set(index +  2, vector.z);
	}
	
	public static inline function setVector4(array: Float32Array, index: Int, vector: FastVector4) {
		array.set(index +  0, vector.x);
		array.set(index +  1, vector.y);
		array.set(index +  2, vector.z);
		array.set(index +  3, vector.w);
	}
	
	public static inline function setColor(array: Float32Array, index: Int, color: Color) {
		array.set(index +  0, color.R);
		array.set(index +  1, color.G);
		array.set(index +  2, color.B);
		array.set(index +  3, color.A);
	}
	
	public static inline function setMatrix3(array: Float32Array, index: Int, matrix: FastMatrix3) {
		array.set(index +  0, matrix._00);
		array.set(index +  1, matrix._01);
		array.set(index +  2, matrix._02);
		
		array.set(index +  3, matrix._10);
		array.set(index +  4, matrix._11);
		array.set(index +  5, matrix._12);
		
		array.set(index +  6, matrix._20);				
		array.set(index +  7, matrix._21);				
		array.set(index +  8, matrix._22);
	}
	
	public static inline function setMatrix4(array: Float32Array, index: Int, matrix: FastMatrix4) {
		array.set(index +  0, matrix._00);
		array.set(index +  1, matrix._01);
		array.set(index +  2, matrix._02);
		array.set(index +  3, matrix._03);
		
		array.set(index +  4, matrix._10);
		array.set(index +  5, matrix._11);
		array.set(index +  6, matrix._12);
		array.set(index +  7, matrix._13);
		
		array.set(index +  8, matrix._20);				
		array.set(index +  9, matrix._21);				
		array.set(index + 10, matrix._22);
		array.set(index + 11, matrix._23);
		
		array.set(index + 12, matrix._30);				
		array.set(index + 13, matrix._31);				
		array.set(index + 14, matrix._32);
		array.set(index + 15, matrix._33);
	}
}