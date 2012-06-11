package android.media;

import android.content.res.AssetFileDescriptor;

extern class SoundPool {
	public function new(channels : Int, type : Int, unknown : Int) : Void;
	public function load(file : AssetFileDescriptor, unknown : Int) : Int;
	public function play(id : Int, unknown0 : Int, unknown1 : Int, unknown2 : Int, unknown3 : Int, unknown4 : Int) : Void;
	public function stop(id : Int) : Void;
}