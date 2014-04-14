package kha.java;

import haxe.io.Bytes;
import java.io.InputStream;
import kha.Blob;
import kha.FontStyle;

class Loader extends kha.Loader {
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
	private function loadText(filename: String): String {
		return "";
	}

	override function loadMusic(desc: Dynamic, done: kha.Music -> Void): Void {
		done(new Music(desc.file + ".wav"));
	}

	override function loadSound(desc: Dynamic, done: kha.Sound -> Void): Void {
		done(new Sound(desc.file + ".wav"));
	}

	override function loadImage(desc: Dynamic, done: Image -> Void): Void {
		var image = new kha.java.Image(desc.file);
		loadRealImage(desc.file, image);
		done(image);
	}
	
	@:functionCode('
		try {
			image.image = javax.imageio.ImageIO.read(new java.io.File(filename));
		} catch (java.io.IOException e) {
			e.printStackTrace();
		}
	')
	function loadRealImage(filename: String, image: Image) {
		
	}

	override function loadBlob(desc: Dynamic, done: Blob -> Void): Void {
		loadRealBlob(desc.file, done);
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
	function loadRealBlob(filename: String, done: Blob -> Void) {
		
	}

	override public function loadFont(desc: Dynamic, style: FontStyle, size: Float): kha.Font {
		return new Font(name, style, size);
	}
}