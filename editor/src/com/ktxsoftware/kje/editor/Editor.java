package com.ktxsoftware.kje.editor;

import java.awt.AWTEvent;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.ComponentOrientation;
import java.awt.Dimension;
import java.awt.EventQueue;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.UIManager;

public class Editor extends JFrame{
	private static final long serialVersionUID = 1L;
	private static int actual_layer = 0;
	private static boolean summer_season = true;
	private static boolean[] visible_layers = {true,false,false,false,false};
	public static final int LAYER_BACKGROUND = 0;
	public static final int LAYER_BACKGROUND2 = 1;
	public static final int LAYER_BACKGROUND3 = 2;
	public static final int LAYER_FOREGROUND = 3;
	public static final int LAYER_OVERLAY = 4;
	JPanel lvlElements_properties;
		
	public Editor() {
		super("Editor");
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		}
		catch (Exception e) {
			e.printStackTrace();
		}
		setDefaultLookAndFeelDecorated(true);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setMinimumSize(new Dimension(1000,600));
		
		
		
		JMenuBar menuBar = new JMenuBar();
		setJMenuBar(menuBar);
		JMenu file = new JMenu("File");
		JMenuItem nw = new JMenuItem("New Level");
		JMenuItem loadLevel = new JMenuItem("Load Level");
		JMenuItem saveLevel = new JMenuItem("Save Level");
			//JMenuItem saveJava = new JMenuItem("SaveJava");
		JMenuItem testMap = new JMenuItem("Test Level");
		JMenuItem loadTileProps = new JMenuItem("Load Tileset Propertys");
		JMenuItem saveTileProps = new JMenuItem("Save Tileset Propertys");
		
		// Menu Listeners
		loadLevel.addActionListener(new LevelLoader(this));
		saveLevel.addActionListener(new LevelSaver(this));
			//saveJava.addActionListener(new JavaSaver(this));
		testMap.addActionListener(new Tester(this));
		loadTileProps.addActionListener(new TilePropertiesLoader(this));
		saveTileProps.addActionListener(new TilePropertiesSaver(this));
		nw.addActionListener(new NewMap());
			// Add to File Menu
		file.add(nw);
		file.add(loadLevel);
		file.add(saveLevel);
		//file.add(saveJava);
		file.add(testMap);
		file.add(loadTileProps);
		file.add(saveTileProps);
		menuBar.add(file);
		menuBar.add(new JMenu("Edit"));
		
		JPanel main = new JPanel();
		main.setLayout(new BoxLayout(main, BoxLayout.Y_AXIS));
		
		// Layers
		
		JPanel layers_season_panel = new JPanel(new BorderLayout());
		
		JPanel layers = new JPanel();
		layers.setSize(500, 150);
		layers.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		layers.setBorder(BorderFactory.createTitledBorder("Layers"));
		
		JCheckBox checkbox_background = new JCheckBox("Background");
		checkbox_background.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		checkbox_background.addMouseListener(new LayerCheckBoxMouseListener());
		checkbox_background.setName("" + LAYER_BACKGROUND);
		checkbox_background.doClick();
		checkbox_background.setBackground(Color.blue);
		layers.add(checkbox_background);
		
		JCheckBox checkbox_background2 = new JCheckBox("Background 2");
		checkbox_background2.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		checkbox_background2.addMouseListener(new LayerCheckBoxMouseListener());
		checkbox_background2.setName("" + LAYER_BACKGROUND2);
		layers.add(checkbox_background2);
		
		JCheckBox checkbox_background3 = new JCheckBox("Background 3");
		checkbox_background3.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		checkbox_background3.addMouseListener(new LayerCheckBoxMouseListener());
		checkbox_background3.setName("" + LAYER_BACKGROUND3);
		layers.add(checkbox_background3);
		
		JCheckBox checkbox_foreground = new JCheckBox("Foreground");
		checkbox_foreground.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		checkbox_foreground.addMouseListener(new LayerCheckBoxMouseListener());
		checkbox_foreground.setName("" + LAYER_FOREGROUND);
		layers.add(checkbox_foreground);
		
		JCheckBox checkbox_overlay = new JCheckBox("Overlay");
		checkbox_overlay.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		checkbox_overlay.addMouseListener(new LayerCheckBoxMouseListener());
		checkbox_overlay.setName("" + LAYER_OVERLAY);
		layers.add(checkbox_overlay);
		
