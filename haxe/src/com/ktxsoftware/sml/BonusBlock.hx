package com.ktxsoftware.sml;

import com.ktxsoftware.kje.Animation;
import com.ktxsoftware.kje.Image;
import com.ktxsoftware.kje.Loader;
import com.ktxsoftware.kje.Rectangle;
import com.ktxsoftware.kje.Scene;
import com.ktxsoftware.kje.Sound;
import com.ktxsoftware.kje.Sprite;

class BonusBlock extends Sprite {
	static var image : Image = Loader.getInstance().getImage("bonusblock.png");
	static var sound : Sound = Loader.getInstance().getSound("coin");
	var downcount : Int;
	var washit : Bool;
	static var onehit : Bool = false;
	
	public function new(x : Float, y : Float) {
		super(image, Std.int(image.getWidth() / 2), image.getHeight(), 0);
		this.x = x;
		this.y = y;
		accy = 0;
		washit = false;
		downcount = 0;
		collider = new Rectangle(0, 0, image.getWidth() / 2, image.getHeight() + 14);
	}
	
	public override function update() {
		if (downcount > 0) {
			--downcount;
			if (downcount == 0) {
				y += 20;
				onehit = false;
			}
		}
	}
	
	public override function hit(sprite : Sprite) {
		if (!washit && !onehit && downcount == 0 && sprite.speedy < 0) {
			sound.play();
			y -= 20;
			downcount = 8;
			onehit = true;
			washit = true;
			Scene.getInstance().addEnemy(new BlockCoin(x + width / 2, y));
			setAnimation(Animation.create(1));
			Jumpman.getInstance().selectCoin();
		}
	}
}