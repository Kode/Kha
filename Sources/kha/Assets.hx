package kha;

import haxe.io.Bytes;
import haxe.Unserializer;

using StringTools;

@:build(kha.internal.AssetsBuilder.build("image"))
@:keep
private class ImageList {
	public function new() {

	}

	public function get(name: String): Image {
		return Reflect.field(this, name);
	}
}

@:build(kha.internal.AssetsBuilder.build("sound"))
@:keep
private class SoundList {
	public function new() {

	}

	public function get(name: String): Sound {
		return Reflect.field(this, name);
	}
}

@:build(kha.internal.AssetsBuilder.build("blob"))
@:keep
private class BlobList {
	public function new() {

	}

	public function get(name: String): Blob {
		return Reflect.field(this, name);
	}
}

@:build(kha.internal.AssetsBuilder.build("font"))
@:keep
private class FontList {
	public function new() {

	}

	public function get(name: String): Font {
		return Reflect.field(this, name);
	}
}

@:build(kha.internal.AssetsBuilder.build("video"))
@:keep
private class VideoList {
	public function new() {

	}

	public function get(name: String): Video {
		return Reflect.field(this, name);
	}
}

class Assets {
	public static var images: ImageList = new ImageList();
	public static var sounds: SoundList = new SoundList();
	public static var blobs: BlobList = new BlobList();
	public static var fonts: FontList = new FontList();
	public static var videos: VideoList = new VideoList();

	/**
	 * Moves from 0 to 1. Use for loading screens.
	 */
	public static var progress: Float;

	/**
	Loads all assets which were detected by khamake. When running khamake (doing so is Kha's standard build behavior)
	it creates a files.json in the build/{target}-resources directoy which contains information about all assets which were found.

	The `callback` parameter is always called after loading, even when some or all assets had failures.

	An optional callback parameter `failed` is called for each asset that failed to load.

	The filter parameter can be used to load assets selectively. The Dynamic parameter describes the asset,
	it contains the very same objects which are listed in files.json.

	Additionally by default all sounds are decompressed. The uncompressSoundsFilter can be used to avoid that.
	Uncompressed sounds can still be played using Audio.stream which is recommended for music.
	*/
	public static function loadEverything(callback: Void->Void, filter: Dynamic->Bool = null, uncompressSoundsFilter: Dynamic->Bool = null, ?failed: AssetError -> Void): Void {
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

		function onLoaded() {
			--filesLeft;
			progress = 1 - filesLeft / fileCount;
			if (filesLeft == 0) callback();
		}

		for (blob in Type.getInstanceFields(BlobList)) {
			if (blob.endsWith("Load")) {
				var name = blob.substr(0, blob.length - 4);
				var description = Reflect.field(blobs, name + "Description");

				if (filter == null || filter(description)) {
					Reflect.field(blobs, blob)(onLoaded, function(err) {
						reporter(failed)(err);
						onLoaded();
					});
				}
				else {
					onLoaded();
				}
			}
		}
		for (image in Type.getInstanceFields(ImageList)) {
			if (image.endsWith("Load")) {
				var name = image.substr(0, image.length - 4);
				var description = Reflect.field(images, name + "Description");

				if (filter == null || filter(description)) {
					Reflect.field(images, image)(onLoaded, function(err) {
						reporter(failed)(err);
						onLoaded();
					});
				}
				else {
					onLoaded();
				}
			}
		}
		for (sound in Type.getInstanceFields(SoundList)) {
			if (sound.endsWith("Load")) {
				var name = sound.substr(0, sound.length - 4);
				var description = Reflect.field(sounds, name + "Description");
				if (filter == null || filter(description)) {
					Reflect.field(sounds, sound)(function () {
						if (uncompressSoundsFilter == null || uncompressSoundsFilter(description)) {
							var sound: Sound = Reflect.field(sounds, sound.substring(0, sound.length - 4));
							sound.uncompress(onLoaded);
						}
						else {
							onLoaded();
						}
					}, function(err) {
						reporter(failed)(err);
						onLoaded();
					});
				}
				else {
					onLoaded();
				}
			}
		}
		for (font in Type.getInstanceFields(FontList)) {
			if (font.endsWith("Load")) {
				var name = font.substr(0, font.length - 4);
				var description = Reflect.field(fonts, name + "Description");
				if (filter == null || filter(description)) {
					Reflect.field(fonts, font)(onLoaded, function(err) {
						reporter(failed)(err);
						onLoaded();
					});
				}
				else {
					onLoaded();
				}
			}
		}
		for (video in Type.getInstanceFields(VideoList)) {
			if (video.endsWith("Load")) {
				var name = video.substr(0, video.length - 4);
				var description = Reflect.field(videos, name + "Description");
				if (filter == null || filter(description)) {
					Reflect.field(videos, video)(onLoaded, function(err) {
						reporter(failed)(err);
						onLoaded();
					});
				}
				else {
					onLoaded();
				}
			}
		}
	}

