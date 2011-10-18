package com.ktxsoftware.kje.editor;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
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
				//"../data/zool/tiles.png",
				//"../data/tiles.png",
				"../Gradius_001.png",
				Level.TILE_WIDTH, Level.TILE_HEIGHT);
		setPreferredSize(new Dimension(PANEL_WIDTH, PANEL_HEIGHT));
		this.addMouseMotionListener(this);
		this.addMouseListener(this);
	}

	public void paint(Graphics g) {
		g.setColor(Color.WHITE);
		g.fillRect(0, 0, PANEL_WIDTH*2, PANEL_HEIGHT);
		int width = (PANEL_WIDTH / Level.TILE_WIDTH) * Level.TILE_WIDTH;
		for (int i = 0; i < tileset.getLength(); ++i) {
			int x = Level.TILE_WIDTH * i % width;
			int y = (Level.TILE_HEIGHT * i / width) * Level.TILE_HEIGHT;
			tileset.paint((Graphics2D) g, i, x, y);
			if (mouse.x > x && mouse.x < x + Level.TILE_WIDTH && mouse.y > y && mouse.y < y + Level.TILE_HEIGHT) {
				g.setColor(new Color(1, 0, 0, 0.5f));
				g.fillRect(x, y, Level.TILE_WIDTH, Level.TILE_HEIGHT);
				last = i;
			}
			// Markiert die aktuell selektierten Elemente halbgruen
			for(int selectedElement:selectedElements){
			if(i == selectedElement){
				g.setColor(new Color(0, 0.5f, 0, 0.5f));
				g.fillRect(x, y, Level.TILE_WIDTH, Level.TILE_HEIGHT);
			}
			}
		}
	}

	public void paint(Graphics2D g2d, int tile, int x, int y) {
		tileset.paint(g2d, tile, x, y);
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
		((TileProperties)((Editor)this.getTopLevelAncestor()).lvlElements_properties).update();
		
	}

	public void mouseDragged(MouseEvent e) { 
		// Element nur aufnehmen wenn noch nicht in Liste
		if (!selectedElements.contains(last)) {
			selectedElements.add(last);
		}
		
		mouse = e.getPoint();
		repaint();
	}
	public void mouseClicked(MouseEvent e) { }
	public void mouseReleased(MouseEvent e) {
	}
	public void mouseEntered(MouseEvent e) { }
	public void mouseExited(MouseEvent e) { }

	
}