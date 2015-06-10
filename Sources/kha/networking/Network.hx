package kha.networking;

import haxe.io.Bytes;

extern class Network {
	public function new(url: String, port: Int);
	public function send(bytes: Bytes, mandatory: Bool): Void;
	public function listen(listener: Bytes->Void): Void;
}