	/**
	 * Loads an image by name which was preprocessed by khamake.
	 *
	 * @param	name The name as defined by the khafile.
	 * @param	done A callback.
	 */
	public static function loadImage(name: String, done: Image -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
		var description = Reflect.field(images, name + "Description");
		LoaderImpl.loadImageFromDescription(description, function (image: Image) {
			Reflect.setField(images, name, image);
			done(image);
		}, reporter(failed, pos));
	}

	/**
	 * Loads an image from a path. Most targets support PNG and JPEG formats.
	 *
	 * @param	path The path to the image file.
	 * @param   readable If true, a copy of the image will be kept in main memory for image read operations.
	 * @param	done A callback.
	 */
	public static function loadImageFromPath(path: String, readable: Bool, done: Image -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
		var description = { files: [ path ], readable: readable };
		LoaderImpl.loadImageFromDescription(description, done, reporter(failed, pos));
	}

	public static var imageFormats(get, null): Array<String>;

	private static function get_imageFormats(): Array<String> {
		return LoaderImpl.getImageFormats();
	}

	public static function loadBlob(name: String, done: Blob -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
		var description = Reflect.field(blobs, name + "Description");
		LoaderImpl.loadBlobFromDescription(description, function (blob: Blob) {
			Reflect.setField(blobs, name, blob);
			done(blob);
		}, reporter(failed, pos));
	}

	public static function loadBlobFromPath(path: String, done: Blob -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
		var description = { files: [ path ] };
		LoaderImpl.loadBlobFromDescription(description, done, reporter(failed, pos));
	}

	public static function loadSound(name: String, done: Sound -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
		var description = Reflect.field(sounds, name + "Description");
		return LoaderImpl.loadSoundFromDescription(description, function (sound: Sound) {
			Reflect.setField(sounds, name, sound);
			done(sound);
		}, reporter(failed, pos));
	}

	public static function loadSoundFromPath(path: String, done: Sound -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
		var description = { files: [ path ] };
		return LoaderImpl.loadSoundFromDescription(description, done, reporter(failed, pos));
	}

	public static var soundFormats(get, null): Array<String>;

	private static function get_soundFormats(): Array<String> {
		return LoaderImpl.getSoundFormats();
	}

	public static function loadFont(name: String, done: Font -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
		var description = Reflect.field(fonts, name + "Description");
		return LoaderImpl.loadFontFromDescription(description, function (font: Font) {
			Reflect.setField(fonts, name, font);
			done(font);
		}, reporter(failed, pos));
	}

	public static function loadFontFromPath(path: String, done: Font -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
		var description = { files: [ path ] };
		return LoaderImpl.loadFontFromDescription(description, done, reporter(failed, pos));
	}

	public static var fontFormats(get, null): Array<String>;

	private static function get_fontFormats(): Array<String> {
		return ["ttf"];
	}

	public static function loadVideo(name: String, done: Video -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
		var description = Reflect.field(videos, name + "Description");
		return LoaderImpl.loadVideoFromDescription(description, function (video: Video) {
			Reflect.setField(videos, name, video);
			done(video);
		}, reporter(failed, pos));
	}

	public static function loadVideoFromPath(path: String, done: Video -> Void, ?failed: AssetError -> Void, ?pos: haxe.PosInfos): Void {
		var description = { files: [ path ] };
		return LoaderImpl.loadVideoFromDescription(description, done, reporter(failed, pos));
	}

	public static var videoFormats(get, null): Array<String>;

	private static function get_videoFormats(): Array<String> {
		return LoaderImpl.getVideoFormats();
	}

	public static inline function reporter(custom: AssetError -> Void, ?pos: haxe.PosInfos)
		return custom != null ? custom : haxe.Log.trace.bind(_, pos);
}
