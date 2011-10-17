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

public class LevelSaver implements ActionListener {
	private JFrame parent;

	public LevelSaver(JFrame parent) {
		this.parent = parent;
	}

	public void actionPerformed(ActionEvent e) {
		JFileChooser chooser = new JFileChooser();
		chooser.setCurrentDirectory(new File("../data"));
		if (chooser.showSaveDialog(parent) == JFileChooser.APPROVE_OPTION) {
			try {
				File file = chooser.getSelectedFile();
				String filename = file.getAbsolutePath().substring(0, file.getAbsolutePath().lastIndexOf("."));
				DataOutputStream stream_foreground_summer = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename + ".map_foreground_summer")));
				DataOutputStream stream_background_summer = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename + ".map_background_summer")));
				DataOutputStream stream_background2_summer = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename + ".map_background2_summer")));
				DataOutputStream stream_background3_summer = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename + ".map_background3_summer")));
				DataOutputStream stream_overlay_summer = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename + ".map_overlay_summer")));
				
				DataOutputStream stream_foreground_winter = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename + ".map_foreground_winter")));
				DataOutputStream stream_background_winter = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename + ".map_background_winter")));
				DataOutputStream stream_background2_winter = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename + ".map_background2_winter")));
				DataOutputStream stream_background3_winter = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename + ".map_background3_winter")));
				DataOutputStream stream_overlay_winter = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(filename + ".map_overlay_winter")));
				
				Level.getInstance().save(stream_background_summer,stream_background2_summer,stream_background3_summer,stream_foreground_summer,stream_overlay_summer,
						stream_background_winter,stream_background2_winter,stream_background3_winter,stream_foreground_winter,stream_overlay_winter);
				
			}
			catch (IOException ex) {
				ex.printStackTrace();
			}
		}
	}
}