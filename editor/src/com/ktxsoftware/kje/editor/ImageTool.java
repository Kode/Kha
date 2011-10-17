package com.ktxsoftware.kje.editor;

import java.awt.Image;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;

import javax.imageio.ImageIO;

public class ImageTool {
	private static List<File> files = new ArrayList<File>();
	
	private static void collect(File dir) {
		for (File file : dir.listFiles()) {
			if (file.isDirectory()) collect(file);
			else if (file.getName().endsWith(".png") || file.getName().endsWith(".jpg")) files.add(file);
		}
	}
	
	public static void main(String[] args) throws IOException {
		File dir = new File("./");
		collect(dir);
		PrintStream stream = new PrintStream(new BufferedOutputStream(new FileOutputStream("images.xml")));
		stream.println("<images>");
		for (File file : files) {
			Image img = ImageIO.read(file);
			stream.println("<image name=\"" + file.getPath().substring(2).replace('\\', '/') + "\" width=\"" + img.getWidth(null) + "\" height=\"" + img.getHeight(null) + "\" />");
		}
		stream.println("</images>");
		stream.close();
	}
}