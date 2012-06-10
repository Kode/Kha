package kha.java;

import kha.FontStyle;

class Loader extends kha.Loader {
	@:functionBody('
		String everything = "";
		try {
		java.io.BufferedReader br = new java.io.BufferedReader(new java.io.FileReader("data.xml"));
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
		xmls.set("data.xml", Xml.parse(everything));
		loadFiles();
	')
	override public function loadDataDefinition() : Void {
		
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
		this.xmls.set(filename, Xml.parse(everything));
		--this.numberOfFiles;
		this.checkComplete();
	')
	override function loadXml(filename : String) : Void {
		
	}

	override function loadMusic(filename : String) : Void {
		musics.set(filename, null);//new Music(filename));
		--numberOfFiles;
		checkComplete();
	}

	override function loadSound(filename : String) : Void {
		sounds.set(filename, null);//new Sound(filename));
		--numberOfFiles;
		checkComplete();
	}

	@:functionBody('
		kha.java.Image image = new kha.java.Image(filename);
		try {
			image.image = javax.imageio.ImageIO.read(new java.io.File(filename));
		} catch (java.io.IOException e) {
			e.printStackTrace();
		}
		this.images.set(filename, image);
		 -- this.numberOfFiles;
		this.checkComplete();
	')
	override function loadImage(filename : String) : Void {
		
	}

	@:functionBody('
		java.util.List<Integer> bytes = new java.util.ArrayList<Integer>();
		try {
			java.io.InputStream in = new java.io.BufferedInputStream(new java.io.FileInputStream(filename));
			for (int c; (c = in.read()) != -1;) {
				bytes.add(c);
			}
			in.close();
		}
		catch (java.io.IOException ex) {
			
		}
		blobs.set(filename, new kha.Blob(new haxe.io.Bytes(bytes.size(), new haxe.root.Array<Object>(bytes.toArray()))));
		--numberOfFiles;
		checkComplete();
	')
	override function loadBlob(filename : String) : Void {
		
	}

	override public function loadFont(name : String, style : FontStyle, size : Int) : kha.Font {
		return new Font(name, style, size);
	}

	function checkComplete() : Void {
		if (numberOfFiles <= 0) {
			kha.Starter.loadFinished();
		}
	}
}