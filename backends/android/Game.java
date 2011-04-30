package de.hsharz.game;

import android.app.Activity;
import android.os.Bundle;
import android.view.Window;
import android.widget.LinearLayout;

public class Game extends Activity {
	private LinearLayout layout;

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		layout = new LinearLayout(this);
		layout.addView(new GameView(this));
		setContentView(layout);
	}
	
	@Override
	public void onStop() {
		super.onStop();
		AndroidMusic.stopit();
		finish();
	}
}