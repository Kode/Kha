package com.ktxsoftware.kje.backends.java;

import java.awt.Cursor;
import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;

import javax.imageio.ImageIO;
import javax.swing.JOptionPane;

import com.ktxsoftware.kje.Font;
import com.ktxsoftware.kje.HighscoreList;
import com.ktxsoftware.kje.Loader;
import com.ktxsoftware.kje.Score;

public class JavaLoader extends Loader {
	private final static String base = "data/";
	
	@Override
	public void loadImage(String name) {
		try {
			images.put(name, new JavaImage(ImageIO.read(new File(base + name))));
		}
		catch (IOException e) {
			System.err.println("Failed loading " + name);
			e.printStackTrace();
		}
	}
	
	@Override
	public void loadSound(String name) {
		sounds.put(name, new JavaSound(base + name + ".wav"));
	}
	
	@Override
	public void loadMusic(String name) {
		try {
			musics.put(name, new JavaMusic(new File(base + name + ".wav")));
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public void loadMap(String lvl_name) {
		try {
			int[][] map;
			DataInputStream stream = new DataInputStream(new BufferedInputStream(new FileInputStream(base + lvl_name)));
			int levelWidth = stream.readInt();
			int levelHeight = stream.readInt();
			map = new int[levelWidth][levelHeight];
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
				map[x][y] = stream.readInt();
			}
			maps.put(lvl_name, map);
		}
		catch (FileNotFoundException e) {
			JOptionPane.showMessageDialog(null, "Die Lvl-Datei wurde nicht gefunden!", "Fehler....", JOptionPane.OK_OPTION);
			System.exit(0);
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public void loadHighscore(){
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new InputStreamReader(new FileInputStream(base + "highscore.score")));
			ArrayList<Score> scores = new ArrayList<Score>();
			for (;;) {
				String name = reader.readLine();
				String score = reader.readLine();
				if (name != null && score != null) scores.add(new Score(name, Integer.parseInt(score)));
				else break;
			}
			HighscoreList.getInstance().init(scores);
		}
		catch (Exception e) {
			
		}
		finally{
			try {
				if (reader != null) reader.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	@Override
	public void saveHighscore(Score unusedScore) {
		BufferedWriter writer = null;
		try {
			writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(base + "highscore.score")));
			for (int i = 0; i < HighscoreList.getInstance().getScores().size(); ++i) {
				Score score = HighscoreList.getInstance().getScores().get(i);
				writer.write(score.getName() + "\n");
				writer.write(String.valueOf(score.getScore()) + "\n");
			}
		}
		catch (Exception ex) {
			
		}
		finally {
			if (writer != null)
			try {
				writer.close();
			}
			catch (IOException e) {

			}
		}
	}

	@Override
	public Font loadFont(String name, int style, int size) {
		return new JavaFont(name, style, size);
	}
	
	@Override
	public void loadXml(String name) {
		xmls.put(name, new JavaNode(base + name));
	}

	@Override
	public void setNormalCursor() {
		Game.getInstance().setCursor(Cursor.getPredefinedCursor(Cursor.DEFAULT_CURSOR));
	}

	@Override
	public void setHandCursor() {
		Game.getInstance().setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
	}
}