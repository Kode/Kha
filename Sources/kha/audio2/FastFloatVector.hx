package kha.audio2;

import haxe.ds.Vector;

private typedef VectorData<T> = #if flash10
	flash.Vector<T>
#elseif neko
	neko.NativeArray<T>
#elseif cs
	cs.NativeArray<T>
#elseif java
	java.NativeArray<T>
#elseif lua
    lua.Table<Int,T>
#else
	Array<T>
#end

#if js
abstract FastFloatVector(js.html.Float32Array) {
	public inline function new(length : Int) {
		this = new js.html.Float32Array(length);
	}
	@:op([]) public inline function get(index:Int):FastFloat {
		return this[index];
	}
	@:op([]) public inline function set(index:Int, val:FastFloat):FastFloat {
		return this[index] = val;
	}
	public var length(get, never):Int;

	inline function get_length():Int {
		return this.length;
	}
	public static inline function blit<FastFloat>(src:FastFloatVector, srcPos:Int, dest:FastFloatVector, destPos:Int, len:Int):Void
	{
		Vector.blit(cast src, srcPos, cast dest, destPos, len);
	}
	public inline function toArray():Array<FastFloat> {
		return [for (n in this) n];
	}
	public inline function toData():js.html.Float32Array
		return this;
	static public inline function fromData(data:VectorData<FastFloat>):FastFloatVector
		return cast data;
	static public inline function fromArrayCopy(array:Array<FastFloat>):FastFloatVector {
		return cast Vector.fromArrayCopy(array);
	}
	public inline function copy():FastFloatVector {
		var r = new FastFloatVector(length);
		FastFloatVector.blit(cast this, 0, r, 0, length);
		return r;
	}
	// according to MDN these should be implemented on typed arrays, in fact
	/*
	public inline function join(sep:String):String {
		return this.join(sep);
	}
	public inline function map<S>(f:FastFloat->S):Vector<S> {
		return this.map(f);
	}
	public inline function sort(f:FastFloat->FastFloat->Int):Void {
		return this.sort(f);
	}
	*/

}
#else
abstract FastFloatVector(Vector<FastFloat>) {
	public inline function new(length : Int) {
		this = new Vector<FastFloat>(length);
	}
	@:op([]) public inline function get(index:Int):FastFloat {
		return this[index];
	}
	@:op([]) public inline function set(index:Int, val:FastFloat):FastFloat {
		return this[index] = val;
	}
	public var length(get, never):Int;

	inline function get_length():Int {
		return this.length;
	}
	public static inline function blit<FastFloat>(src:FastFloatVector, srcPos:Int, dest:FastFloatVector, destPos:Int, len:Int):Void
	{
		Vector.blit(cast src, srcPos, cast dest, destPos, len);
	}
	public inline function toArray():Array<FastFloat> {
		return this.toArray();
	}
	public inline function toData():Vector<FastFloat>
		return this;
	static public inline function fromData(data:VectorData<FastFloat>):FastFloatVector
		return cast data;
	static public inline function fromArrayCopy(array:Array<FastFloat>):FastFloatVector {
		return cast Vector.fromArrayCopy(array);
	}
	public inline function copy():FastFloatVector {
		var r = new FastFloatVector(length);
		FastFloatVector.blit(cast this, 0, r, 0, length);
		return r;
	}
	public inline function join(sep:String):String {
		return this.join(sep);
	}
	public inline function map<S>(f:FastFloat->S):Vector<S> {
		return this.map(f);
	}
	public inline function sort(f:FastFloat->FastFloat->Int):Void {
		return this.sort(f);
	}
	

}
#end
