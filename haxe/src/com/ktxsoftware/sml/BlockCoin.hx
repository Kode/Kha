package com.ktxsoftware.sml;

import com.ktxsoftware.kje.Image;
import com.ktxsoftware.kje.Loader;
import com.ktxsoftware.kje.Scene;
import com.ktxsoftware.kje.Sprite;

class BlockCoin extends Sprite {
	static var image : Image = Loader.getInstance().getImage("blockcoin.png");
	var count : Int;
	
	public function new(x : Float, y : Float) {
		super(image, image.getWidth(), image.getHeight(), 0);
		accy = 0;
		speedy = -2;
		collides = false;
		this.x = x - width / 2;
		this.y = y;
		count = 20;
	}
	
	public override function update() {
		--count;
		if (count == 0) Scene.getInstance().removeEnemy(this);
	}
}