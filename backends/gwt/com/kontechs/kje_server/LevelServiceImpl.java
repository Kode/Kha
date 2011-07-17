package com.kontechs.kje_server;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Comparator;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.kontechs.kje.GameInfo;
import com.kontechs.kje.Score;
import com.kontechs.kje.TileProperty;
import com.kontechs.kje.backends.gwt.LevelService;

@SuppressWarnings("serial")
public class LevelServiceImpl extends RemoteServiceServlet implements LevelService {
	private static String directory;
	
	{
		if (isOnline()) directory = GameInfo.dataDir();
		else directory = "";
	}
	
	private static boolean isOnline() {
		return System.getProperty("os.name").contains("Server");
	}
	
	public int[][] getLevel(String filename) {
		int[][] map;
		try {
			DataInputStream stream = new DataInputStream(new BufferedInputStream(new FileInputStream(directory + filename)));
			int levelWidth = stream.readInt();
			int levelHeight = stream.readInt();
			map = new int[levelWidth][levelHeight];
			for (int x = 0; x < levelWidth; ++x) for (int y = 0; y < levelHeight; ++y) {
				map[x][y] = stream.readInt();
			}
			return map;
		}
		catch (Exception e) {
			e.printStackTrace();
			return null;
		}
	}

	@Override
	public TileProperty[] getTileset(String filename) {
		TileProperty[] array_elements = null;
		DataInputStream stream_elements = null;
		try {
			stream_elements = new DataInputStream(new BufferedInputStream(new FileInputStream(directory + filename + ".settings")));

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
		}
		finally {
			try {
				stream_elements.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
		return array_elements;
	}
	
	private synchronized ArrayList<Score> getScores(int count) {
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new InputStreamReader(new FileInputStream(directory + "highscore.score")));
			ArrayList<Score> scores = new ArrayList<Score>();
			for (int i = 0; i < count; ++i) {
				String name = reader.readLine();
				String score = reader.readLine();
				if (name != null && score != null) scores.add(new Score(name, Integer.parseInt(score)));
				else break;
			}
			return scores;
		}
		catch (Exception e) {
			//e.printStackTrace();
		}
		finally{
			try {
				if (reader != null) reader.close();
			}
			catch (IOException e) {
				e.printStackTrace();
			}
		}
		return new ArrayList<Score>();
	}

	@Override
	public synchronized ArrayList<Score> getScores() {
		return getScores(10);
	}
	
	private void sortScores(ArrayList<Score> scores) {
		Comparator<Score> comparator = new Comparator<Score>() {
			@Override
			public int compare(Score score1, Score score2) {
				return score2.getScore() - score1.getScore();
			}
		};
		java.util.Collections.sort(scores, comparator);
	}

	@Override
	public synchronized void addScore(Score score) {
		ArrayList<Score> scores = getScores(100);
		scores.add(score);
		sortScores(scores);
		
		BufferedWriter writer = null;
		try {
			writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(directory + "highscore.score")));
			for (int i = 0; i < scores.size(); ++i) {
				writer.write(scores.get(i).getName() + "\n");
				writer.write(String.valueOf(scores.get(i).getScore()) + "\n");
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
}