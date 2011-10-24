package com.ktxsoftware.kje.editor;

import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.image.BufferedImage;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;

import javax.swing.ButtonGroup;
import javax.swing.ImageIcon;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.SwingConstants;

public class TileProperties extends JPanel {
	private static final long serialVersionUID = 1L;
	private JCheckBox checkbox_collision;
	private JCheckBox checkbox_enemy;
	private JComboBox<String> combobox_enemyTyp;
	private JComboBox<Integer> combobox_linkedTo;
	JLabel label_thumbnail;
	JRadioButton radiobutton_summer;
	JRadioButton radiobutton_winter;
	JRadioButton radiobutton_both;
	private TileProperty[] array_elements;
	

	private int property_id = 0;
	
	public TileProperties() {
		this.setLayout(new FlowLayout(FlowLayout.LEFT));
		
		// Element Thumbnail 
		
		label_thumbnail = new JLabel("Element number: 0",new ImageIcon(Tileset.getTiles()[0]),SwingConstants.RIGHT);
		this.add(label_thumbnail);
		
		
		// Element collides
		checkbox_collision = new JCheckBox("Element collides");
		this.add(checkbox_collision);
		
		// Element is enemy
		checkbox_enemy = new JCheckBox("Element is Enemy");
		this.checkbox_enemy.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent e) {
				if(((JCheckBox)e.getSource()).isSelected()){
					combobox_enemyTyp.setEnabled(true);
				}
				else{
					combobox_enemyTyp.setEnabled(false);
				}
				
			}
		});
		this.add(checkbox_enemy);
		
		
		// Enemy Typ
		combobox_enemyTyp = new JComboBox<String>();
		combobox_enemyTyp.setEnabled(false);
		combobox_enemyTyp.addItem("Hunter");
		combobox_enemyTyp.addItem("Dog");
		combobox_enemyTyp.addItem("Excavator");
		combobox_enemyTyp.addItem("WoodCoin");
		combobox_enemyTyp.addItem("WoodCoinGold");
		combobox_enemyTyp.addItem("WoodHole");
		combobox_enemyTyp.addItem("BonusBlock");
		combobox_enemyTyp.addItem("Exit");
		combobox_enemyTyp.addItem("BurstingBranchLeft");
		combobox_enemyTyp.addItem("BurstingBranchRight");
		combobox_enemyTyp.addItem("BranchLeft");
		combobox_enemyTyp.addItem("BranchRight");
		combobox_enemyTyp.addItem("BearTrap");
		combobox_enemyTyp.addItem("TreeHole");
		combobox_enemyTyp.addItem("WoodTrap");
		combobox_enemyTyp.addItem("Water");
		combobox_enemyTyp.addItem("WaterSnake");
		combobox_enemyTyp.addItem("TreeBarkLeft");
		combobox_enemyTyp.addItem("TreeBarkRight");		
		this.add(combobox_enemyTyp);

		// Summer Winter Mode
		radiobutton_summer = new JRadioButton("only summer");
		radiobutton_summer.setSelected(true);
		radiobutton_summer.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent e) {
				combobox_linkedTo.setEnabled(radiobutton_both.isSelected()?true:false);
			}
		});
		this.add(radiobutton_summer);
		radiobutton_winter = new JRadioButton("only winter");
		radiobutton_winter.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent e) {
				combobox_linkedTo.setEnabled(radiobutton_both.isSelected()?true:false);
			}
		});
		this.add(radiobutton_winter);
		radiobutton_both = new JRadioButton("both seasons");
		radiobutton_both.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent e) {
				combobox_linkedTo.setEnabled(radiobutton_both.isSelected()?true:false);
			}
		});
		this.add(radiobutton_both);
		
		ButtonGroup radionbutton_group = new ButtonGroup();
		radionbutton_group.add(radiobutton_summer);
		radionbutton_group.add(radiobutton_winter);
		radionbutton_group.add(radiobutton_both);
		
		// Linked to
		Integer[] intArray = new Integer[Tileset.getTiles().length];
		for(int i = 0;i<Tileset.getTiles().length;i++){
			intArray[i] = i;
		}
		this.combobox_linkedTo = new JComboBox<Integer>(intArray);
		ComboBoxRenderer renderer = new ComboBoxRenderer();
		renderer.setPreferredSize(new Dimension(50,32));
		this.combobox_linkedTo.setRenderer(renderer);
		this.combobox_linkedTo.setMaximumRowCount(5);
		this.combobox_linkedTo.setEnabled(false);
		this.add(combobox_linkedTo);
		
		
			
		// Initialize ElementProperty Array
		array_elements = new TileProperty[TilesetPanel.getInstance().getTileset().getLength()];
		for (int i = 0;i<array_elements.length;i++){
			array_elements[i] = new TileProperty();
		}
	}
	
	public void update(){
		saveElementSettings();
		property_id = TilesetPanel.getInstance().getSelectedElements().get(0);
		if(TilesetPanel.getInstance().getSelectedElements() != null){
			BufferedImage thumbnail = Tileset.getTiles()[property_id];
			label_thumbnail.setIcon(new ImageIcon(thumbnail));
		}
		label_thumbnail.setText("Element number: " + property_id);
		loadElementSettings();
	}
	
	public void saveElementSettings(){
		this.array_elements[property_id].setCollides(this.checkbox_collision.isSelected());
		this.array_elements[property_id].setEnemy(this.checkbox_enemy.isSelected());
		this.array_elements[property_id].setEnemyTyp(combobox_enemyTyp.getSelectedItem().toString());
		this.array_elements[property_id].setSeasonMode(
				this.radiobutton_summer.isSelected()?TileProperty.SEASONMODE_SUMMERONLY:
					this.radiobutton_winter.isSelected()?TileProperty.SEASONMODE_WINTERONLY:
						TileProperty.SEASONMODE_BOTH);
		// Link two Tiles
		if(this.radiobutton_both.isSelected()){
			this.array_elements[property_id].setLinkedTile(this.combobox_linkedTo.getSelectedIndex());
			this.array_elements[this.combobox_linkedTo.getSelectedIndex()].setLinkedTile(property_id);
			this.array_elements[this.combobox_linkedTo.getSelectedIndex()].setSeasonMode(TileProperty.SEASONMODE_BOTH);
		}
	}
	
	public void loadElementSettings(){
		// Checkbox Collision
		this.checkbox_collision.setSelected(this.array_elements[property_id].isCollides());
		// Checkbox isEnemy
		this.checkbox_enemy.setSelected(this.array_elements[property_id].isEnemy());
		
		// Combobox EnemyTyp 
		for(int i = 0;i < this.combobox_enemyTyp.getItemCount();i++){
			if(this.combobox_enemyTyp.getItemAt(i).toString().equals(this.array_elements[property_id].getEnemyTyp())){
				this.combobox_enemyTyp.setSelectedIndex(i);
			}
		}
		// Enable/Disable Combobox EnemyTyp
		this.combobox_enemyTyp.setEnabled(this.checkbox_enemy.isSelected()?true:false);
		
		// Radiobuttons Season
		this.radiobutton_summer.setSelected(
				(this.array_elements[property_id].getSeasonMode() == 0)?true:false);
		this.radiobutton_winter.setSelected(
				(this.array_elements[property_id].getSeasonMode() == 1)?true:false);
		this.radiobutton_both.setSelected(
				(this.array_elements[property_id].getSeasonMode() == 2)?true:false);
		
		// Comboxbox linkedTo
		this.combobox_linkedTo.setSelectedIndex(this.array_elements[property_id].getLinkedTile());
		
		// Enable/Disable LinkedTo
		this.combobox_linkedTo.setEnabled(this.radiobutton_both.isSelected()?true:false);
	}
	
	public void save(DataOutputStream stream_elements){
		try {
			stream_elements.writeInt(this.array_elements.length);
			for (TileProperty element : this.array_elements) {
				stream_elements.writeBoolean(element.isCollides());
				stream_elements.writeBoolean(element.isEnemy());
				stream_elements.writeUTF(element.getEnemyTyp());
				stream_elements.writeInt(element.getSeasonMode());
				stream_elements.writeInt(element.getLinkedTile());

			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				stream_elements.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void load(DataInputStream stream_elements){
		try {
			this.array_elements = new TileProperty[stream_elements.readInt()];
			for(int i = 0;i<array_elements.length;i++){
				array_elements[i] = new TileProperty();
			}
			
			for (int i = 0; i < this.array_elements.length; i++) {

				this.array_elements[i].setCollides(stream_elements.readBoolean());
				this.array_elements[i].setEnemy(stream_elements.readBoolean());
				this.array_elements[i].setEnemyTyp(stream_elements.readUTF());
				this.array_elements[i].setSeasonMode(stream_elements.readInt());
				this.array_elements[i].setLinkedTile(stream_elements.readInt());

			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			try {
				stream_elements.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
	
	public TileProperty[] getArray_elements() {
		return array_elements;
	}
}
