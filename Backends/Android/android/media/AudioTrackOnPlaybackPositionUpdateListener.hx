package android.media;

import android.media.AudioTrack;

@:native("android.media.AudioTrack.OnPlaybackPositionUpdateListener")
extern interface AudioTrackOnPlaybackPositionUpdateListener {
	function onMarkerReached(track: AudioTrack): Void;
	function onPeriodicNotification(track: AudioTrack): Void;
}
