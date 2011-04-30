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

import com.kontechs.kje.Loader;

public class JavaLoader extends Loader {
	public JavaImage loadImage(String filename) {
		try {
			return new JavaImage(ImageIO.read(new File("../../data/" + filename + ".png")));
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
	
	public int[][] loadLevel() {
		int[][] map;
		try {
			DataInputStream stream = new DataInputStream(new BufferedInputStream(new FileInputStream("../../data/level.map")));
			int levelWidth = stream.readInt();
			int levelHeight = stream.readInt();
			map = new int[levelWidth][levelHeight];
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
				map[x][y] = stream.readInt();
			}
			return map;
		}
		catch (FileNotFoundException e) {
			return null;
		}
		catch (IOException e) {
			return null;
		}
	}
}