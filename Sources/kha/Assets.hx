package kha;

import haxe.io.Bytes;
import haxe.Unserializer;

using StringTools;

@:build(kha.internal.AssetsBuilder.build("image"))
class ImageList {
	public function new() {
		
	}
}

@:build(kha.internal.AssetsBuilder.build("sound"))
class SoundList {
	public function new() {
		
	}
}

@:build(kha.internal.AssetsBuilder.build("blob"))
class BlobList {
	public function new() {
		
	}
}

@:build(kha.internal.AssetsBuilder.build("font"))
class FontList {
	public function new() {
		
	}
}

@:build(kha.internal.AssetsBuilder.build("video"))
class VideoList {
	public function new() {
		
	}
}

class Assets {
	public static var images: ImageList = new ImageList();
	public static var sounds: SoundList = new SoundList();
	public static var blobs: BlobList = new BlobList();
	public static var fonts: FontList = new FontList();
	public static var videos: VideoList = new VideoList();
	
	public static var progress: Float; // moves from 0 to 1, use for loading screens

	public static function loadEverything(callback: Void -> Void): Void {
		var fileCount = 0;
		for (blob in Type.getInstanceFields(BlobList)) {
			if (blob.endsWith("Load")) {
				++fileCount;
			}
		}
		for (image in Type.getInstanceFields(ImageList)) {
			if (image.endsWith("Load")) {
				++fileCount;
			}
		}
		for (sound in Type.getInstanceFields(SoundList)) {
			if (sound.endsWith("Load")) {
				++fileCount;
			}
		}
		for (font in Type.getInstanceFields(FontList)) {
			if (font.endsWith("Load")) {
				++fileCount;
			}
		}
		for (video in Type.getInstanceFields(VideoList)) {
			if (video.endsWith("Load")) {
				++fileCount;
			}
		}
		
		if (fileCount == 0) {
			callback();
			return;
		}

		var filesLeft = fileCount;
		
		for (blob in Type.getInstanceFields(BlobList)) {
			if (blob.endsWith("Load")) {
				Reflect.field(blobs, blob)(function () {
					--filesLeft;
					progress = 1 - filesLeft / fileCount;
					if (filesLeft == 0) callback();
				});
			}
		}
		for (image in Type.getInstanceFields(ImageList)) {
			if (image.endsWith("Load")) {
				Reflect.field(images, image)(function () {
					--filesLeft;
					progress = 1 - filesLeft / fileCount;
					if (filesLeft == 0) callback();
				});
			}
		}
		for (sound in Type.getInstanceFields(SoundList)) {
			if (sound.endsWith("Load")) {
				Reflect.field(sounds, sound)(function () {
					var sound: Sound = Reflect.field(sounds, sound.substring(0, sound.length - 4));
					sound.uncompress(function () {
						--filesLeft;
						progress = 1 - filesLeft / fileCount;
						if (filesLeft == 0) callback();
					});
				});
			}
		}
		for (font in Type.getInstanceFields(FontList)) {
			if (font.endsWith("Load")) {
				Reflect.field(fonts, font)(function () {
					--filesLeft;
					progress = 1 - filesLeft / fileCount;
					if (filesLeft == 0) callback();
				});
			}
		}
		for (video in Type.getInstanceFields(VideoList)) {
			if (video.endsWith("Load")) {
				Reflect.field(videos, video)(function () {
					--filesLeft;
					progress = 1 - filesLeft / fileCount;
					if (filesLeft == 0) callback();
				});
			}
		}
	}
		
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
		var description = { files: [ path ], readable: readable };
		LoaderImpl.loadImageFromDescription(description, done);
	}
	
	public static var imageFormats(get, null): Array<String>;
	
	private static function get_imageFormats(): Array<String> {
		return LoaderImpl.getImageFormats();
	}
	
	public static function loadBlob(name: String, done: Blob -> Void): Void {
		var description = Reflect.field(blobs, name + "Description");
		LoaderImpl.loadBlobFromDescription(description, function (blob: Blob) {
			Reflect.setField(blobs, name, blob);
			done(blob);
		});
	}
	
	public static function loadBlobFromPath(path: String, done: Blob -> Void): Void {
		var description = { files: [ path ] };
		LoaderImpl.loadBlobFromDescription(description, done);
	}
	
	public static function loadSound(name: String, done: Sound -> Void): Void {
		var description = Reflect.field(sounds, name + "Description");
		return LoaderImpl.loadSoundFromDescription(description, function (sound: Sound) {
			Reflect.setField(sounds, name, sound);
			done(sound);
		});
	}
	
	public static function loadSoundFromPath(path: String, done: Sound -> Void): Void {
		var description = { files: [ path ] };
		return LoaderImpl.loadSoundFromDescription(description, done);
	}
	
	public static var soundFormats(get, null): Array<String>;
	
	private static function get_soundFormats(): Array<String> {
		return LoaderImpl.getSoundFormats();
	}
	
	public static function loadFont(name: String, done: Font -> Void): Void {
		var description = Reflect.field(fonts, name + "Description");
		return LoaderImpl.loadFontFromDescription(description, function (font: Font) {
			Reflect.setField(fonts, name, font);
			done(font);
		});
	}
	
	public static function loadFontFromPath(path: String, done: Font -> Void): Void {
		var description = { files: [ path ] };
		return LoaderImpl.loadFontFromDescription(description, done);
	}
	
	public static var fontFormats(get, null): Array<String>;
	
	private static function get_fontFormats(): Array<String> {
		return ["ttf"];
	}
	
	public static function loadVideo(name: String, done: Video -> Void): Void {
		var description = Reflect.field(videos, name + "Description");
		return LoaderImpl.loadVideoFromDescription(description, function (video: Video) {
			Reflect.setField(videos, name, video);
			done(video);
		});
	}
	
	public static function loadVideoFromPath(path: String, done: Video -> Void): Void {
		var description = { files: [ path ] };
		return LoaderImpl.loadVideoFromDescription(description, done);
	}
	
	public static var videoFormats(get, null): Array<String>;
	
	private static function get_videoFormats(): Array<String> {
		return LoaderImpl.getVideoFormats();
	}
}
