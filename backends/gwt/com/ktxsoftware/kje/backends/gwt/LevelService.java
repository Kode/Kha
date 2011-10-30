package com.ktxsoftware.kje.backends.gwt;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.ktxsoftware.kje.Score;

@RemoteServiceRelativePath("level")
public interface LevelService extends RemoteService {
	int[][] getLevel(String filename);
	//TileProperty[] getTileset(String filename);
	ArrayList<Score> getScores();
	void addScore(Score score);
}