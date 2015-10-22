package kha;

@:build(kha.LoaderBuilder.build())
class Loader {
	public static function loadImage(name: String, done: Image -> Void): Void {
		var description = Reflect.field(Loader, "image_" + name);
		LoaderImpl.loadImageFromDescription(description, done);
	}
	
	public static function loadBlob(name: String, done: Blob -> Void): Void {
		var description = Reflect.field(Loader, "blob_" + name);
		LoaderImpl.loadBlobFromDescription(description, done);
	}
	
	public static function loadMusic(name: String, done: Music -> Void): Void {
		var description = Reflect.field(Loader, "music_" + name);
		return LoaderImpl.loadMusicFromDescription(description, done);
	}
	
	public static function loadSound(name: String, done: Sound -> Void): Void {
		var description = Reflect.field(Loader, "sound_" + name);
		return LoaderImpl.loadSoundFromDescription(description, done);
	}
	
	public static function loadVideo(name: String, done: Video -> Void): Void {
		var description = Reflect.field(Loader, "video_" + name);
		return LoaderImpl.loadVideoFromDescription(description, done);
	}
	
	public static function loadFont(name: String, style: FontStyle, size: Float, done: Font -> Void): Void {
		Kravur.load(name, style, size, done);
	}
	
	public static function getShader(name: String): Blob {
		return null;
	}
}
