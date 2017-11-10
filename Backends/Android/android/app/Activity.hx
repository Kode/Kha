package android.app;

import android.content.Context;
import android.content.Intent;
import android.content.IntentSender;
import android.content.ServiceConnection;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import java.lang.Object;
import java.lang.Runnable;

extern class Activity extends Context {
    public static var RESULT_CANCELED: Int;
    public static var RESULT_OK: Int;
	
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
	@:protected function onActivityResult(requestCode:Int, resultCode:Int, data:Intent): Void;
	function requestWindowFeature(feature: Int): Void;
	function setContentView(view: View): Void;
	function finish(): Void;
	
	function bindService(service: Intent, conn: ServiceConnection, flags: Int): Bool;
	function unbindService(conn: ServiceConnection): Void;
	
	function getPackageName(): String;
	
	@:throws("android.content.IntentSender.SendIntentException")
	function startIntentSenderForResult(intent: IntentSender, requestCode: Int, fillInIntent: Intent, flagsMask: Int, flagsValues: Int, extraFlags: Int): Void;
	
	function startActivity (intent: Intent): Void;

    function onWindowFocusChanged(hasFocus: Bool): Void;
}
