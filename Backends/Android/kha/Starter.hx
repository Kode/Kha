package kha;

import kha.Game;
import kha.Key;

class Starter {
	//static var instance : Starter;
	//static var game : Game;
	//static var painter : kha.android.Painter;
	
	public function new() {
		//instance = this;
		//kha.Loader.init(new kha.android.Loader());
	}
	
	public function start(game : Game) {
		//Starter.game = game;
		//Loader.getInstance().load();
	}
	
	public static function loadFinished() {
		//game.loadFinished();
	}
	
	public static var mouseX: Int;
	public static var mouseY: Int;
}