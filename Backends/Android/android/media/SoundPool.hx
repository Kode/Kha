package android.media;

import android.media.SoundPoolOnLoadCompleteListener;
import android.content.res.AssetFileDescriptor;
import java.lang.Float;

extern class SoundPool {
	public function new(channels : Int, type : Int, loop : Int) : Void;
	public function load(file : AssetFileDescriptor, priority : Int) : Int;
	public function unload(soundId: Int): Bool;
	public function play(id : Int, leaftVolume : Float, rightVolume : Float, priority : Int, loop : Int, rate : Float) : Int;
	public function stop(id : Int): Void;
	public function pause(id: Int): Void;
	public function resume(id:Int): Void;
	public function setVolume(id: Int, leftVolume: Float, rightVolume: Float): Void;
	public function setOnLoadCompleteListener(listener: SoundPoolOnLoadCompleteListener): Void;
}