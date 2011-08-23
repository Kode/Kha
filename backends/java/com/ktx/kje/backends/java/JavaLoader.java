package com.ktx.kje.backends.java;

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

import com.ktx.kje.Font;
import com.ktx.kje.HighscoreList;
import com.ktx.kje.Loader;
import com.ktx.kje.Score;
import com.ktx.kje.TileProperty;

public class JavaLoader extends Loader {
	@Override
	public void loadImage(String name) {
		try {
			if (new File("../../data/" + name + ".png").exists())
				images.put(name, new JavaImage(ImageIO.read(new File("../../data/" + name + ".png"))));
			else
				images.put(name, new JavaImage(ImageIO.read(new File("../../data/" + name + ".jpg"))));
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public void loadSound(String name) {
		sounds.put(name, new JavaSound("../../data/" + name + ".wav"));
	}
	
	@Override
	public void loadMusic(String name) {
		try {
			musics.put(name, new JavaMusic(new File("../../data/" + name + ".wav")));
		}
		catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	@Override
	public void loadMap(String lvl_name) {
		try {
			int[][] map;
			DataInputStream stream = new DataInputStream(new BufferedInputStream(new FileInputStream("../../data/" + lvl_name)));
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
			reader = new BufferedReader(new InputStreamReader(new FileInputStream("../../data/highscore.score")));
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
			writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream("../../data/highscore.score")));
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
	public void loadTileset(String name){
		TileProperty[] array_elements = null;
		DataInputStream stream_elements = null;
		try {
			stream_elements = new DataInputStream(new BufferedInputStream(new FileInputStream("../../data/" + name + ".settings")));

			array_elements = new TileProperty[stream_elements.readInt()];
			for(int i = 0;i<array_elements.length;i++){
				array_elements[i] = new TileProperty();
			}
			for (int i = 0; i < array_elements.length; i++) {
				array_elements[i].setCollides(stream_elements.readBoolean());
				array_elements[i].setEnemy(stream_elements.readBoolean());
				array_elements[i].setEnemyTyp(stream_elements.readUTF());
				array_elements[i].setSeasonMode(stream_elements.readInt());
				array_elements[i].setLinkedTile(stream_elements.readInt());
			}
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		finally {
			try {
				stream_elements.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
		tilesets.put(name, array_elements);
	}

	@Override
	public Font loadFont(String name, int style, int size) {
		return new JavaFont(name, style, size);
	}
	
	@Override
	public void loadXml(String name) {
		xmls.put(name, new JavaNode("../../data/" + name + ".icml"));
	}
}