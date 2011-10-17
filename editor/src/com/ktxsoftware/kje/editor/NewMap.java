package com.ktxsoftware.kje.editor;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;


public class NewMap implements ActionListener {

	@Override
	public void actionPerformed(ActionEvent e) {
		// erstellt alle Layer Arrays neu
		Level.getInstance().resetMaps();

	}

}
