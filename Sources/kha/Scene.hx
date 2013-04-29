package kha;

class Scene {
	private static var instance : Scene;
	
	var collisionLayer: CollisionLayer;
	var backgrounds : Array<Tilemap>;
	var foregrounds : Array<Tilemap>;
	var backgroundSpeeds : Array<Float>;
	var foregroundSpeeds : Array<Float>;
	//var lastUpdatedSprites : Array<Sprite>;
	//var updatedSprites : Array<Sprite>;
	
	var sprites : Array<Sprite>;
	
	var backgroundColor : Color;
	
	public var camx : Int;
	public var camy : Int;
	
	public static var the(get, null): Scene;
	
	private static function get_the(): Scene {
		if (instance == null) instance = new Scene();
		return instance;
	}
	
	function new() {
		sprites = new Array<Sprite>();
		backgrounds = new Array<Tilemap>();
		foregrounds = new Array<Tilemap>();
		backgroundSpeeds = new Array<Float>();
		foregroundSpeeds = new Array<Float>();
		//lastUpdatedSprites = new Array<Sprite>();
		//updatedSprites = new Array<Sprite>();
		backgroundColor = new Color(0, 0, 0);
		camx = 0;
		camy = 0;
	}
	
	public function clear() {
		collisionLayer = null;
		clearTilemaps();
		sprites = new Array<Sprite>();
	}
	
	public function clearTilemaps() {
		backgrounds = new Array<Tilemap>();
		foregrounds = new Array<Tilemap>();
		backgroundSpeeds = new Array<Float>();
		foregroundSpeeds = new Array<Float>();
	}
	
	public function setBackgroundColor(color : Color) {
		backgroundColor = color;
	}

	public function addBackgroundTilemap(tilemap : Tilemap, speed : Float) {
		backgrounds.push(tilemap);
		backgroundSpeeds.push(speed);
	}
	
	public function addForegroundTilemap(tilemap : Tilemap, speed : Float) {
		foregrounds.push(tilemap);
		foregroundSpeeds.push(speed);
	}
	
	public function setColissionMap(tilemap: Tilemap) {
		collisionLayer = new CollisionLayer(tilemap);
	}
	
	public function addHero(sprite: Sprite) {
		if (collisionLayer != null) collisionLayer.addHero(sprite);
		sprites.push(sprite);
	}
	
	public function addEnemy(sprite: Sprite) {
		if (collisionLayer != null) collisionLayer.addEnemy(sprite);
		sprites.push(sprite);
	}
	
	public function addProjectile(sprite: Sprite) {
		if (collisionLayer != null) collisionLayer.addProjectile(sprite);
		sprites.push(sprite);
	}
	
	public function removeEnemy(sprite: Sprite) {
		if (collisionLayer != null) collisionLayer.removeEnemy(sprite);
		sprites.remove(sprite);
	}
	
	public function removeHero(sprite: Sprite) {
		if (collisionLayer != null) collisionLayer.removeHero(sprite);
		sprites.remove(sprite);
	}
	
	public function removeProjectile(sprite: Sprite) {
		if (collisionLayer != null) collisionLayer.removeProjectile(sprite);
		sprites.remove(sprite);
	}
	
	function adjustCamX(): Int {
		if (collisionLayer != null) {
			var realcamx: Int = Std.int(Math.min(Math.max(0, camx - Game.the.width / 2), collisionLayer.getMap().getWidth() * collisionLayer.getMap().getTileset().TILE_WIDTH - Game.the.width));
			if (getWidth() < Game.the.width) realcamx = 0;
			return realcamx;
		}
		else return camx;
	}
	
	function adjustCamY(): Int {
		if (collisionLayer != null) {
			var realcamy: Int = Std.int(Math.min(Math.max(0, camy - Game.the.height / 2), collisionLayer.getMap().getHeight() * collisionLayer.getMap().getTileset().TILE_HEIGHT - Game.the.height));
			if (getHeight() < Game.the.height) realcamy = 0;
			return realcamy;
		}
		else return camy;
	}
	
	function sort(sprites : Array<Sprite>) {
		if (sprites.length == 0) return;
		sprites.sort(function(arg0: Sprite, arg1: Sprite) {
			if (arg0.x < arg1.x) return -1;
			else if (arg0.x == arg1.x) return 0;
			else return 1;
		});
	}
	
	public function update(): Void {
		if (collisionLayer != null) {
			var camx: Int = adjustCamX();
			collisionLayer.advance(camx, camx + Game.the.width);
		}
		for (sprite in sprites) sprite.update();
	}

	public function render(painter: Painter) {
		painter.translate(0, 0);
		//painter.setColor(backgroundColor.r, backgroundColor.g, backgroundColor.b);
		//painter.clear();
		
		var camx: Int = adjustCamX();
		var camy: Int = adjustCamY();
		
		for (i in 0...backgrounds.length) {
			painter.translate(Math.round(-camx * backgroundSpeeds[i]), Math.round(-camy * backgroundSpeeds[i]));
			backgrounds[i].render(painter, Std.int(camx * backgroundSpeeds[i]), Std.int(camy * backgroundSpeeds[i]), Game.the.width, Game.the.height);
		}
		
		painter.translate( -camx, -camy);
		
		sort(sprites);
		
		for (z in 0...10) {
			var i : Int = 0;
			while (i < sprites.length) {
				if (sprites[i].x + sprites[i].width > camx) break;
				++i;
			}
			while (i < sprites.length) {
				if (sprites[i].x > camx + Game.the.width) break;
				if (i < sprites.length && sprites[i].z == z) sprites[i].render(painter);
				++i;
			}
		}
		
		for (i in 0...foregrounds.length) {
			painter.translate(Math.round(-camx * foregroundSpeeds[i]), Math.round(-camy * foregroundSpeeds[i]));
			foregrounds[i].render(painter, Std.int(camx * foregroundSpeeds[i]), Std.int(camy * foregroundSpeeds[i]), Game.the.width, Game.the.height);
		}
	}
	
	public function getWidth() : Float {
		if (collisionLayer != null) return collisionLayer.getMap().getWidth() * collisionLayer.getMap().getTileset().TILE_WIDTH;
		else return 0;
	}
	
	public function getHeight() : Float {
		if (collisionLayer != null) return collisionLayer.getMap().getHeight() * collisionLayer.getMap().getTileset().TILE_HEIGHT;
		else return 0;
	}
}