package com.kontechs.kje;

import java.util.ArrayList;
import java.util.Comparator;

public class HighscoreList {
	private static HighscoreList instance;
	private ArrayList<Score> scores;
	
	public static HighscoreList getInstance() {
		if (instance == null) instance = new HighscoreList();
		return instance;
	}
	
	public HighscoreList() {
		scores = new ArrayList<Score>();
	}
	
	public ArrayList<Score> getScores() {
		return scores;
	}
	
	public void addScore(String name, int score) {
		scores.add(new Score(name, score));
		 Comparator<Score> comparator = new Comparator<Score>() {
			@Override
			public int compare(Score score1, Score score2) {
				return score2.getScore() - score1.getScore();
			}
		 };
		 java.util.Collections.sort(scores, comparator);
	}
}