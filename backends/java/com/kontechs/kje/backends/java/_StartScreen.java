package com.kontechs.kje.backends.java;

import java.awt.Color;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.Toolkit;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;

import javax.swing.ImageIcon;
import javax.swing.JFrame;

import com.kontechs.kje.Image;
import com.kontechs.kje.Loader;
import com.kontechs.kje.Rectangle;
import com.kontechs.kje.Saver;

//TODO: Should not be here
public class _StartScreen extends JFrame implements MouseListener,MouseMotionListener{
	private static final long serialVersionUID = 1L;
	private static Image start_screen;
	private static Image credits_screen;
	private static Image highscore_screen;
	private static Image cursor_normal;
	private static Image cursor_point;
	private static String[][] highscore;
	

	private boolean start_window = true;
	private _BackgroundImage background;
	private boolean isOnSubScreen = false;
	private boolean isOnHighscore = false;
	
	static{
		com.kontechs.kje.System.init(new JavaSystem(WIDTH, HEIGHT));
		Loader.init(new JavaLoader());
		Saver.init(new JavaSaver());
		start_screen = Loader.getInstance().loadImage("startscreen");
		credits_screen = Loader.getInstance().loadImage("credits");
		highscore_screen = Loader.getInstance().loadImage("highscore");
		cursor_normal = Loader.getInstance().loadImage("cursor_normal");
		cursor_point = Loader.getInstance().loadImage("cursor_point");
	}
	
	public _StartScreen() {
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setResizable(false);
		Dimension screen = Toolkit.getDefaultToolkit().getScreenSize();
		setLayout(null);
		setSize(640, 550);
		addMouseListener(this);
		addMouseMotionListener(this);
		
		// Backgroundimage
		background = new _BackgroundImage(start_screen);
		
		// add elements
		add(background);

		setLocation((screen.width - 640) / 2, (screen.height - 550) / 2);
		setVisible(true);
		
		setFocusable(true);
		requestFocus();	
		Loader.getInstance().loadHighscore();
//		String[][] temp_highscore = new String[10][10];
//		temp_highscore[0][0] = "Empty";
//		temp_highscore[0][1] = "0";
//		temp_highscore[1][0] = "Empty";
//		temp_highscore[1][1] = "0";
//		temp_highscore[2][0] = "Empty";
//		temp_highscore[2][1] = "0";
//		temp_highscore[3][0] = "Empty";
//		temp_highscore[3][1] = "0";
//		temp_highscore[4][0] = "Empty";
//		temp_highscore[4][1] = "0";
//		temp_highscore[5][0] = "Empty";
//		temp_highscore[5][1] = "0";
//		temp_highscore[6][0] = "Empty";
//		temp_highscore[6][1] = "0";
//		temp_highscore[7][0] = "Empty";
//		temp_highscore[7][1] = "0";
//		temp_highscore[8][0] = "Empty";
//		temp_highscore[8][1] = "0";
//		temp_highscore[9][0] = "Empty";
//		temp_highscore[9][1] = "0";
//		setHighscore(temp_highscore);
//		Saver.getInstance().saveHighscore();
	}
	
	public Rectangle showStartScreen(){
		while (true) {
			synchronized (this) {
				if (!start_window) break;
			}
		}
		Rectangle window_pos = new Rectangle(this.getLocationOnScreen().x, this.getLocationOnScreen().y, 
				0, 0);
		this.setVisible(false);
		return window_pos;
	}

	@Override
	public void mouseClicked(MouseEvent arg0) {
		System.out.println("x" + arg0.getX());
		System.out.println("y" + arg0.getY());
		if(!isOnSubScreen){
			isOnSubScreen = true;
			if (arg0.getX() > 370 && arg0.getX() < 615 && arg0.getY() > 145
					&& arg0.getY() < 190) {
				synchronized (this) {
					start_window = false;
				}
			}

			if (arg0.getX() > 370 && arg0.getX() < 615 && arg0.getY() > 220
					&& arg0.getY() < 260) {
				isOnHighscore = true;
				this.background.setBackgroundImage(highscore_screen);
				this.repaint();
			}

			if (arg0.getX() > 370 && arg0.getX() < 615 && arg0.getY() > 295
					&& arg0.getY() < 335) {
				this.background.setBackgroundImage(credits_screen);
				this.repaint();
			}

			if (arg0.getX() > 370 && arg0.getX() < 615 && arg0.getY() > 370
					&& arg0.getY() < 415) {
				System.exit(0);
			}
		}else{		
			isOnSubScreen = false;
			if (arg0.getX() > 12 && arg0.getX() < 162 && arg0.getY() > 470
					&& arg0.getY() < 500) {
				isOnHighscore = false;
				this.background.setBackgroundImage(start_screen);
				this.repaint();
			}
		}
		
		
		
	}

