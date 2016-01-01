package kha;

import haxe.io.Bytes;
import java.io.InputStream;
import kha.Blob;
import kha.FontStyle;

class LoaderImpl {
	@:functionCode('
		String everything = "";
		try {
		java.io.BufferedReader br = new java.io.BufferedReader(new java.io.FileReader(filename));
		try {
			StringBuilder sb = new StringBuilder();
			String line = br.readLine();

			while (line != null) {
				sb.append(line);
				sb.append("\\n");
				line = br.readLine();
			}
			everything = sb.toString();
		} finally {
			br.close();
		}
		}
		catch (java.io.IOException ex) {
			
		}
		return everything;
	')
		private static function loadText(filename: String): String {
		return "";
	}

	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void): Void {
		done(new kha.java.Sound(desc.files[0]));
	}
	
	public static function getSoundFormats(): Array<String> {
		return ["wav"];
	}

	public static function loadImageFromDescription(desc: Dynamic, done: Image -> Void): Void {
		var image = new kha.Image(desc.files[0]);
		loadRealImage(desc.files[0], image);
		done(image);
	}
	
	public static function getImageFormats(): Array<String> {
		return ["png", "jpg"];
	}
	
	@:functionCode('
		try {
			image.image = javax.imageio.ImageIO.read(new java.io.File(filename));
		} catch (java.io.IOException e) {
			e.printStackTrace();
		}
	')
	static function loadRealImage(filename: String, image: Image) {
		
	}

	public static function loadBlobFromDescription(desc: Dynamic, done: Blob -> Void): Void {
		loadRealBlob(desc.files[0], done);
	}
	
	@:functionCode('
		java.util.List<Byte> bytes = new java.util.ArrayList<Byte>();
		try {
			java.io.InputStream in = new java.io.BufferedInputStream(new java.io.FileInputStream(filename));
			for (int c; (c = in.read()) != -1;) {
				bytes.add((byte)c);
			}
			in.close();
		}
		catch (java.io.IOException ex) {
			
		}
		byte[] realbytes = new byte[bytes.size()];
		for (int i = 0; i < bytes.size(); ++i) realbytes[i] = bytes.get(i);
		done.__hx_invoke1_o(0.0, new kha.Blob(new haxe.io.Bytes(bytes.size(), realbytes)));
	')
		static function loadRealBlob(filename: String, done: Blob -> Void) {
		
	}

	/*override public function loadFont(desc: Dynamic, style: FontStyle, size: Float): kha.Font {
		return new Font(name, style, size);
	}*/
	
	public static function loadFontFromDescription(desc: Dynamic, done: Font->Void): Void {
		done(new kha.java.Font("Arial", new FontStyle(false, false, false), 12));
	}
	
	public static function loadVideoFromDescription(desc: Dynamic, done: Video->Void): Void {
		done(null);
	}
	
	public static function getVideoFormats(): Array<String> {
		return [];
	}
}
