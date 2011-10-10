package com.ktxsoftware.kje;

public interface Painter {
	void drawImage(Image img, double x, double y);
	void drawImage(Image image, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh);
	void setColor(int r, int g, int b);
	void drawRect(double x, double y, double width, double height);
	void fillRect(double x, double y, double width, double height);
	void setFont(Font font);
	void drawChars(char[] text, int offset, int length, double x, double y);
	void drawString(String text, double x, double y);
	void drawLine(double x1, double y1, double x2, double y2);
	void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3);
	void translate(double x, double y);
	void begin();
	void end();
}