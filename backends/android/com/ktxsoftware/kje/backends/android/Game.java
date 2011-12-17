package com.ktxsoftware.kje.backends.android;

import android.app.Activity;
import android.os.Bundle;
import android.view.Window;
import android.widget.LinearLayout;

public class Game extends Activity {
	private LinearLayout layout;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}
	
	@Override
	protected void onStart() {
		super.onStart();
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		layout = new LinearLayout(this);
		layout.addView(new GameView(this));
		setContentView(layout);
	}
	
	@Override
	protected void onResume() {
		super.onResume();
	}
	
	@Override
	protected void onPause() {
		super.onPause();
	}

	@Override
	protected void onStop() {
		super.onStop();
		AndroidMusic.stopit();
		setContentView(new LinearLayout(this));
		layout = null;
		finish();
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
	}
}