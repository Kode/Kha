package kha;

import haxe.Unserializer;
import haxe.io.Bytes;

using StringTools;

private typedef AssetDataObject = {
	/** File name, given by khamake, used as identifier in `Assets.someList.get()` function **/
	var name: String;

	/** List of file paths, unified by khamake to single file with `name`. **/
	var files: Array<String>;

	/** File sizes in bytes **/
	var file_sizes: Array<Int>;

	/** Can be `image`, `sound`, `blob`, `font` and `video` **/
	var type: String;

	/** Original file width (only for images) **/
	var ?original_width: Int;

	/** Original file height (only for images) **/
	var ?original_height: Int;
}

@:forward(name, files, file_sizes, type, original_width, original_height)
private abstract AssetData(AssetDataObject) from AssetDataObject {
	@:op(a.b) function _get(key: String): Dynamic {
		return Reflect.getProperty(this, key);
	}
}

@:build(kha.internal.AssetsBuilder.build("image"))
private class ImageList {
	public function new() {}

	public function get(name: String): Image {
		return Reflect.field(this, name);
	}
}

@:build(kha.internal.AssetsBuilder.build("sound"))
private class SoundList {
	public function new() {}

	public function get(name: String): Sound {
		return Reflect.field(this, name);
	}
}

@:build(kha.internal.AssetsBuilder.build("blob"))
private class BlobList {
	public function new() {}

	public function get(name: String): Blob {
		return Reflect.field(this, name);
	}
}

@:build(kha.internal.AssetsBuilder.build("font"))
private class FontList {
	public function new() {}

	public function get(name: String): Font {
		return Reflect.field(this, name);
	}
}

