package com.ktxsoftware.kje.editor;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.swing.JFileChooser;


public class Tester implements ActionListener{

	Editor editor;
	
	public Tester(Editor editor) {
		this.editor = editor;
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		JFileChooser chooser = new JFileChooser();
		chooser.setCurrentDirectory(new File("../data"));
		String filename;
		if (chooser.showSaveDialog(editor) == JFileChooser.APPROVE_OPTION) {
			try {
				File file = chooser.getSelectedFile();
				filename = file.getAbsolutePath().substring(0, file.getAbsolutePath().lastIndexOf("."));
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
				
				try {
					System.out.println(file.getName());
				   Runtime.getRuntime().exec("java -cp bin de.hsharz.game.backend.Game " + 
						   file.getName().substring(0,file.getName().lastIndexOf(".") - 1),null,new File("../game"));
				} catch( IOException ex) {
				  // ...
				}
			}
			catch (IOException ex) {
				ex.printStackTrace();
			}
		}
		
		
	}

}
