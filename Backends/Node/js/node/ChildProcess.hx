package js.node;

import js.node.net.*;
import js.node.stream.*;
import js.node.stream.Writable;
import js.node.stream.Readable;

/*
  Emits: message
*/
extern class ChildForkProcess extends ChildProcess {
     @:overload(function(o:Dynamic,?socket:Socket):Void {})
     function send(o:Dynamic,?server:Server):Void;  
}

/*
  Emits: exit,close
*/
extern class ChildProcess
extends js.node.events.EventEmitter
implements npm.Package.Require<"child_process","*"> { 

  public static inline var EVENT_EXIT = "exit";
  public static inline var EVENT_ERROR = "error";
  public static inline var EVENT_CLOSE = "close";
  public static inline var EVENT_DISCONNECT = "disconnect";
  public static inline var EVENT_MESSAGE = "message";

	var stdin:IWritable;
  var stdout:IReadable;
  var stderr:IReadable;
  var pid:Int;
  var connected: Bool;
  
  function kill(?signal:String):Void;
  function disconnect(): Void;

	static function spawn(command: String,args: Array<String>,?options: Dynamic ) : ChildProcess;
	static function exec(command: String,?options:Dynamic,cb: {code:Int}->String->String->Void ): ChildProcess;
	static function execFile(command: String,?options:Dynamic,cb: {code:Int}->String->String->Void ): ChildProcess;
	static function fork(path:String,?args:Dynamic,?options:Dynamic):ChildForkProcess;

}