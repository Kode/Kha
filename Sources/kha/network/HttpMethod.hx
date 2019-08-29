package kha.network;

enum abstract HttpMethod(Int) {
	var Get = 0;
	var Post = 1;
	var Put = 2;
	var Delete = 3;

	public inline function toInt():Int {
		return this;
	}
}
