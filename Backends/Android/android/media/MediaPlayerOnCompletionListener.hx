package android.media;

import android.media.MediaPlayer;

@:native("android.media.MediaPlayer.OnCompletionListener")
extern interface MediaPlayerOnCompletionListener {
	public function onCompletion(mp: MediaPlayer): Void;
}