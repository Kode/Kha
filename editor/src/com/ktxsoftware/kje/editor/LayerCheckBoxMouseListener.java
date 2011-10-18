package com.ktxsoftware.kje.editor;

import java.awt.Color;
import java.awt.Component;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import javax.swing.JCheckBox;

public class LayerCheckBoxMouseListener implements MouseListener{

	@Override
	public void mouseClicked(MouseEvent e) {
		
		
	}

	@Override
	public void mouseEntered(MouseEvent e) {
		
	}

	@Override
	public void mouseExited(MouseEvent e) {
		
	}

	@Override
	public void mousePressed(MouseEvent e) {
		
	}

	@Override
	public void mouseReleased(MouseEvent e) {
		// x > 15 --> erst nach der Checkbox ... also auf dem Text
		// Bei OSX etwas groesser
		// TODO F�r OSX anpassen
		
		if (e.getPoint().x > 15) {
			((JCheckBox) (e.getSource())).setBackground(Color.blue);
			int layer_id = 0;
			layer_id = Integer.parseInt(((JCheckBox)(e.getSource())).getName().toString());
			Editor.setActual_layer(layer_id);
			
			
			// Wenn Layer nicht sichtbar, dann sichtbar machen, da ja drauf gezeichnet werden soll
			if (!((JCheckBox) (e.getSource())).isSelected()) {
				((JCheckBox) (e.getSource())).setSelected(true);
			}
			
			// Andere gefaerbte Checkbox "deselektieren"
			for (Component comp : ((JCheckBox) (e.getSource())).getParent().getComponents()) {
				if (comp != e.getSource()) {
					((JCheckBox)comp).setBackground(((JCheckBox)comp).getParent().getBackground());
				}
			}
			
		}
		// Da Aenderungen an Sichtbarkeit moeglich (checked oder nicht) --> visibleLayers Array updaten
		boolean[] visibleLayers = Editor.getVisible_layers();
		if (((JCheckBox)(e.getSource())).isSelected()) {
			visibleLayers[Integer.parseInt(((JCheckBox)(e.getSource())).getName().toString())] = true;
		}
		else {
			visibleLayers[Integer.parseInt(((JCheckBox)(e.getSource())).getName().toString())] = false;
		}
		Editor.setVisible_layers(visibleLayers);
		
		System.out.println("----------");
		for (boolean visible : visibleLayers) {
			System.out.println(visible);
		}
		
		// Layers neu zeichnen, da ja eine Ebenensichtbarkeit deaktiviert/aktiviert wurden sein koennte
		Level.getInstance().repaint();	
	}
}