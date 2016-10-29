package android.media;

import android.content.Context;
import android.view.SurfaceHolder;
import java.lang.Float;

extern class MediaPlayer {
	public function new() : Void;
	public static function create(context: Context, resid: Int): MediaPlayer;
	public function start() : Void;
	public function stop() : Void;
	public function setLooping(b : Bool) : Void;
	public function prepare() : Void;
	public function release() : Void;
	public function setDataSource(descriptor : String, offset : Int, length : Int) : Void;
	public function setDisplay(display : SurfaceHolder) : Void;
	public function setVolume(leftVolume: Float, rightVolume: Float): Void;
}
