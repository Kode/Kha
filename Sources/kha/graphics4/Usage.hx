package kha.graphics4;

@:enum abstract Usage(Int) to Int {
	var StaticUsage = 0;
	var DynamicUsage = 1; // Just calling it Dynamic causes problems in C++
	var ReadableUsage = 2;
}
