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


public class TilePropertiesLoader implements ActionListener {

	private JFrame parent;
	
	public TilePropertiesLoader(JFrame parent) {
		this.parent = parent;
	}
	
	@Override
	public void actionPerformed(ActionEvent e) {
		JFileChooser chooser = new JFileChooser();
		chooser.setCurrentDirectory(new File("../data"));
		chooser.setFileFilter(new FileFilter() {
			@Override
			public String getDescription() {
				return "Settings Datei (*.settings)";
			}
			@Override
			public boolean accept(File f) {
				 return f.getName().toLowerCase().endsWith(".settings") || f.isDirectory();
			}
		});
		if (chooser.showOpenDialog(parent) == JFileChooser.APPROVE_OPTION) {
			try {
				File file = chooser.getSelectedFile();
				String filename = file.getAbsolutePath();
				
				DataInputStream stream_elements = new DataInputStream(new BufferedInputStream(
						new FileInputStream(file.getAbsolutePath())));
				((TileProperties)((Editor)this.parent).lvlElements_properties).load(stream_elements);
			}
			catch (IOException ex) {
				ex.printStackTrace();
			}
		}

	}

}
