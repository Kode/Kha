package android.media;

import android.media.SoundPool;

@:native("android.media.SoundPool.OnLoadCompleteListener")
extern interface SoundPoolOnLoadCompleteListener {
	function onLoadComplete(soundPool: SoundPool, sampleId: Int, status: Int): Void;
}
