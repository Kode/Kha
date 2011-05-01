package com.kontechs.kje.backends.java;

import java.awt.Color;
import java.awt.Graphics2D;

import com.kontechs.kje.Image;
import com.kontechs.kje.Painter;

public class GraphicsPainter implements Painter {
	private Graphics2D g;
	private int tx, ty;

	public GraphicsPainter(Graphics2D g) {
		this.g = g;
	}
	
	@Override
	public void drawImage(Image img, int x, int y) {
		g.drawImage(((JavaImage)img).getImage(), tx + x, ty + y, null);
	}

	@Override
	public void drawImage(Image img, int sx, int sy, int sw, int sh, int dx, int dy, int dw, int dh) {
		g.drawImage(((JavaImage)img).getImage(), tx + dx, ty + dy, tx + dx + dw, ty + dy + dh, sx, sy, sx + sw, sy + sh, null);
	}

	@Override
	public void setColor(int r, int g, int b) {
		this.g.setColor(new Color(r, g, b));
	}

	@Override
	public void fillRect(int x, int y, int width, int height) {
		g.fillRect(tx + x, ty + y, width, height);	
	}
	
	public void translate(int x, int y) {
		tx = x;
		ty = y;
	}
	
	//TODO: Should not be here
	/*public void drawStatusLine(){ 
		g.drawImage(((JavaImage) StatusLine.getStatusLine()).getImage(), 0, 505, null);
	
		g.setFont(new Font("Arial",Font.PLAIN, 13));
		g.drawString("" + StatusLine.getScore(), 120, 541);
		int life_rectangleLength = 150;
		g.fillRect(436, 530, 
				(int) (life_rectangleLength - 
				((double)life_rectangleLength * 
						(1-((double)StatusLine.getTime_leftInSeconds() / (double)StatusLine.getGametimeInSeconds()))
				)), 11);
		for(int i = 0;i<Beaver.getInstance().getBeaver_hearts();i++){
			int x = 260 + 20 * i;
			g.drawImage(((JavaImage)StatusLine.getStatus_heart()).getImage(), x, 533, null);
		}
		
		if (Beaver.getInstance().isGodMode()) {
			g.setColor(Color.RED);
			g.setFont(new Font("Arial", Font.BOLD, 20));
			g.drawString("Godmode enabled", 50, 50);			
		}
	}*/
	
	//TODO: Should not be here
	/*public void drawExcavatorLife(int x,int y){ 
		g.setColor(Color.RED);
		
		if(ExcavatorLifeLine.getPosx()>0)
			g.fillRect(ExcavatorLifeLine.getPosx() - Scene.getInstance().camx + 370, ExcavatorLifeLine.getPosy() + 30, ExcavatorLifeLine.getActualLifeLineLength(), 10);
	}*/
	
	//TODO: Should not be here
	/*public void drawCollider(int x,int y,int width,int height){
		g.setColor(Color.RED);
		g.drawRect(x + tx, y + ty, width, height);
	}*/
}