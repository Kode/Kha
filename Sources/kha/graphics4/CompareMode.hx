package kha.graphics4;

@:enum abstract CompareMode(Int) to Int {
	var Always = 0;
	var Never = 1;
	var Equal = 2;
	var NotEqual = 3;
	var Less = 4;
	var LessEqual = 5;
	var Greater = 6;
	var GreaterEqual = 7;
}
