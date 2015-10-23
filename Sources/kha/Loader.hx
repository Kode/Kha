package kha;

@:build(kha.LoaderBuilder.build())
class Loader {
	/**
	 * Loads an image by name which was preprocessed by khamake.
	 * 
	 * @param	name The name as defined by the khafile.
	 * @param	done A callback.
	 */
	public static function loadImage(name: String, done: Image -> Void): Void {
		var description = Reflect.field(Loader, "image_" + name);
		LoaderImpl.loadImageFromDescription(description, done);
	}
	
	/**
	 * Loads an image from a path. Most targets support PNG and JPEG formats.
	 * 
	 * @param	path The path to the image file.
	 * @param   readable If true, a copy of the image will be kept in main memory for image read operations.
	 * @param	done A callback.
	 */
	public static function loadImageFromPath(path: String, readable: Bool, done: Image -> Void): Void {
		var description = { file: path, readable: readable };
		LoaderImpl.loadImageFromDescription(description, done);
	}
	
	public static function loadBlob(name: String, done: Blob -> Void): Void {
		var description = Reflect.field(Loader, "blob_" + name);
		LoaderImpl.loadBlobFromDescription(description, done);
	}
	
	public static function loadBlobFromPath(path: String, done: Blob -> Void): Void {
		var description = { file: path };
		LoaderImpl.loadBlobFromDescription(description, done);
	}
	
	public static function loadMusic(name: String, done: Music -> Void): Void {
		var description = Reflect.field(Loader, "music_" + name);
		return LoaderImpl.loadMusicFromDescription(description, done);
	}
	
	public static function loadMusicFromPath(path: String, done: Music -> Void): Void {
		var description = { file: path };
		return LoaderImpl.loadMusicFromDescription(description, done);
	}
	
	public static function loadSound(name: String, done: Sound -> Void): Void {
		var description = Reflect.field(Loader, "sound_" + name);
		return LoaderImpl.loadSoundFromDescription(description, done);
	}
	
	public static function loadSoundFromPath(path: String, done: Sound -> Void): Void {
		var description = { file: path };
		return LoaderImpl.loadSoundFromDescription(description, done);
	}
	
	public static function loadVideo(name: String, done: Video -> Void): Void {
		var description = Reflect.field(Loader, "video_" + name);
		return LoaderImpl.loadVideoFromDescription(description, done);
	}
	
	public static function loadVideoFromPath(path: String, done: Video -> Void): Void {
		var description = { file: path };
		return LoaderImpl.loadVideoFromDescription(description, done);
	}
	
	public static function loadFont(name: String, style: FontStyle, size: Float, done: Font -> Void): Void {
		Kravur.load(name, style, size, done);
	}
	
	public static function getShader(name: String): Blob {
		return null;
	}
}
