package kha.compute;

enum abstract Access(Int) to Int {
	var Read = 0;
	var Write = 1;
	var ReadWrite = 2;
}
