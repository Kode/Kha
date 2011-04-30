package de.hsharz.game.client;

import com.google.gwt.user.client.rpc.AsyncCallback;

public interface GreetingServiceAsync {
	void getLevel(AsyncCallback<int[][]> callback);
}