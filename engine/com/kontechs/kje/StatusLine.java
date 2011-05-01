package com.kontechs.kje;

import com.kontechs.kje.backends.java.Game;

//TODO: Remove
public class StatusLine {
	private static int score = 0;
	private static int time_left;
	public static final int GAMETIME_IN_SECONDS;
	public static final int GAMETIME_REDUCTION_IN_SECONDS_SEASON_CHANGE = 5;
	public static Image status_line = Loader.getInstance().loadImage("status_line");
	public static Image status_heart = Loader.getInstance().loadImage("heart");
	
	static{
		GAMETIME_IN_SECONDS = 240;
		time_left = GAMETIME_IN_SECONDS * Game.getSyncrate();
	}

	public static int getScore() {
		return score;
	}

	public static void setScore(int score) {
		StatusLine.score = score;
	}
	
	public static int getTime_left(){
		return time_left;
	}
	
	public static int getTime_leftInSeconds(){
		return time_left / Game.getSyncrate();
	}
	
	public static void setTime_left(int time_left_new){
		time_left = time_left_new;
	}
	
	public static int getGametimeInSeconds() {
		return GAMETIME_IN_SECONDS;
	}
	
	public static Image getStatusLine(){
		return status_line;
	}
	
	public static Image getStatus_heart() {
		return status_heart;
	}
}