package com.ktxsoftware.kje.backends.gwt;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.ktxsoftware.kje.Score;
import com.ktxsoftware.kje.TileProperty;

public interface LevelServiceAsync {
	void getLevel(String filename, AsyncCallback<int[][]> callback);
	void getTileset(String filename, AsyncCallback<TileProperty[]> callback);
	void getScores(AsyncCallback<ArrayList<Score>> callback);
	void addScore(Score score, AsyncCallback<Void> callback);
}