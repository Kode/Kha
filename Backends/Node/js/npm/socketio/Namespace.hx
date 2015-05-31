package js.npm.socketio;

extern
class Namespace {

	public var id : String;
  public var handshake (default,null) : HandshakeData; 
  public var broadcast (default,null) : Namespace;

//  public static function SocketNamespace (socket : Dynamic, name : String) : Void;
  public function send(data : Dynamic, fn : Dynamic) : Namespace;
  public function disconnect () : Namespace;

  // from js.Node.NodeEventEmitter
  public function addListener(event:String,fn:Listener):Dynamic;
  public function on(event:String,fn:Listener):Dynamic;
  public function once(event:String,fn:Listener):Void;
  public function removeListener(event:String,listener:Listener):Void;
  public function removeAllListeners(event:String):Void;
  public function listeners(event:String):Array<Listener>;
  public function setMaxListeners(m:Int):Void;

	@:overload(function(name : String) : Namespace{ } )
  public function emit(event:String,?arg1:Dynamic,?arg2:Dynamic,?arg3:Dynamic):Void;

  public function join(room:String):Void;
  public function leave(room:String):Void;

  /*@:native("in")*/
  public inline function in_(room:String):Namespace return untyped this["in"](room);
  

  public function clients(room:String):Array<Namespace>;

  public function set<T>( key : String , value : T , ?cb : Void -> Void ) : Void;
  public function get<T>( key : String , cb : Null<String> -> T -> Void ) : Void;

  public function socket( id : String ) : Namespace;

}
