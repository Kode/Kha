package js.npm;

import js.npm.socketIo.Namespace;

extern class SocketIoSession 
implements npm.Package.Require<"socket.io-session","*"> {
	
	public function new( cookieParser : js.npm.connect.Middleware , store : js.npm.connect.session.Store ) : Void;

	public static inline function session( namespace : Namespace ) : Dynamic {
		return untyped (namespace.handshake == null) ? null : namespace.handshake.session;
	}

}