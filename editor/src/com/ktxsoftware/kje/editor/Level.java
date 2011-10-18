package com.ktxsoftware.kje.editor;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Rectangle;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.PrintStream;

import javax.swing.JPanel;

public class Level extends JPanel implements MouseListener, MouseMotionListener{
	private static final long serialVersionUID = 1L;
	private int levelWidth = 256;
	private int levelHeight = 224 / 16;
	public static final int TILE_WIDTH = 16;
	public static final int TILE_HEIGHT = 16;
	
	private static Level instance;
	private int[][] map_foreground_summer;
	private int[][]	map_background_summer;
	private int[][]	map_background2_summer;
	private int[][]	map_background3_summer;
	private int[][] map_overlay_summer;
	private int[][] map_foreground_winter;
	private int[][]	map_background_winter;
	private int[][]	map_background2_winter;
	private int[][]	map_background3_winter;
	private int[][] map_overlay_winter;
	private boolean blank_mode = false;

	static {
		instance = new Level();
	}

	public static Level getInstance() {
		return instance;
	}

	public int getLevelWidth() {
		return levelWidth;
	}

	public int getLevelHeight() {
		return levelHeight;
	}

	private Level() {
		map_foreground_summer = new int[levelWidth][levelHeight];
		map_background_summer = new int[levelWidth][levelHeight];
		map_background2_summer = new int[levelWidth][levelHeight];
		map_background3_summer = new int[levelWidth][levelHeight];
		map_overlay_summer = new int[levelWidth][levelHeight];
		map_foreground_winter = new int[levelWidth][levelHeight];
		map_background_winter = new int[levelWidth][levelHeight];
		map_background2_winter = new int[levelWidth][levelHeight];
		map_background3_winter = new int[levelWidth][levelHeight];
		map_overlay_winter = new int[levelWidth][levelHeight];
		addMouseListener(this);
		addMouseMotionListener(this);
		setPreferredSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
		
	}

	public void paint(Graphics g) {
		Rectangle rect = getVisibleRect();
		g.setColor(Color.WHITE);
		g.fillRect(rect.x, rect.y, rect.width, rect.height);
		for (int x = rect.x / TILE_WIDTH; x < Math.min((rect.x + rect.width) / TILE_WIDTH + 1, levelWidth); ++x)
			for (int y = rect.y / TILE_HEIGHT; y < Math.min((rect.y + rect.height) / TILE_HEIGHT + 1, levelHeight); ++y) {
				
				if(Editor.getVisible_layers()[Editor.LAYER_BACKGROUND]){
					TilesetPanel.getInstance().paint((Graphics2D) g,
							Editor.isSummer_season()? map_background_summer[x][y]: map_background_winter[x][y], 
									x * TILE_WIDTH,y * TILE_HEIGHT);
				}
				if(Editor.getVisible_layers()[Editor.LAYER_BACKGROUND2]){
					TilesetPanel.getInstance().paint((Graphics2D) g,
							Editor.isSummer_season()? map_background2_summer[x][y]: map_background2_winter[x][y], 
									x * TILE_WIDTH,y * TILE_HEIGHT);
				}
				if(Editor.getVisible_layers()[Editor.LAYER_BACKGROUND3]){
					TilesetPanel.getInstance().paint((Graphics2D) g,
							Editor.isSummer_season()? map_background3_summer[x][y]: map_background3_winter[x][y], 
									x * TILE_WIDTH,y * TILE_HEIGHT);
				}
				if(Editor.getVisible_layers()[Editor.LAYER_FOREGROUND]){
					// paint "real" blank elements (0) with a red cross
					int element_id = Editor.isSummer_season()?map_foreground_summer[x][y]:map_foreground_winter[x][y];
					if(blank_mode && element_id == 0){
						TilesetPanel.getInstance().paint((Graphics2D) g,2,x * TILE_WIDTH,y * TILE_HEIGHT);
					}
					else{
					TilesetPanel.getInstance().paint((Graphics2D) g,
							Editor.isSummer_season()? map_foreground_summer[x][y]: map_foreground_winter[x][y], 
									x * TILE_WIDTH,y * TILE_HEIGHT);
					}
					
				}
				
				if(Editor.getVisible_layers()[Editor.LAYER_OVERLAY]){
					TilesetPanel.getInstance().paint((Graphics2D) g,
							Editor.isSummer_season()? map_overlay_summer[x][y]: map_overlay_winter[x][y], 
									x * TILE_WIDTH,y * TILE_HEIGHT);
				}		
				
		}
		g.setColor(Color.BLACK);
		for (int x = rect.x / TILE_WIDTH * TILE_WIDTH; x < rect.x + rect.width; x += TILE_WIDTH) g.drawLine(x, rect.y, x, rect.y + rect.height);
		for (int y = rect.y / TILE_HEIGHT * TILE_HEIGHT; y < rect.y + rect.height; y += TILE_HEIGHT) g.drawLine(rect.x, y, rect.x + rect.width, y);
	}

