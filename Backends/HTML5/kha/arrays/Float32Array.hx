package kha.arrays;

import kha.Color;
import kha.FastFloat;
import kha.math.FastVector2;
import kha.math.FastVector3;
import kha.math.FastVector4;
import kha.math.FastMatrix3;
import kha.math.FastMatrix4;

abstract Float32Array(js.html.Float32Array) {
	public inline function new(elements: Int) {
		this = new js.html.Float32Array(elements);
	}
	
	public var length(get, never): Int;

	inline function get_length(): Int {
		return this.length;
	}
	
	public inline function set(index: Int, value: FastFloat): FastFloat {
		return this[index] = value;
	}
	
	public inline function setVector2(index: Int, vector: FastVector2) {
		set(index +  0, vector.x);
		set(index +  1, vector.y);
	}
	
	public inline function setVector3(index: Int, vector: FastVector3) {
		set(index +  0, vector.x);
		set(index +  1, vector.y);
		set(index +  2, vector.z);
	}
	
	public inline function setVector4(index: Int, vector: FastVector4) {
		set(index +  0, vector.x);
		set(index +  1, vector.y);
		set(index +  2, vector.z);
		set(index +  3, vector.w);
	}
	
	public inline function setColor(index: Int, color: Color) {
		set(index +  0, color.R);
		set(index +  1, color.G);
		set(index +  2, color.B);
		set(index +  3, color.A);
	}
	
	public inline function setMatrix3(index: Int, matrix: FastMatrix3) {
		set(index +  0, matrix._00);
		set(index +  1, matrix._01);
		set(index +  2, matrix._02);
		
		set(index +  3, matrix._10);
		set(index +  4, matrix._11);
		set(index +  5, matrix._12);
		
		set(index +  6, matrix._20);				
		set(index +  7, matrix._21);				
		set(index +  8, matrix._22);
	}
	
	public inline function setMatrix4(index: Int, matrix: FastMatrix4) {
		set(index +  0, matrix._00);
		set(index +  1, matrix._01);
		set(index +  2, matrix._02);
		set(index +  3, matrix._03);
		
		set(index +  4, matrix._10);
		set(index +  5, matrix._11);
		set(index +  6, matrix._12);
		set(index +  7, matrix._13);
		
		set(index +  8, matrix._20);				
		set(index +  9, matrix._21);				
		set(index + 10, matrix._22);
		set(index + 11, matrix._23);
		
		set(index + 12, matrix._30);				
		set(index + 13, matrix._31);				
		set(index + 14, matrix._32);
		set(index + 15, matrix._33);
	}
	
	public inline function get(index: Int): FastFloat {
		return this[index];
	}
	
	public inline function data(): js.html.Float32Array {
		return this;
	}
}
