package js.node.stream;

import js.node.Buffer;
import js.node.events.EventEmitter;

/* 
   Emits:
   drain,error,close,pipe
*/
extern class Writable
implements IWritable
extends EventEmitter
implements npm.Package.RequireNamespace<"stream","*">
{

  public static inline var EVENT_DRAIN = "drain";
  public static inline var EVENT_ERROR = "error";
  public static inline var EVENT_CLOSE = "close";
  public static inline var EVENT_FINISH = "finish";
  public static inline var EVENT_PIPE = "pipe";
  public static inline var EVENT_UNPIPE = "unpipe";

  var writeable:Bool;
  @:overload(function(chunk:Buffer):Bool {})
  function write(d:String,?enc:String,?fd:Int):Bool;
  @:overload(function(b:Buffer):Void {})
  function end(?s:String,?enc:String):Void;
  function destroy():Void;
  function destroySoon():Void;
  function new(?opt:Dynamic):Void;
  
}

extern interface IWritable 
extends IEventEmitter {

  var writeable:Bool;
  @:overload(function(chunk:Buffer):Bool {})
  function write(d:String,?enc:String,?fd:Int):Bool;
  @:overload(function(b:Buffer):Void {})
  function end(?s:String,?enc:String):Void;
  function destroy():Void;
  function destroySoon():Void;

}
