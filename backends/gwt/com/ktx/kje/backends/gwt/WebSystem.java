package com.ktx.kje.backends.gwt;

public class WebSystem extends com.ktx.kje.System {
	int xres, yres;
	
	public WebSystem(int xres, int yres) {
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