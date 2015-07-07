package android.app;

import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import java.lang.Object;
import java.lang.Runnable;

extern class Activity extends Context {
	public function new(): Void;
	public function onCreate(savedInstanceState: Bundle): Void;
	public function getWindow(): Window;
	public function onConfigurationChanged(newConfig: Configuration): Void;
	public function getApplicationContext(): Context;
	public function getSystemService(name: String): Object;
	public function runOnUiThread(action: Runnable): Void;
	function onStart(): Void;
	function onResume(): Void;
	function onPause(): Void;
	function onStop(): Void;
	function onDestroy(): Void;
	function onRestart(): Void;
	function requestWindowFeature(feature: Int): Void;
	function setContentView(view: View): Void;
	function finish(): Void;
}
