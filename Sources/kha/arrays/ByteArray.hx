package kha.arrays;

/**
 * Maps a byte array over a byte buffer, allowing for mixed-type access of its contents.
 * This type unifies with all typed array classes, and vice-versa.
 */
extern class ByteArray
{
    /**
     * Underlying byte buffer.
     */
    var buffer(get, null):ByteBuffer;
    /**
     * Length in bytes of the byte array.
     */
    var byteLength(get, null):Int;
    /**
     * Byte offset into the underlying byte buffer.
     */
    var byteOffset(get, null):Int;
    
    /**
     * Creates a new array over a byte buffer.
     * @param buffer underlying byte buffer
     * @param byteOffset offset of the first byte of the array into the byte buffer, defaults to 0
     * @param byteLength amount of bytes to map, defaults to entire buffer 
     */
    function new(buffer:ByteArray, ?byteOffset:Int, ?byteLength:Int) : Void;

    /**
     * Creates a new array from scratch.
     * @param byteLength number of bytes to create
     * @return ByteArray
     */
    static function make(byteLength:Int) : ByteArray;

	function getInt8(byteOffset:Int):Int;
    function getUint8(byteOffset:Int):Int;
    function getInt16(byteOffset:Int, ?littleEndian:Bool):Int;
    function getUint16(byteOffset:Int, ?littleEndian:Bool):Int;
    function getInt32(byteOffset:Int, ?littleEndian:Bool):Int;
    function getUint32(byteOffset:Int, ?littleEndian:Bool):Int;
    function getFloat32(byteOffset:Int, ?littleEndian:Bool):FastFloat;
    function getFloat64(byteOffset:Int, ?littleEndian:Bool):Float;
	function setInt8(byteOffset:Int, value:Int):Void;
	function setUint8(byteOffset:Int, value:Int):Void;
	function setInt16(byteOffset:Int, value:Int, ?littleEndian:Bool):Void;
	function setUint16(byteOffset:Int, value:Int, ?littleEndian:Bool):Void;
	function setInt32(byteOffset:Int, value:Int, ?littleEndian:Bool):Void;
	function setUint32(byteOffset:Int, value:Int, ?littleEndian:Bool):Void;
	function setFloat32(byteOffset:Int, value:FastFloat, ?littleEndian:Bool):Void;
	function setFloat64(byteOffset:Int, value:Float, ?littleEndian:Bool):Void;

    function subarray(start:Int, ?end:Int) : ByteArray;
}