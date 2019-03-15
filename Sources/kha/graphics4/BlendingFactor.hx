package kha.graphics4;

@:enum abstract BlendingFactor(Int) to Int {
	var Undefined = 0;
	var BlendOne = 1;
	var BlendZero = 2;
	var SourceAlpha = 3;
	var DestinationAlpha = 4;
	var InverseSourceAlpha = 5;
	var InverseDestinationAlpha = 6;
	var SourceColor = 7;
	var DestinationColor = 8;
	var InverseSourceColor = 9;
	var InverseDestinationColor = 10;
}
