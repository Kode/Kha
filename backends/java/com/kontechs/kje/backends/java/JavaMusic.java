package com.kontechs.kje.backends.java;

import java.io.File;
import java.io.IOException;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.SourceDataLine;
import javax.sound.sampled.UnsupportedAudioFileException;

import com.kontechs.kje.Music;

//Google'n'Paste-Code
public class JavaMusic implements Music, Runnable { 
	File file;
	AudioInputStream in;
	SourceDataLine line;
	int frameSize;
	byte[] buffer = new byte [32 * 1024]; // 32k is arbitrary
	Thread playThread;
	boolean playing;
	boolean notYetEOF;

	public JavaMusic(File f) throws IOException, UnsupportedAudioFileException, LineUnavailableException {
		//instance = this;
		file = f;
		in = AudioSystem.getAudioInputStream (f);
		AudioFormat format = in.getFormat();
		AudioFormat.Encoding formatEncoding = format.getEncoding();
		if (! (formatEncoding.equals (AudioFormat.Encoding.PCM_SIGNED) ||
			   formatEncoding.equals (AudioFormat.Encoding.PCM_UNSIGNED))) 
		   throw new UnsupportedAudioFileException (
                              file.getName() + " is not PCM audio");
       //System.out.println ("got PCM format");        
	   frameSize = format.getFrameSize(); 
	   DataLine.Info info =
		   new DataLine.Info (SourceDataLine.class, format); 
	   //System.out.println ("got info"); 
	   line = (SourceDataLine) AudioSystem.getLine (info); 
	   //System.out.println ("got line");        
	   line.open(); 
	   //System.out.println ("opened line"); 
	   playThread = new Thread (this); 
	   playing = false; 
	   notYetEOF = true;        
	   playThread.start();
	}
	
	public void run() {
		int readPoint = 0;
		int bytesRead = 0;

		try {
			for (;;) {
				while (notYetEOF) {
					if (playing) {
					bytesRead = in.read (buffer, 
								 readPoint, 
								 buffer.length - readPoint);
	                   if (bytesRead == -1) { 
					notYetEOF = false; 
					break;
					}
					// how many frames did we get,
					// and how many are left over?
					//int frames = bytesRead / frameSize;
					int leftover = bytesRead % frameSize;
					// send to line
					line.write (buffer, readPoint, bytesRead-leftover);
					// save the leftover bytes
					System.arraycopy (buffer, bytesRead,
							  buffer, 0, 
							  leftover); 
	                    readPoint = leftover;
					} else { 
					// if not playing                   
					// Thread.yield(); 
					try { Thread.sleep (10);} 
					catch (InterruptedException ie) {}
					}
				} // while notYetEOF
				//System.out.println ("reached eof");
				try {
					in = AudioSystem.getAudioInputStream (file);
				} catch (UnsupportedAudioFileException e) {
					e.printStackTrace();
				}
				notYetEOF = true;
			}
			//line.drain();
			//line.stop();
		} catch (IOException ioe) {
			ioe.printStackTrace();
		} finally {
			// line.close();
		}
	} // run

	@Override
	public void start() {
		playing = true;
		if (!playThread.isAlive())
			playThread.start();
		line.start();
	}

	@Override
	public void stop() {
		playing = false;
		line.stop();
	}
   
	public SourceDataLine getLine() {
		return line;
	}

	public File getFile() {		
		return file; 
	}

	@Override
	public void update() {
		
	} 
}