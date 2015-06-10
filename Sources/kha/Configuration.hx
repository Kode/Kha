package kha;

/**
 * This class handles updating the game instance.
 */
class Configuration {
	/**
	 * The game instance.
	 */
	static var theScreen: Game;
	/**
	 * ID of the time task.
	 */
	static var id: Int = -1;

	/**
	 * Return the game instance.
	 */
	public static inline function screen(): Game {
		return theScreen;
	}

	/**
	 * Call this to let the system know the scheduler has been initialized.
	 */
	@:allow(kha.Scheduler) 
	private static function schedulerInitialized() {
		id = -1;
	}

	/**
	 * Set the game instance.
	 */
	public static function setScreen(screen: Game) {
		theScreen = screen;
		theScreen.setInstance();
		if (id < 0) {
			id = Scheduler.addTimeTask(update, 0, 1 / 60);
		}
	}

	/**
	 * Update the game.
	 */
	private static function update() {
		theScreen.update();
	}
}
