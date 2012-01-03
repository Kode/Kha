package com.ktxsoftware.sml;

import com.ktxsoftware.kje.Animation;
import com.ktxsoftware.kje.Direction;
import com.ktxsoftware.kje.Image;
import com.ktxsoftware.kje.Loader;
import com.ktxsoftware.kje.Rectangle;
import com.ktxsoftware.kje.Scene;
import com.ktxsoftware.kje.Sprite;

class Koopa extends Enemy {
	static var image : Image;
	var killcount : Int;
	var leftAnim : Animation;
	var rightAnim : Animation;
	static var initialized = false;
	
	static function init() {
		if (!initialized) {
			image = Loader.getInstance().getImage("koopa.png");
			initialized = true;
		}
	}
	
	public function new(x : Int, y : Int) {
		init();
		super(Koopa.image, 16 * 4, 48);
		this.x = x;
		this.y = y;
		leftAnim = new Animation([0, 1], 10);
		rightAnim = new Animation([2, 3], 10);
		setAnimation(leftAnim);
		speedx = -1 * Math.round(Math.pow(1.2, Jumpman.getInstance().getRound()));
		collider = new Rectangle(0, 16, 16 * 4, 48 - 16);
		killcount = -1;
	}
	
	public override function update() {
		if (killcount > 0) {
			--killcount;
			if (killcount == 0) Scene.getInstance().removeEnemy(this);
		}
		super.update();
	}

	public override function kill() {
		super.kill();
		speedx = 0;
		var anim = [4, 5, 4, 5, 4, 5, 4, 5, 6, 7];
		setAnimation(new Animation(anim, 14));
		killcount = anim.length * 14;
	}
	
	public override function hit(sprite : Sprite){
		if(killcount > 0 && killcount < 2 * 14){
			Jumpman.getInstance().die();
		}
		else{
			super.hit(sprite);
		}
	}
	
	public override function hitFrom(dir : Direction) {
		if (dir == Direction.LEFT) {
			setAnimation(leftAnim);
			speedx = -1 * Math.round(Math.pow(1.2, Jumpman.getInstance().getRound()));
		}
		else if (dir == Direction.RIGHT) {
			setAnimation(rightAnim);
			speedx = 1 * Math.round(Math.pow(1.2, Jumpman.getInstance().getRound()));
		}
	}
}