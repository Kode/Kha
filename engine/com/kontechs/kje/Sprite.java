package com.kontechs.kje;

import de.hsharz.beaver.Beaver; //TODO: Remove

public class Sprite {
	private Image image;
	private Image imageWinter; //TODO: Remove
	private Image imageSummer; //TODO: Remove
	private Animation animation;
	protected Rectangle collider;
	public String name; //TODO: Remove
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
	
	public Sprite(Image imageSummer, Image imageWinter, int width, int height,int z_order) {
		this.z_order = z_order;
		this.imageSummer = imageSummer;
		this.imageWinter = imageWinter;
		this.image = imageSummer;
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
		
		//TODO: Generalize
		//correct the x coordinate with the unique collider rectangle of the beaver and excavator
		if(this instanceof Beaver) {
			Beaver beaver = (Beaver) this;
			tempcollider.x = beaver.lookRight ? beaver.x+beaver.collider.x : beaver.x;
		}
		else {
			tempcollider.x = x;
		}
		
		tempcollider.y = y;
		tempcollider.width = collider.width;
		tempcollider.height = collider.height;
		return tempcollider;
	}
	
	//TODO: Remove
	public void changeImage(String season)
	{
		if(season == "winter")
			this.image = this.imageWinter;
		else if(season == "summer")
			this.image = this.imageSummer;
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
				painter.drawCollider(x + collider.x,y + collider.y,collider.width,collider.height); //TODO: drawRect
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
	
	public int x, y, width, height;
	public float speedx, speedy;
	public float accx, accy;
	public float maxspeedy = 5.0f;
	public boolean collides = true;
}