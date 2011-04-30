package com.kontechs.kje;

public class Sprite {
	private Image image;
	private Animation animation;
	protected Rectangle collider;
	
	public Sprite(Image image, int width, int height) {
		this.image = image;
		this.width = width;
		this.height = height;
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
		if (image != null) painter.drawImage(image, animation.get() * width % image.getWidth(), animation.get() * width / image.getWidth() * height, width, height, x - collider.x, y - collider.y, width, height);
	}
	
	public void hit(Direction dir) {
		
	}
	
	public void hit(Sprite sprite) {
		
	}
	
	public int x, y, width, height;
	public float speedx, speedy;
	public float accx, accy;
	public float maxspeedy = 5.0f;
	public boolean collides = true;
}