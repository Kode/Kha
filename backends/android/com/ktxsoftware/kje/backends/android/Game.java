package com.ktxsoftware.kje.backends.android;

import android.app.Activity;
import android.os.Bundle;
import android.view.Window;

public class Game extends Activity {

    private GameView mView;

    @Override
    protected void onCreate(Bundle icicle) {
        super.onCreate(icicle);
        //requestWindowFeature(Window.FEATURE_NO_TITLE);
        mView = new GameView(getApplication());
        setContentView(mView);
    }

    @Override
    protected void onPause() {
        super.onPause();
        mView.onPause();
    }

    @Override
    protected void onResume() {
        super.onResume();
        mView.onResume();
    }
    
    /*@Override
	public void onStop() {
		super.onStop();
		AndroidMusic.stopit();
		finish();
	}*/
}