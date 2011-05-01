package com.kontechs.kje.backends.gwt;

import com.google.gwt.user.client.rpc.AsyncCallback;
import com.kontechs.kje.TileProperty;

public interface LevelServiceAsync {
	void getLevel(String filename, AsyncCallback<int[][]> callback);
	void getTileset(String filename, AsyncCallback<TileProperty[]> callback);
}