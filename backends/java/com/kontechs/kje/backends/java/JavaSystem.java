package com.kontechs.kje.backends.java;

public class JavaSystem extends com.kontechs.kje.System {
	private int xres, yres;
	
	public JavaSystem(int xres, int yres) {
		this.xres = xres;
		this.yres = yres;
	}
	
	@Override
	public int getXRes() {
		return xres;
	}

	@Override
	public int getYRes() {
		return yres;
	}	
}