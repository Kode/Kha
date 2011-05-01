package com.kontechs.kje;

public class Rectangle {
	public int x, y, width, height;
	
	public Rectangle(int x, int y, int width, int height) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
	
	public void setPos(int x, int y) {
		this.x = x;
		this.y = y;
	}

	public void moveX(int xdelta) {
		x += xdelta;
	}
	
	public void moveY(int ydelta) {
		y += ydelta;
	}
	
	public boolean collision(Rectangle r) {
		boolean a, b;
		if (x < r.x) a = r.x < x + width;
		else a = x < r.x + r.width;
		if (y < r.y) b = r.y < y + height;
		else b = y < r.y + r.height;
		return a && b;
	}
	
	//TODO: Check
	/*additional function to check collision between burstingbranch and hero
	 * this function checks if the hero stands on top of the branch
	 * @author Robert Pabst
	 */
	public boolean collisionTopOnly(Rectangle r) {
		boolean a, b;
		if (x < r.x) a = r.x < x + width;
		else a = x < r.x + r.width;
		if (y < r.y + r.height) b = r.y + r.height < y + height;
		else b = y < r.y + r.height;
		return a && b;
	}
}