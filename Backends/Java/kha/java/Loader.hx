package kha.java;

import haxe.io.Bytes;
import kha.FontStyle;
import kha.loader.Asset;

class Loader extends kha.Loader {
	
	override function loadXml(asset: Asset) : Void {
		xmls.set(asset.name, Xml.parse(loadText(asset.file)));
		--numberOfFiles;
		checkComplete();
	}
	
	@:functionBody('
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

	override function loadMusic(asset: Asset): Void {
		musics.set(asset.name, new Music(asset.file + ".wav"));
		--numberOfFiles;
		checkComplete();
	}

	override function loadSound(asset: Asset): Void {
		sounds.set(asset.name, new Sound(asset.file + ".wav"));
		--numberOfFiles;
		checkComplete();
	}

	override function loadImage(asset: Asset): Void {
		var image = new kha.java.Image(asset.file);
		loadRealImage(asset.file, image);
		images.set(asset.name, image);
		--numberOfFiles;
		checkComplete();
	}
	
	@:functionBody('
		try {
			image.image = javax.imageio.ImageIO.read(new java.io.File(filename));
		} catch (java.io.IOException e) {
			e.printStackTrace();
		}
	')
	function loadRealImage(filename: String, image: Image) {
		
	}

	@:functionBody('
		java.util.List<Byte> bytes = new java.util.ArrayList<Byte>();
		try {
			java.io.InputStream in = new java.io.BufferedInputStream(new java.io.FileInputStream(asset.file));
			for (int c; (c = in.read()) != -1;) {
				bytes.add((byte)c);
			}
			in.close();
		}
		catch (java.io.IOException ex) {
			
		}
		byte[] realbytes = new byte[bytes.size()];
		for (int i = 0; i < bytes.size(); ++i) realbytes[i] = bytes.get(i);
		blobs.set(asset.name, new kha.Blob(new haxe.io.Bytes(bytes.size(), realbytes)));
		--numberOfFiles;
		checkComplete();
	')
	override function loadBlob(asset: Asset): Void {
		
	}

	override public function loadFont(name: String, style: FontStyle, size: Int): kha.Font {
		return new Font(name, style, size);
	}
}