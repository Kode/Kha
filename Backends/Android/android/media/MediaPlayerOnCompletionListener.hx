package android.media;

import android.media.MediaPlayer;

@:native("android.media.MediaPlayer.OnCompletionListener")
extern interface MediaPlayerOnCompletionListener {
	function onCompletion(mp: MediaPlayer): Void;
}
