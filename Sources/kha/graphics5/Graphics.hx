package kha.graphics5;

interface Graphics {
	function renderTargetsInvertedY(): Bool;
	function begin(target:RenderTarget): Void;
	function end(): Void;
	function swapBuffers(): Void;
}
