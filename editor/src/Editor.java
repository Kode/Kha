import java.awt.Dimension;

import javax.swing.BoxLayout;
import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.UIManager;

public class Editor extends JFrame {
	private static final long serialVersionUID = 1L;

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
		
		JMenuBar menuBar = new JMenuBar();
		setJMenuBar(menuBar);
		JMenu file = new JMenu("File");
		JMenuItem nw = new JMenuItem("New");
		JMenuItem load = new JMenuItem("Load");
		JMenuItem save = new JMenuItem("Save");
		JMenuItem saveJava = new JMenuItem("SaveJava");
		load.addActionListener(new Loader(this));
		save.addActionListener(new Saver(this));
		saveJava.addActionListener(new JavaSaver(this));
		file.add(nw);
		file.add(load);
		file.add(save);
		file.add(saveJava);
		menuBar.add(file);
		menuBar.add(new JMenu("Edit"));
		
		JPanel main = new JPanel();
		main.setLayout(new BoxLayout(main, BoxLayout.Y_AXIS));
		
		JScrollPane scrollPane = new JScrollPane(Level.getInstance());
		scrollPane.setPreferredSize(new Dimension(1000, 600));
		main.add(scrollPane);
		main.add(TilesetPanel.getInstance());
		add(main);
		
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
}