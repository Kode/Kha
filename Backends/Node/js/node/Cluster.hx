package js.node;

typedef ClusterSettings = {
    var exec:String;
    var args:Array<String>;
    var silent:Bool;
    @:optional var execArgv: Array<String>;
}


/* emits: message, online,listening,disconnect,exit, setup */
extern class ClusterWorker extends js.node.events.EventEmitter {
    public static inline var EVENT_ONLINE = 'online';
    public static inline var EVENT_LISTENING =  'listening';
    public static inline var EVENT_EXIT = 'exit';
    public static inline var EVENT_DISCONNECT = 'disconnect';
    public static inline var EVENT_MESSAGE = 'message';
    public static inline var EVENT_ERROR = 'error';

    var id: String; // indexes into cluster.workers
    var process:js.node.ChildProcess;
    var suicide:Bool;
    function send(message:Dynamic,?sendHandle:Dynamic):Void;
    function destroy():Void;
    function disconnect(): Void;
}

/* Emits: death,message, fork, online, listening  */
extern class Cluster extends js.node.events.EventEmitter
implements npm.Package.Require<"cluster","*"> {
    public static inline var EVENT_FORK = 'fork';
    public static inline var EVENT_ONLINE = 'online';
    public static inline var EVENT_LISTENING =  'listening';
    public static inline var EVENT_EXIT = 'exit';
    public static inline var EVENT_DISCONNECT = 'disconnect';
    public static inline var EVENT_SETUP = 'setup';

    var isMaster:Bool;
    var isWorker:Bool;
    var worker: ClusterWorker;
    var workers:Array<ClusterWorker>;
    var settings: ClusterSettings;
    function fork(?env:Dynamic):ClusterWorker;
    function send(o:Dynamic):Void;
    function setupMaster(?settings:ClusterSettings):Void;
    function disconnect(?cb:Void->Void):Void;

    // Needed to use events on master Cluster
    public static var cluster : Cluster;
    static function __init__() : Void 
      cluster = untyped Cluster;
}