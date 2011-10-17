package com.ktxsoftware.kje.editor;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedInputStream;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.filechooser.FileFilter;

public class LevelLoader implements ActionListener {
	private JFrame parent;

	public LevelLoader(JFrame parent) {
		this.parent = parent;
	}

	public void actionPerformed(ActionEvent e) {
		JFileChooser chooser = new JFileChooser();
		chooser.setCurrentDirectory(new File("../data"));
		chooser.setFileFilter(new FileFilter() {
			@Override
			public String getDescription() {
				return "Level File (.map_*)";
			}
			@Override
			public boolean accept(File f) {
				return f.getName().toLowerCase().endsWith(".map_foreground_summer") || f.isDirectory();
			}
		});
		if (chooser.showOpenDialog(parent) == JFileChooser.APPROVE_OPTION) {
			try {
				File file = chooser.getSelectedFile();
				String filename = file.getAbsolutePath();
				// Extensions abschneiden
				filename = filename.substring(0, filename.lastIndexOf("."));
				
				DataInputStream stream_foreground_summer = new DataInputStream(new BufferedInputStream(new FileInputStream(filename + ".map_foreground_summer")));
				DataInputStream stream_background_summer = new DataInputStream(new BufferedInputStream(new FileInputStream(filename + ".map_background_summer")));
				DataInputStream stream_background2_summer = new DataInputStream(new BufferedInputStream(new FileInputStream(filename + ".map_background2_summer")));
				DataInputStream stream_background3_summer = new DataInputStream(new BufferedInputStream(new FileInputStream(filename + ".map_background3_summer")));
				DataInputStream stream_overlay_summer = new DataInputStream(new BufferedInputStream(new FileInputStream(filename + ".map_overlay_summer")));
				
				DataInputStream stream_foreground_winter = new DataInputStream(new BufferedInputStream(new FileInputStream(filename + ".map_foreground_winter")));
				DataInputStream stream_background_winter = new DataInputStream(new BufferedInputStream(new FileInputStream(filename + ".map_background_winter")));
				DataInputStream stream_background2_winter = new DataInputStream(new BufferedInputStream(new FileInputStream(filename + ".map_background2_winter")));
				DataInputStream stream_background3_winter = new DataInputStream(new BufferedInputStream(new FileInputStream(filename + ".map_background3_winter")));
				DataInputStream stream_overlay_winter = new DataInputStream(new BufferedInputStream(new FileInputStream(filename + ".map_overlay_winter")));
				
				Level.getInstance().load(stream_background_summer,stream_background2_summer,stream_background3_summer,stream_foreground_summer,stream_overlay_summer,
						stream_background_winter,stream_background2_winter,stream_background3_winter,stream_foreground_winter,stream_overlay_winter);
				Level.getInstance().repaint();
				
			}
			catch (IOException ex) {
				ex.printStackTrace();
			}
		}
	}
}