package kha;

class Configuration {
	static var theScreen: Game;
	static var id: Int = -1;
	
	public static function screen(): Game {
		return theScreen;
	}
	
	public static function setScreen(screen: Game) {
		theScreen = screen;
		//if (id >= 0) Scheduler.removeTimeTask(id);
		if (id < 0) id = Scheduler.addTimeTask(update, 0, 1 / 60);
	}
	
	private static function update(): Void {
		theScreen.update();
	}
}
