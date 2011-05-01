package com.kontechs.kje_server;

import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

import com.google.gwt.user.server.rpc.RemoteServiceServlet;
import com.kontechs.kje.TileProperty;
import com.kontechs.kje.backends.gwt.LevelService;

@SuppressWarnings("serial")
public class LevelServiceImpl extends RemoteServiceServlet implements LevelService {	
	public int[][] getLevel(String filename) {
		int[][] map;
		try {
			DataInputStream stream = new DataInputStream(new BufferedInputStream(new FileInputStream(filename)));
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

	@Override
	public TileProperty[] getTileset(String filename) {
		TileProperty[] array_elements = null;
		DataInputStream stream_elements = null;
		try {
			stream_elements = new DataInputStream(new BufferedInputStream(
					new FileInputStream(filename + ".settings")));

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