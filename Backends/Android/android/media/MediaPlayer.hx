package android.media;

import android.content.Context;
import android.view.SurfaceHolder;
import haxe.Int64;
import java.lang.Float;
import java.io.FileDescriptor;

extern class MediaPlayer {
	public function new() : Void;
	public static function create(context: Context, resid: Int): MediaPlayer;
	public function start() : Void;
	public function pause(): Void;
	public function stop() : Void;
	public function setLooping(b : Bool) : Void;
	public function prepare() : Void;
	public function release() : Void;
	public function setDataSource(descriptor : FileDescriptor, offset : Int, length : Int) : Void;
	public function setDisplay(display : SurfaceHolder) : Void;
	public function setVolume(leftVolume: Float, rightVolume: Float): Void;
	public function getCurrentPosition(): Int; // millisec
	public function getDuration(): Int; // millisec
	public function seekTo(msec: Int): Void;
	public function setOnCompletionListener(listener: MediaPlayerOnCompletionListener): Void;
}
