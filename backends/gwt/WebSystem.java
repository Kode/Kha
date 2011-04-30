package de.hsharz.game.client;

public class WebSystem extends de.hsharz.game.engine.System {
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