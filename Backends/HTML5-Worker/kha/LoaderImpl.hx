package kha;

import haxe.io.Bytes;
import kha.graphics4.TextureFormat;

class LoaderImpl {
	static var loadingImages: Map<Int, Image->Void> = new Map();
	static var loadingSounds: Map<Int, Sound->Void> = new Map();
	static var soundId = -1;
	static var loadingVideos: Map<Int, Video->Void> = new Map();
	static var videoId = -1;
	static var loadingBlobs: Map<Int, Blob->Void> = new Map();
	static var blobId = -1;
	static var sounds: Map<Int, Sound> = new Map();

	public static function getImageFormats(): Array<String> {
		return ["png", "jpg", "hdr"];
	}

	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image -> Void, failed: AssetError -> Void) {
		++kha.Image._lastId;
		loadingImages[kha.Image._lastId] = done;
		Worker.postMessage({ command: 'loadImage', file: desc.files[0], id: kha.Image._lastId });
	}

	public static function _loadedImage(value: Dynamic) {
		var image = new Image(value.id, -1, value.width, value.height, value.realWidth, value.realHeight, TextureFormat.RGBA32);
		loadingImages[value.id](image);
		loadingImages.remove(value.id);
	}

	public static function getSoundFormats(): Array<String> {
		return ["mp4"];
	}

	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void, failed: AssetError -> Void) {
		++soundId;
		loadingSounds[soundId] = done;
		Worker.postMessage({ command: 'loadSound', file: desc.files[0], id: soundId });
	}

	public static function _loadedSound(value: Dynamic) {
		var sound = new kha.html5worker.Sound(value.id);
		loadingSounds[value.id](sound);
		loadingSounds.remove(value.id);
		sounds.set(value.id, sound);
	}

	public static function _uncompressedSound(value: Dynamic): Void {
		cast(sounds[value.id], kha.html5worker.Sound)._callback();
	}

	public static function getVideoFormats(): Array<String> {
		return ["mp4"];
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video -> Void, failed: AssetError -> Void): Void {
		++videoId;
		loadingVideos[videoId] = done;
		Worker.postMessage({ command: 'loadVideo', file: desc.files[0], id: videoId });
	}

	public static function loadBlobFromDescription(desc: Dynamic, done: Blob -> Void, failed: AssetError -> Void) {
		++blobId;
		loadingBlobs[blobId] = done;
		Worker.postMessage({ command: 'loadBlob', file: desc.files[0], id: blobId });
	}

	public static function _loadedBlob(value: Dynamic) {
		var blob = new Blob(Bytes.ofData(value.data));
		loadingBlobs[value.id](blob);
		loadingBlobs.remove(value.id);
	}

	public static function loadFontFromDescription(desc: Dynamic, done: Font -> Void, failed: AssetError -> Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			done(new Kravur(blob));
		}, failed);
	}
}