@:build(kha.internal.AssetsBuilder.build("video"))
private class VideoList {
	public function new() {}

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
	public static function loadEverything(callback: () -> Void, ?filter: (item: AssetData) -> Bool, ?uncompressSoundsFilter: (soundItem: AssetData) -> Bool,
			?failed: (err: AssetError) -> Void): Void {
		final lists: Array<Dynamic> = [ImageList, SoundList, BlobList, FontList, VideoList];
		final listInstances: Array<Dynamic> = [images, sounds, blobs, fonts, videos];
		var fileCount = 0;
		var byteCount = 0;

		for (i in 0...lists.length) {
			final list = lists[i];
			for (file in Type.getInstanceFields(list)) {
				if (file.endsWith("Description")) {
					fileCount++;
				}
				else if (file.endsWith("Size")) {
					var size: Int = Reflect.field(listInstances[i], file);
					byteCount += size;
				}
			}
		}

		if (fileCount == 0) {
			callback();
			return;
		}

		var filesLeft = fileCount;
		var bytesLeft = byteCount;

		function onLoaded(bytes: Int): Void {
			filesLeft--;
			bytesLeft -= bytes;
			progress = 1 - (bytesLeft / byteCount);
			if (filesLeft == 0)
				callback();
		}

		function onError(err: AssetError, bytes: Int): Void {
			reporter(failed)(err);
			onLoaded(bytes);
		}

		function loadFunc(desc: AssetData, done: (bytes: Int) -> Void, failure: (err: AssetError, bytes: Int) -> Void): Void {
			final name = desc.name;
			final size = desc.file_sizes[0];
			switch (desc.type) {
				case "image":
					Assets.loadImage(name, image -> done(size), err -> onError(err, size));
				case "sound":
					Assets.loadSound(name, sound -> {
						if (uncompressSoundsFilter == null || uncompressSoundsFilter(desc)) {
							sound.uncompress(function() {
								done(size);
							});
						}
						else {
							done(size);
						}
					}, err -> onError(err, size));
				case "blob":
					Assets.loadBlob(name, blob -> done(size), err -> onError(err, size));
				case "font":
					Assets.loadFont(name, font -> done(size), err -> onError(err, size));
				case "video":
					Assets.loadVideo(name, video -> done(size), err -> onError(err, size));
			}
		}

		for (i in 0...lists.length) {
			final list = lists[i];
			final listInstance = listInstances[i];
			for (field in Type.getInstanceFields(list)) {
				if (!field.endsWith("Description"))
					continue;
				final desc = Reflect.field(listInstance, field);
				if (filter == null || filter(desc)) {
					loadFunc(desc, onLoaded, onError);
				}
				else {
					onLoaded(desc.file_sizes[0]);
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
	public static function loadImage(name: String, done: (image: Image) -> Void, ?failed: (err: AssetError) -> Void, ?pos: haxe.PosInfos): Void {
		var description = Reflect.field(images, name + "Description");
		if (description == null) {
			reporter(failed, pos)({url: name, error: "Name not found"});
			return;
		}
		LoaderImpl.loadImageFromDescription(description, function(image: Image) {
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
	public static function loadImageFromPath(path: String, readable: Bool, done: (image: Image) -> Void, ?failed: (err: AssetError) -> Void,
			?pos: haxe.PosInfos): Void {
		var description = {files: [path], readable: readable};
		LoaderImpl.loadImageFromDescription(description, done, reporter(failed, pos));
	}

	public static var imageFormats(get, null): Array<String>;

	static function get_imageFormats(): Array<String> {
		return LoaderImpl.getImageFormats();
	}

	public static function loadBlob(name: String, done: (blob: Blob) -> Void, ?failed: (err: AssetError) -> Void, ?pos: haxe.PosInfos): Void {
		var description = Reflect.field(blobs, name + "Description");
		if (description == null) {
			reporter(failed, pos)({url: name, error: "Name not found"});
			return;
		}
		LoaderImpl.loadBlobFromDescription(description, function(blob: Blob) {
			Reflect.setField(blobs, name, blob);
			done(blob);
		}, reporter(failed, pos));
	}

	public static function loadBlobFromPath(path: String, done: (blob: Blob) -> Void, ?failed: (err: AssetError) -> Void, ?pos: haxe.PosInfos): Void {
		var description = {files: [path]};
		LoaderImpl.loadBlobFromDescription(description, done, reporter(failed, pos));
	}

	public static function loadSound(name: String, done: (sound: Sound) -> Void, ?failed: (err: AssetError) -> Void, ?pos: haxe.PosInfos): Void {
		var description = Reflect.field(sounds, name + "Description");
		if (description == null) {
			reporter(failed, pos)({url: name, error: "Name not found"});
			return;
		}
		return LoaderImpl.loadSoundFromDescription(description, function(sound: Sound) {
			Reflect.setField(sounds, name, sound);
			done(sound);
		}, reporter(failed, pos));
	}

	public static function loadSoundFromPath(path: String, done: (sound: Sound) -> Void, ?failed: (err: AssetError) -> Void, ?pos: haxe.PosInfos): Void {
		var description = {files: [path]};
		return LoaderImpl.loadSoundFromDescription(description, done, reporter(failed, pos));
	}

	public static var soundFormats(get, null): Array<String>;

	static function get_soundFormats(): Array<String> {
		return LoaderImpl.getSoundFormats();
	}

	public static function loadFont(name: String, done: (font: Font) -> Void, ?failed: (err: AssetError) -> Void, ?pos: haxe.PosInfos): Void {
		var description = Reflect.field(fonts, name + "Description");
		if (description == null) {
			reporter(failed, pos)({url: name, error: "Name not found"});
			return;
		}
		return LoaderImpl.loadFontFromDescription(description, function(font: Font) {
			Reflect.setField(fonts, name, font);
			done(font);
		}, reporter(failed, pos));
	}

	public static function loadFontFromPath(path: String, done: (font: Font) -> Void, ?failed: (err: AssetError) -> Void, ?pos: haxe.PosInfos): Void {
		var description = {files: [path]};
		return LoaderImpl.loadFontFromDescription(description, done, reporter(failed, pos));
	}

	public static var fontFormats(get, null): Array<String>;

	static function get_fontFormats(): Array<String> {
		return ["ttf"];
	}

	public static function loadVideo(name: String, done: (video: Video) -> Void, ?failed: (err: AssetError) -> Void, ?pos: haxe.PosInfos): Void {
		var description = Reflect.field(videos, name + "Description");
		if (description == null) {
			reporter(failed, pos)({url: name, error: "Name not found"});
			return;
		}
		return LoaderImpl.loadVideoFromDescription(description, function(video: Video) {
			Reflect.setField(videos, name, video);
			done(video);
		}, reporter(failed, pos));
	}

	public static function loadVideoFromPath(path: String, done: (video: Video) -> Void, ?failed: (err: AssetError) -> Void, ?pos: haxe.PosInfos): Void {
		var description = {files: [path]};
		return LoaderImpl.loadVideoFromDescription(description, done, reporter(failed, pos));
	}

	public static var videoFormats(get, null): Array<String>;

	static function get_videoFormats(): Array<String> {
		return LoaderImpl.getVideoFormats();
	}

	public static function reporter(custom: (err: AssetError) -> Void, ?pos: haxe.PosInfos) {
		return custom != null ? custom : haxe.Log.trace.bind(_, pos);
	}
}
