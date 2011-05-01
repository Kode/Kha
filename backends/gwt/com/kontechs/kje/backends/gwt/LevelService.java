package com.kontechs.kje.backends.gwt;

import com.google.gwt.user.client.rpc.RemoteService;
import com.google.gwt.user.client.rpc.RemoteServiceRelativePath;
import com.kontechs.kje.TileProperty;

@RemoteServiceRelativePath("level")
public interface LevelService extends RemoteService {
	int[][] getLevel(String filename);
	TileProperty[] getTileset(String filename);
}