		layers_season_panel.add(layers,BorderLayout.LINE_START);
		
		
		// Seasons
		
		JPanel seasons = new JPanel();
		seasons.setSize(500, 150);
		seasons.setComponentOrientation(ComponentOrientation.LEFT_TO_RIGHT);
		seasons.setBorder(BorderFactory.createTitledBorder("Seasons"));
		
		JRadioButton radiobutton_summer = new JRadioButton("summer");
		radiobutton_summer.doClick();
		JRadioButton radiobutton_winter = new JRadioButton("winter");
		ButtonGroup radiobutton_groupSeasons = new ButtonGroup();
		radiobutton_groupSeasons.add(radiobutton_summer);
		radiobutton_groupSeasons.add(radiobutton_winter);
		radiobutton_summer.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent arg0) {
				Editor.setSummer_season(true);
				Level.getInstance().repaint();
			}
		});
		radiobutton_winter.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent arg0) {
				Editor.setSummer_season(false);
				Level.getInstance().repaint();
			}
		});
		seasons.add(radiobutton_summer);
		seasons.add(radiobutton_winter);
		
		JButton button_translateSeason = new JButton("translate summer to winter");
		button_translateSeason.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent e) {
				Level.getInstance().translateSummertoWinter(((TileProperties)lvlElements_properties).getArray_elements());
			}
		});
		seasons.add(button_translateSeason);
		
		layers_season_panel.add(seasons);
		main.add(layers_season_panel);
		
		
		// Level
		JScrollPane lvl_scrollPane = new JScrollPane(Level.getInstance());
		lvl_scrollPane.setPreferredSize(new Dimension(1000, 600));
		lvl_scrollPane.setBorder(BorderFactory.createTitledBorder("Level"));
		main.add(lvl_scrollPane);

		// Level Elements
		JPanel elements_panel = new JPanel(new BorderLayout());
		
		JScrollPane lvlElements_scrollPane = new JScrollPane(TilesetPanel.getInstance());
		lvlElements_scrollPane.setBorder(BorderFactory.createTitledBorder("Level-Elements"));
		elements_panel.add(lvlElements_scrollPane);
		
		// Level Elements Properties
		lvlElements_properties = new TileProperties();
		lvlElements_properties.setPreferredSize(new Dimension(200,200));
		lvlElements_properties.setBorder(BorderFactory.createTitledBorder("Element-Properties"));
		
		elements_panel.add(lvlElements_properties,BorderLayout.LINE_END);
		
		main.add(elements_panel);
		add(main);
		
		// Add global Keylistener, because of JFrame, With STRG show real blank Elements (0)
		EventQueue e = Toolkit.getDefaultToolkit().getSystemEventQueue();
		e.push(new EventQueue() {
			protected void dispatchEvent(AWTEvent event) {
				if (event instanceof KeyEvent) {
					KeyEvent keyEvent = (KeyEvent) event;
					if (event.getID() == KeyEvent.KEY_PRESSED && keyEvent.getKeyCode() == KeyEvent.VK_CONTROL) {
						Level.getInstance().setBlank_mode(!Level.getInstance().isBlank_mode());
						Level.getInstance().repaint();
					}
				}
				super.dispatchEvent(event);
			}
		});
		
		
		pack();
		this.setSize(1280, 720);
		setVisible(true);
	}

	public static void main(String[] args) {
		javax.swing.SwingUtilities.invokeLater(
			new Runnable() {
				public void run() {
					new Editor();
				}
			}
		);
	}

	public static int getActual_layer() {
		return actual_layer;
	}

	public static void setActual_layer(int actual_layer) {
		if (actual_layer >= 0 && actual_layer <= 4){ 
			Editor.actual_layer = actual_layer;
		}
	}

	public static boolean[] getVisible_layers() {
		return visible_layers;
	}

	public static void setVisible_layers(boolean[] visible_layers) {
		Editor.visible_layers = visible_layers;
	}

	public static boolean isSummer_season() {
		return summer_season;
	}

	public static void setSummer_season(boolean summer_season) {
		Editor.summer_season = summer_season;
	}
}