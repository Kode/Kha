package com.ktxsoftware.sml;

import com.ktxsoftware.kje.Scene;
import com.ktxsoftware.kje.Sprite;

class Exit extends Sprite {
	public function new(x : Int, y : Int) {
		super(null, 32, 32, 0);
		this.x = x;
		this.y = y;
		accy = 0;
	}
	
	public override function hit(sprite : Sprite) {
		Scene.getInstance().removeEnemy(this);
		Jumpman.getInstance().nextRound();
		SuperMarioLand.getInstance().startGame();
	}
}