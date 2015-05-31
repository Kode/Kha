package js.node;

import js.node.events.EventEmitter;
import js.node.stream.Readable;
import js.node.stream.Writable;

/* 
  Emits:
  exit, uncaughtException + SIGNAL events (SIGINT etc)
 */
extern class Process extends EventEmitter {

  public static inline var EVENT_EXIT = "exit";
  public static inline var EVENT_UNCAUGHTEXCEPTION = "uncaughtException";
  public static inline var EVENT_SIGINT = "SIGINT";
  public static inline var EVENT_SIGUSR1 = "SIGUSR1";

  var stdout:IWritable;
  var stdin:IReadable;
  var stderr:IWritable;
  var argv:Array<String>;
  var env:Dynamic;
  var pid:Int;
  var title:String;
  var arch:String;
  var platform:String;
  var installPrefix:String;
  var execPath:String;
  var version:String;
  var versions:Dynamic;
  
  function memoryUsage():{rss:Int,vsize:Int,heapUsed:Int,heapTotal:Int};
  function nextTick(fn:Void->Void):Void;
  function exit(code:Int):Void;
  function cwd():String;
  function getuid():Int;
  function getgid():Int;
  function setuid(u:Int):Void;
  function setgid(g:Int):Void;
  function umask(?m:Int):Int;
  function chdir(d:String):Void;
  function kill(pid:Int,?signal:String):Void;
  function uptime():Int;
  function abort():Void;
  function hrtime():Array<Int>;
}
