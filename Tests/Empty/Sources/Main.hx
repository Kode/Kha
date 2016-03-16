package;

import kha.Scheduler;
import kha.System;

class Main {
	public static function main() {
		System.init({title: "Empty", width: 640, height: 480}, init);
	}
	
	private static function init(): Void {
		var game = new Empty();
		System.notifyOnRender(game.render);
		Scheduler.addTimeTask(game.update, 0, 1 / 60);
	}
}
