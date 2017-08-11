package android.media;

import android.media.AudioTrack;

@:native("android.media.AudioTrack.OnPlaybackPositionUpdateListener")
extern interface AudioTrackOnPlaybackPositionUpdateListener {
	public function onMarkerReached(track: AudioTrack): Void;
	public function onPeriodicNotification(track: AudioTrack): Void;
}