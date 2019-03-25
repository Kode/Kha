package kha.graphics4;

@:enum abstract StencilAction(Int) to Int {
	var Keep = 0;
	var Zero = 1;
	var Replace = 2;
	var Increment = 3;
	var IncrementWrap = 4;
	var Decrement = 5;
	var DecrementWrap = 6;
	var Invert = 7;
}
