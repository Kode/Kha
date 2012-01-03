package com.ktxsoftware.sml;

import com.ktxsoftware.kje.Image;
import com.ktxsoftware.kje.Loader;
import com.ktxsoftware.kje.Scene;
import com.ktxsoftware.kje.Sound;
import com.ktxsoftware.kje.Sprite;

class Coin extends Sprite {
	private static var image : Image;
	private static var sound : Sound;
	static var initialized = false;
	
	static function init() {
		if (!initialized) {
			image = Loader.getInstance().getImage("coin.png");
			sound = Loader.getInstance().getSound("coin");
			initialized = true;
		}
	}
	
	public function new(x : Int, y : Int) {
		init();
		super(Coin.image, 28, 32, 0);
		this.x = x;
		this.y = y;
		accy = 0;
	}
	
	public override function hit(sprite : Sprite) {
		sound.play();
		Scene.getInstance().removeEnemy(this);
		Jumpman.getInstance().selectCoin();
	}
}