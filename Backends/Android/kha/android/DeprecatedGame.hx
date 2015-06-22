package kha.android;

import android.app.Activity;
import android.widget.LinearLayout;
import android.os.Bundle;
import android.view.Window;

class DeprecatedGame extends Activity {
	var layout : LinearLayout;

	override public function onCreate(savedInstanceState : Bundle) : Void {
		super.onCreate(savedInstanceState);
	}
	
	override public function onStart() : Void {
		super.onStart();
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		layout = new LinearLayout(this);
		layout.addView(new GameView(this));
		setContentView(layout);
	}
	
	override public function onResume() : Void {
		super.onResume();
	}

	override public function onPause() : Void {
		super.onPause();
	}

	override public function onStop() : Void {
		super.onStop();
		Music.stopit();
		setContentView(new LinearLayout(this));
		layout = null;
		finish();
	}

	override public function onDestroy() : Void {
		super.onDestroy();
	}
	
	public static function main() : Void {
		
	}
}