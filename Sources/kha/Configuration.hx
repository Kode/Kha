package kha;

class Configuration {
	static var theScreen: Game;
	static var id: Int = -1;
	
	public static function screen(): Game {
		return theScreen;
	}
	
	public static function setScreen(screen: Game) {
		Scheduler.removeTimeTask(id);
		theScreen = screen;
		id = Scheduler.addTimeTask(function() { Configuration.theScreen.update(); }, 0, 1 / 60);
	}
}