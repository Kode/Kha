package com.kontechs.kje.backends.java;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import javax.imageio.ImageIO;
import javax.swing.JOptionPane;

import com.kontechs.kje.Font;
import com.kontechs.kje.Loader;
import com.kontechs.kje.TileProperty;

public class JavaLoader extends Loader {
	@Override
	public void loadImage(String name) {
		try {
			images.put(name, new JavaImage(ImageIO.read(new File("../../data/" + name + ".png"))));
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
	
	//TODO: Check
	public void loadHighscore(){
		String[][] highscore = new String[10][2];
		DataInputStream stream = null;
		try {
			stream = new DataInputStream(new BufferedInputStream(new FileInputStream("../../data/highscore.score")));
			for (int entry_index = 0; entry_index < 10; entry_index++)  {
				highscore[entry_index][0] = stream.readUTF();
				highscore[entry_index][1] = stream.readUTF();
			}
		}catch(FileNotFoundException e) {
			JOptionPane.showMessageDialog(null, "Die Highscore-Datei wurde nicht gefunden!", "Fehler....", JOptionPane.OK_OPTION);
			System.exit(0);
		}
		catch (IOException e) {
		}
		finally{
			try {
				stream.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		//StartScreen.setHighscore(highscore); //TODO
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
}