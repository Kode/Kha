package com.ktxsoftware.kje;

import java.util.ArrayList;
import java.util.Comparator;

public class HighscoreList {
	private static HighscoreList instance;
	private ArrayList<Score> scores = new ArrayList<Score>();
	
	public static HighscoreList getInstance() {
		if (instance == null) instance = new HighscoreList();
		return instance;
	}
	
	public void init(ArrayList<Score> scores) {
		this.scores = scores;
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
		Loader.getInstance().saveHighscore(new Score(name, score));
	}
}