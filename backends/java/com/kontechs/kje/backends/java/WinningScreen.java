package com.kontechs.kje.backends.java;

import java.awt.Color;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.awt.event.MouseMotionListener;

import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JTextField;

import com.kontechs.kje.BackgroundImage;
import com.kontechs.kje.Image;
import com.kontechs.kje.Loader;
import com.kontechs.kje.Rectangle;
import com.kontechs.kje.Saver;

//TODO: Should not be here
public class WinningScreen extends JFrame implements MouseListener,MouseMotionListener{ 
	private static final long serialVersionUID = 1L;
	private Image background_image = Loader.getInstance().loadImage("winningscreen");
	private int time_left = 0;
	private int points = 0;
	private boolean winning_screen = true;
	private static Image cursor_normal;
	private static Image cursor_point;
	JTextField name_field;
	
	public WinningScreen(int time_left,int points) {
		this.time_left = time_left;
		this.points = points;
		
		cursor_normal = Loader.getInstance().loadImage("cursor_normal");
		cursor_point = Loader.getInstance().loadImage("cursor_point");
		
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setResizable(false);
		Dimension screen = Toolkit.getDefaultToolkit().getScreenSize();
		setLayout(null);
		setSize(640, 550);
		addMouseListener(this);
		addMouseMotionListener(this);
		
		// Backgroundimage
		BackgroundImage background = new BackgroundImage(background_image);
		
		
		// Textarea
		name_field = new JTextField("Player");
		name_field.setBackground(Color.decode("#8a5839"));
		name_field.setForeground(Color.WHITE);
		name_field.setBounds(370, 182, 200, 20);
		name_field.setBorder(javax.swing.BorderFactory.createEmptyBorder());
		name_field.setCaretColor(Color.black);
		name_field.addActionListener(new ActionListener() {
			
			@Override
			public void actionPerformed(ActionEvent arg0) {
				winning_screen = false;
				Saver.getInstance().saveHighscore();				
			}
		});
		
		add(name_field);
		add(background);
		
		setLocation((screen.width - 640) / 2, (screen.height - 550) / 2);
		setVisible(true);
		
		setFocusable(true);
		requestFocus();	
	}
	
	public Rectangle showWinningScreen(){ 
		while (true) {
			synchronized (this) {
				if (!winning_screen) break;
			}
		}
		Rectangle window_pos = new Rectangle(this.getLocationOnScreen().x, this.getLocationOnScreen().y, 
				0, 0);
		StartScreen.insertInHighscore((this.time_left + this.points), name_field.getText());
		Saver.getInstance().saveHighscore();
		this.setVisible(false);
		return window_pos;
	}
	
	@Override
	public void mouseDragged(MouseEvent arg0) {
		// TODO Auto-generated method stub
		
	}
	@Override
	public void mouseMoved(MouseEvent arg0) {
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
	@Override
	public void mouseClicked(MouseEvent arg0) {
		if (arg0.getX() > 12 && arg0.getX() < 162 && arg0.getY() > 470
				&& arg0.getY() < 500) {
			winning_screen = false;
			Saver.getInstance().saveHighscore();
			
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
	public void paint(Graphics g) {
		super.paint(g);
		g.setColor(Color.decode("#7f3204"));
		g.setFont(new Font("Arial", Font.BOLD, 20));
		g.drawString("" + this.time_left, 240, 248);
		g.drawString("" + this.points, 240, 278);
		g.drawString("" + (this.time_left + this.points), 240, 311);
		int score_place = StartScreen.getHighscorePlace((this.time_left + this.points));
		g.drawString(score_place +  (score_place==1?"st":score_place==2?"nd":score_place==3?"rd":"th" + " Place"), 220, 341);
	}
}
