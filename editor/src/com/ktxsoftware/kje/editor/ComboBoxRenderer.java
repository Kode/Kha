package com.ktxsoftware.kje.editor;

import java.awt.Component;

import javax.swing.ImageIcon;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.ListCellRenderer;

public class ComboBoxRenderer extends JLabel implements ListCellRenderer<Object> {
	private static final long serialVersionUID = 1L;

	public ComboBoxRenderer() {
		setOpaque(true);
		setHorizontalAlignment(CENTER);
		setVerticalAlignment(CENTER);
	}
	
	@Override
	public Component getListCellRendererComponent(JList<?> list, Object value, int index, boolean isSelected, boolean cellHasFocus) {
		int selectedIndex = 0;
		if (value != null) selectedIndex = ((Integer)value).intValue();
		
		setBackground(isSelected?list.getSelectionBackground():list.getBackground());
		setForeground(isSelected?list.getSelectionForeground():list.getForeground());
		
		setText("" + selectedIndex);
		if (selectedIndex != -1) setIcon(new ImageIcon(Tileset.getTiles()[selectedIndex]));
		return this;
	}
}