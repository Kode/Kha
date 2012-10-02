package kha;

class System {
	static var theScreen: Game;
	
	public static function screen(): Game {
		return theScreen;
	}
	
	public static function setScreen(screen: Game) {
		theScreen = screen;
	}
}