package de.hsharz.game.client;

import com.google.gwt.canvas.dom.client.Context2d;
import com.google.gwt.canvas.dom.client.CssColor;

import de.hsharz.game.engine.Image;
import de.hsharz.game.engine.Painter;

public class CanvasPainter implements Painter {
	private Context2d context;
	private int tx, ty;
	
	public CanvasPainter(Context2d context) {
		this.context = context;
	}
	
	public void drawImage(Image img, int x, int y) {
		if (((WebImage)img).getIE() != null) context.drawImage(((WebImage)img).getIE(), tx + x, ty + y);
	}
	
	public void drawImage(Image img, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh) {
		if (((WebImage)img).getIE() != null) context.drawImage(((WebImage)img).getIE(), sx, sy, sw, sh, tx + dx, ty + dy, dw, dh);
	}
	
	public void setColor(int r, int g, int b) {
		context.setFillStyle(CssColor.make(r, g, b));
		
	}
	
	public void fillRect(int x, int y, int width, int height) {
		context.fillRect(tx + x, ty + y, width, height);
	}

	@Override
	public void translate(int x, int y) {
		tx = x;
		ty = y;
	}
}