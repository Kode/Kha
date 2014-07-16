package kha;

@:allow(kha.Starter)
class Canvas {
	public var width(default, null): Int;
	public var height(default, null): Int;
	public var g2(default, null): kha.graphics2.Graphics;
}
