package com.ktxsoftware.kje.editor;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.filechooser.FileFilter;


public class TilePropertiesSaver implements ActionListener {

	private JFrame parent;
	
	public TilePropertiesSaver(JFrame parent) {
		this.parent = parent;
	}
	
	@Override
	public void actionPerformed(ActionEvent arg0) {
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
		if (chooser.showSaveDialog(parent) == JFileChooser.APPROVE_OPTION) {
			try {
				File file = chooser.getSelectedFile();
				
				DataOutputStream stream_elements = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(
						file.getAbsolutePath())));
				((TileProperties)((Editor)this.parent).lvlElements_properties).save(stream_elements);
				
			}
			catch (IOException ex) {
				ex.printStackTrace();
			}
		}

	}

}
