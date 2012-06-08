package kha.xna;

import kha.Image;

@:classContents('
	public Microsoft.Xna.Framework.Graphics.SpriteBatch spriteBatch;
')
class Painter extends kha.Painter {
	var tx : Float;
	var ty : Float;
	
	public function new() {
		tx = 0;
		ty = 0;
	}

	@:functionBody('
		spriteBatch.Begin();
	')
	override public function begin() : Void {
		
	}
	
	@:functionBody('
		spriteBatch.End();
	')
	override public function end() : Void {
		
	}
	
	override public function translate(x : Float, y : Float) {
		tx = x;
		ty = y;
	}
	
	@:functionBody('
		spriteBatch.Draw(((kha.xna.Image)img).texture, new Microsoft.Xna.Framework.Vector2((float)(x + tx), (float)(ty + y)), Microsoft.Xna.Framework.Color.White); 
	')
	override public function drawImage(img : Image, x : Float, y : Float) : Void {
	
	}
	
	@:functionBody('
		spriteBatch.Draw(((kha.xna.Image)image).texture, new Microsoft.Xna.Framework.Rectangle((int)(tx + dx), (int)(ty + dy), (int)dw, (int)dh), new Microsoft.Xna.Framework.Rectangle((int)sx, (int)sy, (int)sw, (int)sh), Microsoft.Xna.Framework.Color.White);
	')
	override public function drawImage2(image : Image, sx : Float, sy : Float, sw : Float, sh : Float, dx : Float, dy : Float, dw : Float, dh : Float) : Void {
		
	}
}