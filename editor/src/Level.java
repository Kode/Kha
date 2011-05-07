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

public class Level extends JPanel implements MouseListener, MouseMotionListener {
	private static final long serialVersionUID = 1L;
	private int levelWidth = 1000;
	private int levelHeight = 16;
	public static final int TILE_WIDTH = 16;
	public static final int TILE_HEIGHT = 16;
	
	private static Level instance;
	private int[][] map;

	static {
		instance = new Level();
	}

	public static Level getInstance() {
		return instance;
	}

	private Level() {
		map = new int[levelWidth][levelHeight];
		addMouseListener(this);
		addMouseMotionListener(this);
		setPreferredSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
	}

	public void mousePressed(MouseEvent e) {
		int x = e.getX() / TILE_WIDTH;
		int y = e.getY() / TILE_HEIGHT;
		map[x][y] = TilesetPanel.getInstance().getLast();
		repaint();
	}

	public void paint(Graphics g) {
		Rectangle rect = getVisibleRect();
		g.setColor(Color.WHITE);
		g.fillRect(rect.x, rect.y, rect.width, rect.height);
		for (int x = rect.x / TILE_WIDTH; x < Math.min((rect.x + rect.width) / TILE_WIDTH + 1, levelWidth); ++x)
			for (int y = rect.y / TILE_HEIGHT; y < Math.min((rect.y + rect.height) / TILE_HEIGHT + 1, levelHeight); ++y) {
				TilesetPanel.getInstance().paint((Graphics2D)g, map[x][y], x * TILE_WIDTH, y * TILE_HEIGHT);
		}
		g.setColor(Color.BLACK);
		for (int x = rect.x / TILE_WIDTH * TILE_WIDTH; x < rect.x + rect.width; x += TILE_WIDTH) g.drawLine(x, rect.y, x, rect.y + rect.height);
		for (int y = rect.y / TILE_HEIGHT * TILE_HEIGHT; y < rect.y + rect.height; y += TILE_HEIGHT) g.drawLine(rect.x, y, rect.x + rect.width, y);
	}

	public void save(DataOutputStream stream) {
		try {
			//levelWidth = levelWidth - 9;
			//levelHeight = 10;
			stream.writeInt(levelWidth);
			stream.writeInt(levelHeight);
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
				stream.writeInt(map[x][y]);
			}
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
	
	public void saveJava(PrintStream stream) {
		try {
			stream.print("class LevelMap { public static int[] levelmap = new int[]{");
			stream.print(levelWidth + ",");
			stream.print(levelHeight + ",");
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
				if (x == levelWidth - 1 && y == levelHeight - 1) stream.print(map[x][y]);
				else stream.print(map[x][y] + ",");
			}
			stream.print("}; }");
		}
		finally {
			stream.close();
		}
	}
	
	public void load(DataInputStream stream) {
		try {
			levelWidth = stream.readInt();
			levelHeight = stream.readInt();
			setPreferredSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
			setSize(new Dimension(levelWidth * TILE_WIDTH, levelHeight * TILE_HEIGHT));
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
				map[x][y] = stream.readInt();
			}
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

	public void mouseClicked(MouseEvent e) { }
	public void mouseReleased(MouseEvent e) { }
	public void mouseEntered(MouseEvent e) { }
	public void mouseExited(MouseEvent e) { }
	public void mouseDragged(MouseEvent e) { }
	public void mouseMoved(MouseEvent e) { }
}