package kha;

import haxe.io.Bytes;
import haxe.Unserializer;

@:build(kha.internal.LoaderBuilder.build("image"))
class LoaderImages {
	public function new() {
		
	}
}

@:build(kha.internal.LoaderBuilder.build("sound"))
class LoaderSounds {
	public function new() {
		
	}
}

@:build(kha.internal.LoaderBuilder.build("music"))
class LoaderMusic {
	public function new() {
		
	}
}

@:build(kha.internal.LoaderBuilder.build("blob"))
class LoaderBlobs {
	public function new() {
		
	}
}

@:build(kha.internal.LoaderBuilder.build("video"))
class LoaderVideos {
	public function new() {
		
	}
}

@:build(kha.LoaderBuilder.build())
class Loader {
	public static var images: LoaderImages = new LoaderImages();
	public static var sounds: LoaderSounds = new LoaderSounds();
	public static var music: LoaderMusic = new LoaderMusic();
	public static var blobs: LoaderBlobs = new LoaderBlobs();
	public static var videos: LoaderVideos = new LoaderVideos();
		
	/**
	 * Loads an image by name which was preprocessed by khamake.
	 * 
	 * @param	name The name as defined by the khafile.
	 * @param	done A callback.
	 */
	public static function loadImage(name: String, done: Image -> Void): Void {
		var description = Reflect.field(images, name + "Description");
		LoaderImpl.loadImageFromDescription(description, function (image: Image) {
			Reflect.setField(images, name, image);
			done(image);
		});
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
		var description = Reflect.field(blobs, name + "Description");
		LoaderImpl.loadBlobFromDescription(description, function (blob: Blob) {
			Reflect.setField(blobs, name, blob);
			done(blob);
		});
	}
	
	public static function loadBlobFromPath(path: String, done: Blob -> Void): Void {
		var description = { file: path };
		LoaderImpl.loadBlobFromDescription(description, done);
	}
	
	public static function loadMusic(name: String, done: Music -> Void): Void {
		var description = Reflect.field(music, name + "Description");
		return LoaderImpl.loadMusicFromDescription(description, function (m: Music) {
			Reflect.setField(music, name, m);
			done(m);
		});
	}
	
	public static function loadMusicFromPath(path: String, done: Music -> Void): Void {
		var description = { file: path };
		return LoaderImpl.loadMusicFromDescription(description, done);
	}
	
	public static function loadSound(name: String, done: Sound -> Void): Void {
		var description = Reflect.field(sounds, name + "Description");
		return LoaderImpl.loadSoundFromDescription(description, function (sound: Sound) {
			Reflect.setField(sounds, name, sound);
			done(sound);
		});
	}
	
	public static function loadSoundFromPath(path: String, done: Sound -> Void): Void {
		var description = { file: path };
		return LoaderImpl.loadSoundFromDescription(description, done);
	}
	
	public static function loadVideo(name: String, done: Video -> Void): Void {
		var description = Reflect.field(videos, name + "Description");
		return LoaderImpl.loadVideoFromDescription(description, function (video: Video) {
			Reflect.setField(videos, name, video);
			done(video);
		});
	}
	
	public static function loadVideoFromPath(path: String, done: Video -> Void): Void {
		var description = { file: path };
		return LoaderImpl.loadVideoFromDescription(description, done);
	}
	
	public static function loadFont(name: String, style: FontStyle, size: Float, done: Font -> Void): Void {
		Kravur.load(name, style, size, done);
	}
	
	public static function getShader(name: String): Blob {
		var description = Reflect.field(Loader, "shader_" + name);
		var bytes: Bytes = Unserializer.run(description.content);
		return new Blob(bytes);
	}
}
