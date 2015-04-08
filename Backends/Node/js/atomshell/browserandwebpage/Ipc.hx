package js.atomshell.browserandwebpage;
import js.node.events.EventEmitter;

/**
 * @author AS3Boyan
 * MIT

 */
extern class Ipc implements npm.Package.Require<"ipc","*"> extends EventEmitter
{
	static function send(channel:String, ?args:Dynamic):Void;
	static function sendSync(channel:String, ?args:Dynamic):Void;
}

class IpcEvent
{
	inline public static var ASYNCHRONOUS_MESSAGE:String = "asynchronous-message";
	inline public static var SYNCHRONOUS_MESSAGE:String = "synchronous-message";
	inline public static var ASYNCHRONOUS_REPLY:String = "asynchronous-reply";
	inline public static var SYNCHRONOUS_REPLY:String = "synchronous-reply";
	
	public var returnValue:Dynamic;
	public var sender:Dynamic;
}