package android.media;

import android.media.SoundPool;

@:native("android.media.SoundPool.OnLoadCompleteListener")
extern interface SoundPoolOnLoadCompleteListener {
	public function onLoadComplete(soundPool: SoundPool, sampleId: Int, status:Int): Void;
}