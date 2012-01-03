package com.ktxsoftware.sml;

import com.ktxsoftware.kje.Image;
import com.ktxsoftware.kje.Loader;
import com.ktxsoftware.kje.Scene;
import com.ktxsoftware.kje.Sound;
import com.ktxsoftware.kje.Sprite;

class Coin extends Sprite {
	private static var image : Image = Loader.getInstance().getImage("coin.png");
	private static var sound : Sound = Loader.getInstance().getSound("coin");
	
	public function new(x : Int, y : Int) {
		super(image, 28, 32, 0);
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