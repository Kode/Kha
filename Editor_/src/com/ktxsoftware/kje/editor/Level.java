package com.ktxsoftware.kje.editor;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Rectangle;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;

import javax.swing.JPanel;

public class Level extends JPanel implements MouseListener, MouseMotionListener{
	private static final long serialVersionUID = 1L;
	
	public static final int TILE_WIDTH = 16;
	public static final int TILE_HEIGHT = 16;
	
	private static Level instance;
	
	private int levelWidth = 256;
	private int levelHeight = 224 / 16;
	private int[][] map;

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
		map = new int[levelWidth][levelHeight];
		addMouseListener(this);
		addMouseMotionListener(this);
		setPreferredSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
	}

	public void paint(Graphics g) {
		Rectangle rect = getVisibleRect();
		g.setColor(Color.WHITE);
		g.fillRect(rect.x, rect.y, rect.width, rect.height);
		for (int x = rect.x / TILE_WIDTH; x < Math.min((rect.x + rect.width) / TILE_WIDTH + 1, levelWidth); ++x)
			for (int y = rect.y / TILE_HEIGHT; y < Math.min((rect.y + rect.height) / TILE_HEIGHT + 1, levelHeight); ++y)
				TilesetPanel.getInstance().getTileset().paint(g, map[x][y], x * TILE_WIDTH,y * TILE_HEIGHT);
		g.setColor(Color.BLACK);
		for (int x = rect.x / TILE_WIDTH * TILE_WIDTH; x < rect.x + rect.width; x += TILE_WIDTH) g.drawLine(x, rect.y, x, rect.y + rect.height);
		for (int y = rect.y / TILE_HEIGHT * TILE_HEIGHT; y < rect.y + rect.height; y += TILE_HEIGHT) g.drawLine(rect.x, y, rect.x + rect.width, y);
	}

	public void save(DataOutputStream stream) {
		try {
			stream.writeInt(levelWidth);
			stream.writeInt(levelHeight);
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) stream.writeInt(map[x][y]);
		}
		catch (IOException ex) {
			ex.printStackTrace();
		}
		finally {
			try {
				stream.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
	}

	public void load(DataInputStream stream) {
		try {
			levelWidth = stream.readInt();
			levelHeight = stream.readInt();
			map = new int[levelWidth][levelHeight];
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) map[x][y] = stream.readInt();
		}
		catch (IOException ex) {
			ex.printStackTrace();
		}
		finally {
			try {
				stream.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
		setPreferredSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
		setSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
	}

	public void mouseReleased(MouseEvent e) {
		int x = e.getX() / TILE_WIDTH;
		int y = e.getY() / TILE_HEIGHT;
		int smallestX = Integer.MAX_VALUE;
		int smallestY = Integer.MAX_VALUE;
		for (int index : TilesetPanel.getInstance().getSelectedElements()) {
			if (smallestX > index % 32) smallestX = index % 32;
			if (smallestY > index / 32) smallestY = index / 32;
		}
		for (int index : TilesetPanel.getInstance().getSelectedElements()) map[x + index % 32 - smallestX][y + index / 32 - smallestY] = index;
		repaint();
	}
	
	public void mouseClicked(MouseEvent e) { }
	
	public void mousePressed(MouseEvent e) { }
	
	public void mouseEntered(MouseEvent e) { }
	
	public void mouseExited(MouseEvent e) { }
	
	public void mouseDragged(MouseEvent e) {
		map[e.getX() / TILE_WIDTH][e.getY() / TILE_HEIGHT] = TilesetPanel.getInstance().getSelectedElements().get(0);
		repaint();
	}
	
	public void mouseMoved(MouseEvent e) {}
	
	public void resetMaps() {
		map = new int[levelWidth][levelHeight];
		repaint();
	}
}