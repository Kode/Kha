package com.ktx.kje;

import java.io.Serializable;

public class Score implements Serializable {
	private static final long serialVersionUID = 1L;
	private String name;
	private int score;
	
	public Score() {
		
	}
	
	public Score(String name, int score) {
		this.name = name;
		this.score = score;
	}
	
	public String getName() {
		return name;
	}
	
	public int getScore() {
		return score;
	}
	
	public void increase(int amount) {
		score += amount;
	}
}