	public void save(DataOutputStream stream_background_summer,DataOutputStream stream_background2_summer,DataOutputStream stream_background3_summer, DataOutputStream stream_foreground_summer,DataOutputStream stream_overlay_summer,
			DataOutputStream stream_background_winter,DataOutputStream stream_background2_winter,DataOutputStream stream_background3_winter, DataOutputStream stream_foreground_winter,DataOutputStream stream_overlay_winter) {
		try {
			stream_foreground_summer.writeInt(levelWidth);
			stream_foreground_summer.writeInt(levelHeight);
			stream_background_summer.writeInt(levelWidth);
			stream_background_summer.writeInt(levelHeight);
			stream_background2_summer.writeInt(levelWidth);
			stream_background2_summer.writeInt(levelHeight);
			stream_background3_summer.writeInt(levelWidth);
			stream_background3_summer.writeInt(levelHeight);
			stream_overlay_summer.writeInt(levelWidth);
			stream_overlay_summer.writeInt(levelHeight);
			
			stream_foreground_winter.writeInt(levelWidth);
			stream_foreground_winter.writeInt(levelHeight);
			stream_background_winter.writeInt(levelWidth);
			stream_background_winter.writeInt(levelHeight);
			stream_background2_winter.writeInt(levelWidth);
			stream_background2_winter.writeInt(levelHeight);
			stream_background3_winter.writeInt(levelWidth);
			stream_background3_winter.writeInt(levelHeight);
			stream_overlay_winter.writeInt(levelWidth);
			stream_overlay_winter.writeInt(levelHeight);
			
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
				stream_foreground_summer.writeInt(map_foreground_summer[x][y]);
				stream_background_summer.writeInt(map_background_summer[x][y]);
				stream_background2_summer.writeInt(map_background2_summer[x][y]);
				stream_background3_summer.writeInt(map_background3_summer[x][y]);
				stream_overlay_summer.writeInt(map_overlay_summer[x][y]);
				
				stream_foreground_winter.writeInt(map_foreground_winter[x][y]);
				stream_background_winter.writeInt(map_background_winter[x][y]);
				stream_background2_winter.writeInt(map_background2_winter[x][y]);
				stream_background3_winter.writeInt(map_background3_winter[x][y]);
				stream_overlay_winter.writeInt(map_overlay_winter[x][y]);
			}
		}
		catch (IOException ex) {
			ex.printStackTrace();
		}
		finally {
			try {
				stream_background_summer.close();
				stream_background2_summer.close();
				stream_background3_summer.close();
				stream_foreground_summer.close();
				stream_overlay_summer.close();
				
				stream_background_winter.close();
				stream_background2_winter.close();
				stream_background3_winter.close();
				stream_foreground_winter.close();
				stream_overlay_winter.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void saveJava(PrintStream stream) {
		try {
			stream.print("class LevelMap { public static int[] levelmap = new int[]{");
			stream.print(levelWidth + ",");
			stream.print(levelHeight + ",");
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
				if (x == levelWidth - 1 && y == levelHeight - 1) stream.print(map_foreground_summer[x][y]);
				else stream.print(map_foreground_summer[x][y] + ",");
			}
			stream.print("}; }");
		}
		finally {
			stream.close();
		}
	}
	
	public void load(DataInputStream stream_background_summer,DataInputStream stream_background2_summer,DataInputStream stream_background3_summer,DataInputStream stream_foreground_summer,DataInputStream stream_overlay_summer,
			DataInputStream stream_background_winter,DataInputStream stream_background2_winter,DataInputStream stream_background3_winter,DataInputStream stream_foreground_winter,DataInputStream stream_overlay_winter) {
		try {
			levelWidth = stream_foreground_summer.readInt();
			levelHeight = stream_foreground_summer.readInt();
			// Ersten beiden Werte einlesen, da sie ja nicht zur Tilesetdefinition gehoeren
			// sondern width und height beinhalten
			stream_background_summer.readInt();
			stream_background_summer.readInt();
			stream_background2_summer.readInt();
			stream_background2_summer.readInt();
			stream_background3_summer.readInt();
			stream_background3_summer.readInt();
			stream_overlay_summer.readInt();
			stream_overlay_summer.readInt();
			
			stream_background_winter.readInt();
			stream_background_winter.readInt();
			stream_background2_winter.readInt();
			stream_background2_winter.readInt();
			stream_background3_winter.readInt();
			stream_background3_winter.readInt();
			stream_overlay_winter.readInt();
			stream_overlay_winter.readInt();
			stream_foreground_winter.readInt();
			stream_foreground_winter.readInt();
			
			setPreferredSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
			setSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
			// Einzelnen Tilesetdefinition fuer die verschiedenen Layer auslesen und in dazugehoerigen
			// Arrays speichern
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
				map_foreground_summer[x][y] = stream_foreground_summer.readInt();
				map_background_summer[x][y] = stream_background_summer.readInt();
				map_background2_summer[x][y] = stream_background2_summer.readInt();
				map_background3_summer[x][y] = stream_background3_summer.readInt();
				map_overlay_summer[x][y] = stream_overlay_summer.readInt();
				
				map_foreground_winter[x][y] = stream_foreground_winter.readInt();
				map_background_winter[x][y] = stream_background_winter.readInt();
				map_background2_winter[x][y] = stream_background2_winter.readInt();
				map_background3_winter[x][y] = stream_background3_winter.readInt();
				map_overlay_winter[x][y] = stream_overlay_winter.readInt();
			}
		}
		catch (IOException ex) {
			ex.printStackTrace();
		}
		finally {
			try {
				stream_foreground_summer.close();
				stream_background_summer.close();
				stream_background2_summer.close();
				stream_background3_summer.close();
				stream_overlay_summer.close();
				stream_foreground_winter.close();
				stream_background_winter.close();
				stream_background2_winter.close();
				stream_background3_winter.close();
				stream_overlay_winter.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public void mouseClicked(MouseEvent e) {
		
	}
	public void mouseReleased(MouseEvent e) {
		int x = e.getX() / TILE_WIDTH;
		int y = e.getY() / TILE_HEIGHT;
		// 32 Elemente
		int smallestX = 32;
		int smallestY = 20;
		// hoechsten und niedrigsten X und Y Wert ... zum normalisieren des Index gebraucht
		for(int index:TilesetPanel.getInstance().getSelectedElements()){
			index++;
			System.out.println("index: " + index);
			if(smallestX >	(index-1)%32){
				smallestX = (index-1)%32;
			}
			if(smallestY > index/32){
				smallestY = index/32;
			}
		}
		System.out.println("smallestX: " + smallestX);
		// Position der Elemente relativ zum Mauspunkt zeichnen
		for(int index:TilesetPanel.getInstance().getSelectedElements()){
			switch(Editor.getActual_layer()){
				case Editor.LAYER_BACKGROUND:
					if(Editor.isSummer_season()){
//						System.out.println("x: " + x);
//						System.out.println("index: " + index);
//						System.out.println("index%32: " + index%32);
//						System.out.println("smallestX: " + smallestX);
//						System.out.println("ergebnis: " + (x + index%32 - smallestX + 1));
						map_background_summer[x + index%32 - smallestX][y + index/32 - smallestY] = index;
					}else{
						map_background_winter[x + index%32 - smallestX][y + index/32 - smallestY] = index;
					}
				break;
				case Editor.LAYER_BACKGROUND2:
					if(Editor.isSummer_season()){
						map_background2_summer[x + index%32 - smallestX][y + index/32 - smallestY] = index;
					}else{
						map_background2_winter[x + index%32 - smallestX][y + index/32 - smallestY] = index;
					}
				break;
				case Editor.LAYER_BACKGROUND3:
					if(Editor.isSummer_season()){
						map_background3_summer[x + index%32 - smallestX][y + index/32 - smallestY] = index;
					}else{
						map_background3_winter[x + index%32 - smallestX][y + index/32 - smallestY] = index;
					}
				break;
			
				case Editor.LAYER_FOREGROUND:
					if(Editor.isSummer_season()){
						map_foreground_summer[x + index%32 - smallestX][y + index/32 - smallestY] = index;
					}else{
						map_foreground_winter[x + index%32 - smallestX][y + index/32 - smallestY] = index;
					}
				break;
				
				case Editor.LAYER_OVERLAY:
					if(Editor.isSummer_season()){
						map_overlay_summer[x + index%32 - smallestX][y + index/32 - smallestY] = index;
					}else{
						map_overlay_winter[x + index%32 - smallestX][y + index/32 - smallestY] = index;
					}
				break;
			}
			
		}
		
		repaint();
	}
	public void mousePressed(MouseEvent e) {}
	public void mouseEntered(MouseEvent e) { }
	public void mouseExited(MouseEvent e) { }
	public void mouseDragged(MouseEvent e) {
		int x = e.getX() / TILE_WIDTH;
		int y = e.getY() / TILE_HEIGHT;
		// Beim Draggen nur 1.Element
		switch(Editor.getActual_layer()){
		case Editor.LAYER_BACKGROUND:
			if(Editor.isSummer_season()){
				map_background_summer[x][y] = TilesetPanel.getInstance().getSelectedElements().get(0);
			}
			else{
				map_background_winter[x][y] = TilesetPanel.getInstance().getSelectedElements().get(0);
			}	
		break;
		case Editor.LAYER_BACKGROUND2:
			if(Editor.isSummer_season()){
				map_background2_summer[x][y] = TilesetPanel.getInstance().getSelectedElements().get(0);
			}
			else{
				map_background2_winter[x][y] = TilesetPanel.getInstance().getSelectedElements().get(0);
			}	
		break;
		case Editor.LAYER_BACKGROUND3:
			if(Editor.isSummer_season()){
				map_background3_summer[x][y] = TilesetPanel.getInstance().getSelectedElements().get(0);
			}
			else{
				map_background3_winter[x][y] = TilesetPanel.getInstance().getSelectedElements().get(0);
			}	
		break;
	
		case Editor.LAYER_FOREGROUND:
			if(Editor.isSummer_season()){
				map_foreground_summer[x][y] = TilesetPanel.getInstance().getSelectedElements().get(0);
			}
			else{
				map_foreground_winter[x][y] = TilesetPanel.getInstance().getSelectedElements().get(0);
			}	
		break;
		
		case Editor.LAYER_OVERLAY:
			if(Editor.isSummer_season()){
				map_overlay_summer[x][y] = TilesetPanel.getInstance().getSelectedElements().get(0);
			}
			else{
				map_overlay_winter[x][y] = TilesetPanel.getInstance().getSelectedElements().get(0);
			}	
		break;
	}
		repaint();
	}
	public void mouseMoved(MouseEvent e) {}
	
	public void resetMaps() {
		map_foreground_summer = new int[levelWidth][levelHeight];
		map_background_summer = new int[levelWidth][levelHeight];
		map_background2_summer = new int[levelWidth][levelHeight];
		map_background3_summer = new int[levelWidth][levelHeight];
		map_overlay_summer = new int[levelWidth][levelHeight];
		map_foreground_winter = new int[levelWidth][levelHeight];
		map_background_winter = new int[levelWidth][levelHeight];
		map_background2_winter = new int[levelWidth][levelHeight];
		map_background3_winter = new int[levelWidth][levelHeight];
		map_overlay_winter = new int[levelWidth][levelHeight];
		repaint();
	}
	
	public void translateSummertoWinter(TileProperty[] elementProperties) {
		for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
			if (elementProperties[map_background_summer[x][y]].getSeasonMode() == TileProperty.SEASONMODE_BOTH) {
				map_background_winter[x][y] = elementProperties[map_background_summer[x][y]].getLinkedTile();
			}
			if (elementProperties[map_background2_summer[x][y]].getSeasonMode() == TileProperty.SEASONMODE_BOTH) {
				map_background2_winter[x][y] = elementProperties[map_background2_summer[x][y]].getLinkedTile();
			}
			if (elementProperties[map_background3_summer[x][y]].getSeasonMode() == TileProperty.SEASONMODE_BOTH) {
				map_background3_winter[x][y] = elementProperties[map_background3_summer[x][y]].getLinkedTile();
			}
			if (elementProperties[map_foreground_summer[x][y]].getSeasonMode() == TileProperty.SEASONMODE_BOTH) {
				map_foreground_winter[x][y] = elementProperties[map_foreground_summer[x][y]].getLinkedTile();
			}
			if (elementProperties[map_overlay_summer[x][y]].getSeasonMode() == TileProperty.SEASONMODE_BOTH) {
				map_overlay_winter[x][y] = elementProperties[map_overlay_summer[x][y]].getLinkedTile();
			}
		}
	}

	public boolean isBlank_mode() {
		return blank_mode;
	}

	public void setBlank_mode(boolean blank_mode) {
		this.blank_mode = blank_mode;
	}
}