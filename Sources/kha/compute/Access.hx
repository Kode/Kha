package kha.compute;

enum abstract Access(Int) {
	var Read = 0;
	var Write = 1;
	var ReadWrite = 2;

	public inline function toInt():Int {
		return this;
	}
}
