package com.ktxsoftware.kje;

public abstract class Painter {
	public abstract void drawImage(Image img, double x, double y);
	public abstract void drawImage(Image image, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh);
	public abstract void setColor(int r, int g, int b);
	public abstract void drawRect(double x, double y, double width, double height);
	public abstract void fillRect(double x, double y, double width, double height);
	public abstract void setFont(Font font);
	public abstract void drawChars(char[] text, int offset, int length, double x, double y);
	public abstract void drawString(String text, double x, double y);
	public abstract void drawLine(double x1, double y1, double x2, double y2);
	public abstract void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3);
	public abstract void translate(double x, double y);
	public void clear() {
		fillRect(0, 0, Game.getInstance().getWidth(), Game.getInstance().getHeight());
	}
	public abstract void begin();
	public abstract void end();
}