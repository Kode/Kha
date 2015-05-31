package js.node.stream;

import js.node.events.EventEmitter;
import js.node.stream.Writable;
import js.node.stream.Readable;

extern class Duplex 
implements IDuplex
extends EventEmitter
implements npm.Package.RequireNamespace<"stream","*"> 
{
	
	var readable:Bool;
	function pause():Void;
	function resume():Void;
	function destroy():Void;
	function destroySoon():Void;
	function setEncoding(enc:String):Void;
	function pipe(dest:IWritable,?opts:{end:Bool}):Void;

	var writeable:Bool;
	@:overload(function(chunk:Buffer):Bool {})
	function write(d:String,?enc:String,?fd:Int):Bool;
	@:overload(function(b:Buffer):Void {})
	function end(?s:String,?enc:String):Void;

	function new(?opt:Dynamic):Void;

}

interface IDuplex
extends IWritable
extends IReadable
{
	var readable:Bool;
	function pause():Void;
	function resume():Void;
	function destroy():Void;
	function destroySoon():Void;
	function setEncoding(enc:String):Void;
	function pipe(dest:IWritable,?opts:{end:Bool}):Void;

	var writeable:Bool;
	@:overload(function(chunk:Buffer):Bool {})
	function write(d:String,?enc:String,?fd:Int):Bool;
	@:overload(function(b:Buffer):Void {})
	function end(?s:String,?enc:String):Void;
}