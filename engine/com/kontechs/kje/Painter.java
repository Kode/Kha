package com.kontechs.kje;

public interface Painter {
	void drawImage(Image img, int x, int y);
	void drawImage(Image image, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh);
	void setColor(int r, int g, int b);
	void fillRect(int x, int y, int width, int height);
	void translate(int x, int y);
	
	//TODO
	//void drawStatusLine();
	//void drawCollider(int x,int y,int width,int height);
	//void drawExcavatorLife(int x,int y);
}