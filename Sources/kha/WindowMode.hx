package kha;

@:enum
abstract WindowMode(Int) {
	var Windowed = 0; // Use an ordinary window
	var Fullscreen = 1; // Regular fullscreen mode
	var ExclusiveFullscreen = 2; // Exclusive fullscreen mode (switches monitor resolution, Windows only)
}
