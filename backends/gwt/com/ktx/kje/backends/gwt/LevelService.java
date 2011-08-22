package com.ktx.kje.backends.gwt;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.ktx.kje.Score;
import com.ktx.kje.TileProperty;

@RemoteServiceRelativePath("level")
public interface LevelService extends RemoteService {
	int[][] getLevel(String filename);
	TileProperty[] getTileset(String filename);
	ArrayList<Score> getScores();
	void addScore(Score score);
}