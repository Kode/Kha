package js.npm;

import js.node.events.EventEmitter;

typedef SocketIoMongoConfig = {
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

extern class SocketIoMongo 
implements npm.Package.Require<"socket.io-mongo","*">
extends EventEmitter {
	public function new( options : SocketIoMongoConfig ) : Void;
}