package js.node;

@:native("Buffer") 
extern class Buffer 
implements ArrayAccess<Int> 
{

   @:overload(function(str:String,?enc:String):Void {})
   @:overload(function(arr:Array<Int>):Void {})
  function new(size:Int):Void;

  var length(default,null) : Int;
  var INSPECT_MAX_BYTES:Int;
  
  function copy(targetBuffer:Buffer,targetStart:Int,sourceStart:Int,sourceEnd:Int):Void;
  function slice(start:Int,end:Int):Buffer;
  function write(s:String,?offset:Int,?length:Int,?enc:String):Int;
  function toString(?enc:String,?start:Int,?end:Int):String;
  function fill(value:Float,offset:Int,?end:Int):Void;
  static function isBuffer(o:Dynamic):Bool;
  static function byteLength(s:String,?enc:String):Int;

  function readUInt8(offset:Int,?noAssert:Bool):Int;
  function readUInt16LE(offset:Int,?noAssert:Bool):Int;
  function readUInt16BE(offset:Int,?noAssert:Bool):Int;
  function readUInt32LE(offset:Int,?noAssert:Bool):Int;
  function readUInt32BE(offset:Int,?noAssert:Bool):Int;

  function readInt8(offset:Int,?noAssert:Bool):Int;
  function readInt16LE(offset:Int,?noAssert:Bool):Int;
  function readInt16BE(offset:Int,?noAssert:Bool):Int;
  function readInt32LE(offset:Int,?noAssert:Bool):Int;
  function readInt32BE(offset:Int,?noAssert:Bool):Int;

  function readFloatLE(offset:Int,?noAssert:Bool):Float;
  function readFloatBE(offset:Int,?noAssert:Bool):Float;
  function readDoubleLE(offset:Int,?noAssert:Bool):Float; // is this right?
  function readDoubleBE(offset:Int,?noAssert:Bool):Float; // is this right?

  function writeUInt8(value:Int,offset:Int,?noAssert:Bool):Void;
  function writeUInt16LE(value:Int,offset:Int,?noAssert:Bool):Void;
  function writeUInt16BE(value:Int,offset:Int,?noAssert:Bool):Void;
  function writeUInt32LE(value:Int,offset:Int,?noAssert:Bool):Void;
  function writeUInt32BE(value:Int,offset:Int,?noAssert:Bool):Void;

  function writeInt8(value:Int,offset:Int,?noAssert:Bool):Void;
  function writeInt16LE(value:Int,offset:Int,?noAssert:Bool):Void;
  function writeInt16BE(value:Int,offset:Int,?noAssert:Bool):Void;
  function writeInt32LE(value:Int,offset:Int,?noAssert:Bool):Void;
  function writeInt32BE(value:Int,offset:Int,?noAssert:Bool):Void;

  function writeFloatLE(value:Float,offset:Int,?noAssert:Bool):Void;
  function writeFloatBE(value:Float,offset:Int,?noAssert:Bool):Void;
  function writeDoubleLE(value:Float,offset:Int,?noAssert:Bool):Void; // is this right?
  function writeDoubleBE(value:Float,offset:Int,?noAssert:Bool):Void; // is this right?

}
