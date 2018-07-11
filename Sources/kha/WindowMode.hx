package kha;

@:enum
abstract WindowMode(Int) {
	var Window = 0;              // Window with borders
	var Fullscreen = 1;          // Window without borders
	var ExclusiveFullscreen = 2; // Exclusive fullscreen mode (switches monitor resolution, Windows only)
}
