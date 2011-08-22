package com.ktx.kje.backends.gwt;

import java.util.ArrayList;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.ktx.kje.Score;
import com.ktx.kje.TileProperty;

public interface LevelServiceAsync {
	void getLevel(String filename, AsyncCallback<int[][]> callback);
	void getTileset(String filename, AsyncCallback<TileProperty[]> callback);
	void getScores(AsyncCallback<ArrayList<Score>> callback);
	void addScore(Score score, AsyncCallback<Void> callback);
}