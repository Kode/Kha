package kha.network;

import haxe.io.Bytes;

extern class Network {
	public function new(url: String, port: Int, errorCallback: Void->Void, closeCallback: Void->Void);
	public function send(bytes: Bytes, mandatory: Bool): Void;
	public function listen(listener: Bytes->Void): Void;
}
