package com.kontechs.kje.backends.java;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import javax.imageio.ImageIO;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.UnsupportedAudioFileException;
import javax.swing.JOptionPane;

import com.kontechs.kje.Loader;
import com.kontechs.kje.TileProperty;

public class JavaLoader extends Loader {
	public JavaImage loadImage(String filename) {
		try {
			return new JavaImage(ImageIO.read(new File("../data/" + filename + ".png")));
		}
		catch (IOException e) {
			return null;
		}
	}
	
	public JavaSound loadSound(String filename) {
		return new JavaSound("../../data/" + filename + ".wav");
	}
	
	public JavaMusic loadMusic(String filename) {
		try {
			return new JavaMusic(new File("../../data/" + filename + ".wav"));
		}
		catch (IOException e) {
			return null;
		}
		catch (UnsupportedAudioFileException e) {
			return null;
		}
		catch (LineUnavailableException e) {
			return null;
		}
	}
	
	public int[][] loadLevel(String lvl_name) {
		int[][] map;
		try {
			DataInputStream stream = new DataInputStream(new BufferedInputStream(new FileInputStream("../data/" + lvl_name)));
			int levelWidth = stream.readInt();
			int levelHeight = stream.readInt();
			map = new int[levelWidth][levelHeight];
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
				map[x][y] = stream.readInt();
			}
			return map;
		}
		catch (FileNotFoundException e) {
			JOptionPane.showMessageDialog(null, "Die Lvl-Datei wurde nicht gefunden!", "Fehler....", JOptionPane.OK_OPTION);
			System.exit(0);
			return null;
		}
		catch (IOException e) {
			return null;
		}
	}
	
	//TODO: Check
	public void loadHighscore(){
		String[][] highscore = new String[10][2];
		DataInputStream stream = null;
		try {
			stream = new DataInputStream(new BufferedInputStream(new FileInputStream("../data/highscore.score")));
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
		StartScreen.setHighscore(highscore);
	}
	
	//TODO: Check
	public TileProperty[] loadTilesProperties(String tilesPropertyName){
		TileProperty[] array_elements = null;
		DataInputStream stream_elements = null;
		try {
			stream_elements = new DataInputStream(new BufferedInputStream(
					new FileInputStream("../data/" + tilesPropertyName + ".settings")));

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
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				stream_elements.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return array_elements;
		
	}
}