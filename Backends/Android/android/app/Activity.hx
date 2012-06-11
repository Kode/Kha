package android.app;

import android.content.Context;
import android.os.Bundle;
import android.view.View;

extern class Activity extends Context {
	public function new() : Void;
	public function onCreate(savedInstanceState : Bundle) : Void;
	function onStart() : Void;
	function onResume() : Void;
	function onPause() : Void;
	function onStop() : Void;
	function onDestroy() : Void;
	function requestWindowFeature(feature : Int) : Void;
	function setContentView(view : View) : Void;
	function finish() : Void;
}