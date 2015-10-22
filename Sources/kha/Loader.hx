package kha;

@:build(kha.LoaderBuilder.build())
class Loader {
	private static var blobs:  Map<String, Blob>;
	private static var images: Map<String, Image>;
	private static var sounds: Map<String, Sound>;
	private static var musics: Map<String, Music>;
	private static var videos: Map<String, Video>;
	
	public static function getImage(name: String): Image {
		return images[name];
	}
	
	public static function getMusic(name: String): Music {
		return null;
	}
	
	public static function getSound(name: String): Sound {
		return null;
	}
	
	public static function getBlob(name: String): Blob {
		return null;
	}
	
	public static function loadImage(name: String, done: Image -> Void): Void {
		var description = Reflect.field(Loader, "image_" + name);
		LoaderImpl.loadImageFromDescription(description, done);
	}
	
	public static function getShader(name: String): Blob {
		return null;
	}
}
