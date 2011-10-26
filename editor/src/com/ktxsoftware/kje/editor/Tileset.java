package com.ktxsoftware.kje.editor;

import java.awt.Graphics;
import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;

public class Tileset {
	private static BufferedImage[] tiles;

	public Tileset(String filename, int width, int height) {
		try {
			Image img = ImageIO.read(new File(filename));
			BufferedImage tilemap = new BufferedImage(img.getWidth(null), img.getHeight(null), BufferedImage.TYPE_4BYTE_ABGR);
			tilemap.getGraphics().drawImage(img, 0, 0, null);
			int xmax = tilemap.getWidth() / width;
			int ymax = tilemap.getHeight() / height;
			tiles = new BufferedImage[xmax * ymax];
			for (int x = 0; x < xmax; ++x) for (int y = 0; y < ymax; ++y) {
				tiles[x + y * xmax] = tilemap.getSubimage(x * width, y * height, width, height);
			}
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void paint(Graphics g, int tile, int x, int y) {
		g.drawImage(tiles[tile], x, y, null);
	} 

	public int getLength() {
		return tiles.length;
	}

	public static BufferedImage[] getTiles() {
		return tiles;
	}
}