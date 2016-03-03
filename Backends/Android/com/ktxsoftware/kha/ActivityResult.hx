package com.ktxsoftware.kha;

import android.content.Intent;

interface ActivityResult {
	public function onResult(requestCode:Int, resultCode:Int, data:Intent):Void;
}