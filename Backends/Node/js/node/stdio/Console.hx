package js.node.stdio;

/* note:can't spec multiple optional args, so adding an arbitrary 3 */
typedef Console = {
  function log(s:Dynamic,?a1:Dynamic,?a2:Dynamic,?a3:Dynamic):Void;
  function info(s:Dynamic,?a1:Dynamic,?a2:Dynamic,?a3:Dynamic):Void;
  function warn(s:Dynamic,?a1:Dynamic,?a2:Dynamic,?a3:Dynamic):Void;
  function error(s:Dynamic,?a1:Dynamic,?a2:Dynamic,?a3:Dynamic):Void;
  function time(label:String):Void;
  function timeEnd(label:String):Void;
  function dir(obj:Dynamic):Void;
  function trace(label: String):Void;
  function assert(expression: Dynamic, ?message: String):Void;
}