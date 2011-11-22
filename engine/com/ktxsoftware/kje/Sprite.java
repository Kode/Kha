package com.ktxsoftware.kje;

public class Sprite {
	protected Image image;
	protected Animation animation;
	protected Rectangle collider;
	
	public double x, y, width, height;
	public double speedx, speedy;
	public double accx, accy;
	public double maxspeedy = 5.0f;
	public boolean collides = true;
	public int z;
	
	public Sprite(Image image, int width, int height, int z) {
		this.image = image;
		this.width = width;
		this.height = height;
		this.z = z;
		collider = new Rectangle(0, 0, width, height);
		speedx = speedy = 0;
		accx = 0;
		accy = 0.2f;
		animation = new Animation(0);
	}
	
	private Rectangle tempcollider = new Rectangle(0, 0, 0, 0);
	
	public Rectangle collisionRect() {
		tempcollider.x = x;
		tempcollider.y = y;
		tempcollider.width = collider.width;
		tempcollider.height = collider.height;
		return tempcollider;
	}
	
	public void setAnimation(Animation animation) {
		this.animation = animation;
	}
	
	public void update() {
		animation.next();
	}
	
	public void render(Painter painter) {
		if (image != null)
			painter.drawImage(image, animation.get() * width % image.getWidth(), Math.floor(animation.get() * width / image.getWidth()) * height, width, height, Math.round(x - collider.x), Math.round(y - collider.y), width, height);
	}
	
	public void hit(Direction dir) {
		
	}
	
	public void hit(Sprite sprite) {
		
	}
	
	public void setImage(Image image) {
		this.image = image;
	}
	
	public void outOfView() {
		
	}
}