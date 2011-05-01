package com.kontechs.kje.backends.java;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import com.kontechs.kje.Saver;

public class JavaSaver extends Saver {
	
	public void saveHighscore(){
		DataOutputStream stream_highscore = null;
		try {
			stream_highscore = new DataOutputStream(new BufferedOutputStream(new FileOutputStream("../data/highscore.score")));
			for (int entry_index = 0; entry_index < 10; entry_index++)  {
				stream_highscore.writeUTF(StartScreen.getHighscore()[entry_index][0]); //TODO: Get this somewhere else
				stream_highscore.writeUTF(StartScreen.getHighscore()[entry_index][1]); //TODO: Get this somewhere else
			}
			stream_highscore.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}finally{
			try {
				stream_highscore.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
}
