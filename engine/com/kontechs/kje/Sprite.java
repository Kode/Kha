package com.kontechs.kje;

public class Sprite {
	private Image image;
	private Animation animation;
	protected Rectangle collider;
	protected int z_order = 0;
	
	public Sprite(Image image, int width, int height, int z_order) {
		this.z_order = z_order;
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
		
		//TODO: Research
		//correct the x coordinate with the unique collider rectangle of the beaver and excavator
		//if(this instanceof Beaver) {
		//	Beaver beaver = (Beaver) this;
		//	tempcollider.x = beaver.lookRight ? beaver.x+beaver.collider.x : beaver.x;
		//}
		//else {
			tempcollider.x = x;
		//}
		
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
		if (image != null) {
			painter.drawImage(image, animation.get() * width % image.getWidth(), animation.get() * width / image.getWidth() * height, width, height, x - collider.x, y - collider.y, width, height);
			if(Scene.getInstance().isCooliderDebugMode()){
				painter.setColor(255, 0, 0);
				painter.drawRect(x + collider.x, y + collider.y, collider.width, collider.height);
			}
		}
	}
	
	public void hit(Direction dir) {
		
	}
	
	public void hit(Sprite sprite) {
		
	}

	//TODO: W00t?
	public boolean collidedown(Sprite sprite) {
		sprite.y = y +32;
		return true;
	}
	
	//TODO: W00t?
	public boolean collidetop(Sprite sprite){
		sprite.y= y -64;
		return true;
	}
	
	public int getZ_order() {
		return z_order;
	}

	public void setZ_order(int z_order) {
		this.z_order = z_order;
	}
	
	public void setImage(Image image) {
		this.image = image;
	}
	
	public int x, y, width, height;
	public float speedx, speedy;
	public float accx, accy;
	public float maxspeedy = 5.0f;
	public boolean collides = true;
}