import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;

import javax.swing.JFileChooser;
import javax.swing.JFrame;


public class JavaSaver implements ActionListener {
	private JFrame parent;

	public JavaSaver(JFrame parent) {
		this.parent = parent;
	}

	public void actionPerformed(ActionEvent e) {
		JFileChooser chooser = new JFileChooser();
		if (chooser.showSaveDialog(parent) == JFileChooser.APPROVE_OPTION) {
			try {
				File file = chooser.getSelectedFile();
				String filename = file.getAbsolutePath();
				PrintStream stream = new PrintStream(new BufferedOutputStream(new FileOutputStream(filename)));
				Level.getInstance().saveJava(stream);
			}
			catch (IOException ex) {
				ex.printStackTrace();
			}
		}
	}
}