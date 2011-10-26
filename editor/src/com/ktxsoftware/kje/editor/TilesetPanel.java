package com.ktxsoftware.kje.editor;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;
import java.util.ArrayList;

import javax.swing.JScrollPane;

public class TilesetPanel extends JScrollPane implements MouseListener, MouseMotionListener {
	private static final long serialVersionUID = 1L;
	
	private static final int PANEL_WIDTH = 1024;
	private static final int PANEL_HEIGHT = 600;
	
	private static TilesetPanel instance;
	
	private Tileset tileset;
	private Point mouse = new Point(0, 0);
	private int last;
	private ArrayList<Integer> selectedElements = new ArrayList<Integer>();

	static {
		instance = new TilesetPanel();
	}

	public static TilesetPanel getInstance() {
		return instance;
	}

	private TilesetPanel() {
		tileset = new Tileset(
				"../games/gradius/data/Gradius_001.png",
				Level.TILE_WIDTH, Level.TILE_HEIGHT);
		setPreferredSize(new Dimension(PANEL_WIDTH, PANEL_HEIGHT));
		addMouseMotionListener(this);
		addMouseListener(this);
	}

	public void paint(Graphics g) {
		g.setColor(Color.WHITE);
		g.fillRect(0, 0, PANEL_WIDTH*2, PANEL_HEIGHT);
		int width = (PANEL_WIDTH / Level.TILE_WIDTH) * Level.TILE_WIDTH;
		for (int tile = 0; tile < tileset.getLength(); ++tile) {
			int x = Level.TILE_WIDTH * tile % width;
			int y = (Level.TILE_HEIGHT * tile / width) * Level.TILE_HEIGHT;
			tileset.paint(g, tile, x, y);
			if (mouse.x > x && mouse.x < x + Level.TILE_WIDTH && mouse.y > y && mouse.y < y + Level.TILE_HEIGHT) {
				markTile(g, new Color(1, 0, 0, 0.5f), x, y);
				last = tile;
			}
			if (isSelected(tile)) markTile(g, new Color(0, 0.5f, 0, 0.5f), x, y);
		}
	}
	
	private void markTile(Graphics g, Color c, int x, int y) {
		g.setColor(c);
		g.fillRect(x, y, Level.TILE_WIDTH, Level.TILE_HEIGHT);
	}
	
	private boolean isSelected(int tile) {
		for (int selectedElement : selectedElements) if (tile == selectedElement) return true;
		return false;
	}

	public ArrayList<Integer> getSelectedElements() {
		return selectedElements;
	}
	
	public Tileset getTileset() {
		return tileset;
	}

	public void mouseMoved(MouseEvent e) {
		mouse = e.getPoint();
		repaint();
	}

	public void mousePressed(MouseEvent e) {
		selectedElements.clear();
		selectedElements.add(last);
	}

	public void mouseDragged(MouseEvent e) { 
		if (!selectedElements.contains(last)) selectedElements.add(last);
		mouse = e.getPoint();
		repaint();
	}
	
	public void mouseClicked(MouseEvent e) { }
	
	public void mouseReleased(MouseEvent e) { }
	
	public void mouseEntered(MouseEvent e) { }
	
	public void mouseExited(MouseEvent e) { }
}