	@Override
	public void mouseEntered(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseExited(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mousePressed(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseReleased(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseDragged(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void mouseMoved(MouseEvent arg0) {
		if(isOnSubScreen){

			if(arg0.getX() > 12 && arg0.getX()< 162 && arg0.getY() > 470 && arg0.getY() < 500){
				//Cursor hand_cursor = new Cursor(Cursor.HAND_CURSOR);
				Cursor hand_cursor = getToolkit().createCustomCursor(
						  new ImageIcon( ((JavaImage)cursor_point).getImage()).getImage(),
						  new Point(0,0), "Cursor" );
				setCursor(hand_cursor);
			}else{
				Cursor normal_cursor = getToolkit().createCustomCursor(
						  new ImageIcon( ((JavaImage)cursor_normal).getImage()).getImage(),
						  new Point(0,0), "Cursor" );
				setCursor(normal_cursor);
			}
		}
		else{
			if((arg0.getX() > 370 && arg0.getX()< 615 && arg0.getY() > 145 && arg0.getY() < 190)
					|| arg0.getX() > 370 && arg0.getX()< 615 && arg0.getY() > 220 && arg0.getY() < 260
					|| arg0.getX() > 370 && arg0.getX()< 615 && arg0.getY() > 295 && arg0.getY() < 335
					|| arg0.getX() > 370 && arg0.getX()< 615 && arg0.getY() > 370 && arg0.getY() < 415){
				Cursor hand_cursor = getToolkit().createCustomCursor(
						  new ImageIcon( ((JavaImage)cursor_point).getImage()).getImage(),
						  new Point(0,0), "Cursor" );
				setCursor(hand_cursor);
			}else{
				Cursor normal_cursor = getToolkit().createCustomCursor(
						  new ImageIcon( ((JavaImage)cursor_normal).getImage()).getImage(),
						  new Point(0,0), "Cursor" );
				setCursor(normal_cursor);
			}
		
		}
		
	}
	
	public static String[][] getHighscore() {
		return highscore;
	}

	public static void setHighscore(String[][] highscore) {
		_StartScreen.highscore = highscore;
	}
	
	@Override
	public void paint(Graphics g) {
		super.paint(g);
		if(isOnHighscore){
			for (int entry_index = 0; entry_index < 10; entry_index++)  {
				g.setFont(new Font("Arial", Font.BOLD, 17));
				g.setColor(Color.decode("#7F3104"));
				
				g.drawString(getHighscore()[entry_index][0], 200, 170 + (entry_index*22));
				g.drawString(getHighscore()[entry_index][1], 400, 170 + (entry_index*22));
			}
		}
	}
	
	public static void insertInHighscore(int highscore,String name){
		int highscore_index = 9;
		for (int entry_index = 9; entry_index >= 0; entry_index--)  {
			if(highscore> Integer.parseInt(getHighscore()[entry_index][1])){
				highscore_index = entry_index;
			}
		}
		String tempscore = getHighscore()[highscore_index][1];
		String tempname = getHighscore()[highscore_index][0];
		String[][] temp_highscore = getHighscore();
		temp_highscore[highscore_index][1] = "" + highscore;
		temp_highscore[highscore_index][0] = "" + name;
		for (int entry_index = highscore_index + 1; entry_index < 9; entry_index++)  {
			
			temp_highscore[entry_index][1] = tempscore;
			temp_highscore[entry_index][0] = tempname;	
			tempscore = getHighscore()[entry_index+1][1];
			tempname = getHighscore()[entry_index+1][0];                           
			
		} 
		setHighscore(temp_highscore);
	}
	
	public static int getHighscorePlace(int highscore){
		int highscore_index = 9;
		for (int entry_index = 9; entry_index >= 0; entry_index--)  {
			if(highscore> Integer.parseInt(getHighscore()[entry_index][1])){
				highscore_index = entry_index;
			}
		}
		return  highscore_index + 1;
	}
	
}
