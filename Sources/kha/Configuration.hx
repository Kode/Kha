package kha;

class Configuration {
	static var theScreen: Game;
	static var id: Int = -1;
	
	public static inline function screen(): Game {
		return theScreen;
	}
	
	@:allow(kha.Scheduler) 
	private static function schedulerInitialized() {
		id = -1;
	}
	
	public static function setScreen(screen: Game) {
		theScreen = screen;
		if (id < 0) {
			id = Scheduler.addTimeTask(update, 0, 1 / 60);
		}
	}
	
	private static function update() {
		theScreen.update();
	}
}
