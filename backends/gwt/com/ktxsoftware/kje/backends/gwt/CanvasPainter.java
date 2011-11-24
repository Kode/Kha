package com.ktxsoftware.kje.backends.gwt;

import com.google.gwt.canvas.dom.client.Context2d;
import com.google.gwt.canvas.dom.client.CssColor;
import com.google.gwt.dom.client.CanvasElement;
import com.google.gwt.user.client.ui.FocusPanel;
import com.ktxsoftware.kje.Font;
import com.ktxsoftware.kje.Image;
import com.ktxsoftware.kje.Painter;

public class CanvasPainter extends Painter {
	private int width, height;

    private Canvas2 canvas;
    private Context2d context;
	private double tx, ty;
	
	public CanvasPainter(FocusPanel panel, int width, int height) {
		this.width = width;
		this.height = height;

		canvas = Canvas2.createIfSupported();
		String agent = getUserAgent().toLowerCase();
		if ((agent.contains("msie 8") || agent.contains("msie 7") || agent.contains("msie 6")) && !agent.contains("opera")) initCanvas(canvas.getCanvasElement());
		canvas.setWidth(width + "px");
		canvas.setHeight(height + "px");
		canvas.setCoordinateSpaceWidth(width);
		canvas.setCoordinateSpaceHeight(height);
		context = canvas.getContext2d();
		
		panel.add(canvas);
	}
	
	public static native void initCanvas(CanvasElement canvas) /*-{
		$wnd.G_vmlCanvasManager.initElement(canvas);
	}-*/;
	
	public static native String getUserAgent() /*-{
		return navigator.userAgent.toLowerCase();
	}-*/;
	
	@Override
	public void drawImage(Image img, double x, double y) {
		context.drawImage(((WebImage)img).getIE(), tx + x, ty + y);
	}
	
	@Override
	public void drawImage(Image img, double sx, double sy, double sw, double sh, double dx, double dy, double dw, double dh) {
		try {
			context.drawImage(((WebImage)img).getIE(), sx, sy, sw, sh, tx + dx, ty + dy, dw, dh);
		}
		catch (Exception ex) {
			System.err.println("Error drawing image");
		}
	}
	
	@Override
	public void setColor(int r, int g, int b) {
		context.setStrokeStyle(CssColor.make(r, g, b));
		context.setFillStyle(CssColor.make(r, g, b));
	}
	
	@Override
	public void drawRect(double x, double y, double width, double height) {
		context.rect(tx + x, ty + y, width, height);
	}
	
	@Override
	public void fillRect(double x, double y, double width, double height) {
		context.fillRect(tx + x, ty + y, width, height);
	}

	@Override
	public void translate(double x, double y) {
		tx = x;
		ty = y;
	}

	@Override
	public void drawString(String text, double x, double y) {
		context.fillText(text, tx + x, ty + y);
	}

	@Override
	public void setFont(Font font) {
		context.setFont(((WebFont)font).name);
	}

	@Override
	public void drawChars(char[] text, int offset, int length, double x, double y) {
		drawString(new String(text, offset, length), x, y);
	}

	@Override
	public void drawLine(double x1, double y1, double x2, double y2) {
		context.moveTo(tx + x1, ty + y1);
		context.lineTo(tx + x2, ty + y2);
		context.moveTo(0, 0);
	}

	@Override
	public void fillTriangle(double x1, double y1, double x2, double y2, double x3, double y3) {
		context.beginPath();
		
		context.closePath();
		context.fill();
	}
	
	@Override
	public void begin() {
		
	}
	
	@Override
	public void end() {
		
	}
}