package js.npm;

import js.node.events.EventEmitter;

typedef MongSocketIoConfig = {
   ?collectionPrefix: String // collection name is prefix + name
  ,?streamCollection: String    // capped collection name
  ,?storageCollection: String   // collection name used for key/value storage
  ,?nodeId: String // id that uniquely identifies this node
  ,?size: Int // max size in bytes for capped collection
  ,?num: Int  // max number of documents inside of capped collection
  ,?url: String  // db url e.g. "mongodb://localhost:27017/yourdb"
  ,?host: String  // optionally you can pass everything separately
  ,?port: Int
  ,?db: String
}

extern class MongSocketIo
implements npm.Package.Require<"mong.socket.io","*">
extends EventEmitter {
	public function new( conf : MongSocketIoConfig ) : Void;
}