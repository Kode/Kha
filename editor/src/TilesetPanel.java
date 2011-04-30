import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;

import javax.swing.JPanel;

public class TilesetPanel extends JPanel implements MouseListener, MouseMotionListener {
	private static final long serialVersionUID = 1L;
	private static final int PANEL_WIDTH = 1000;
	private static final int PANEL_HEIGHT = 300;
	private static TilesetPanel instance;
	private Tileset tileset;
	private Point mouse = new Point(0, 0);
	private int last, verylast;

	static {
		instance = new TilesetPanel();
	}

	public static TilesetPanel getInstance() {
		return instance;
	}

	private TilesetPanel() {
		tileset = new Tileset(
				//"../data/zool/tiles.png",
				"../data/tiles.png",
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
		}
	}

	public void paint(Graphics2D g2d, int tile, int x, int y) {
		tileset.paint(g2d, tile, x, y);
	}

	public int getLast() {
		return verylast;
	}

	public void mouseMoved(MouseEvent e) {
		mouse = e.getPoint();
		repaint();
	}

	public void mousePressed(MouseEvent e) {
		verylast = last;
	}

	public void mouseDragged(MouseEvent e) { }
	public void mouseClicked(MouseEvent e) { }
	public void mouseReleased(MouseEvent e) { }
	public void mouseEntered(MouseEvent e) { }
	public void mouseExited(MouseEvent e) { }
}