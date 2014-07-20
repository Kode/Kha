package kha;

@:allow(kha.Starter)
interface Canvas {
	var width(get, null): Int;
	var height(get, null): Int;
	var g2(get, null): kha.graphics2.Graphics;
	var g4(get, null): kha.graphics4.Graphics;
}
