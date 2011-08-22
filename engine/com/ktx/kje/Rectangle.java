package com.ktx.kje;

public class Rectangle {
	public double x, y, width, height;
	
	public Rectangle(double x, double y, double width, double height) {
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
}