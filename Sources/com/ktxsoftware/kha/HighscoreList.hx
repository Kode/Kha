package com.ktxsoftware.kha;

class HighscoreList {
	static var instance : HighscoreList;
	var scores : Array<Score>;
	
	function new() {
		scores = [];
	}
	
	public static function getInstance() : HighscoreList {
		if (instance == null) instance = new HighscoreList();
		return instance;
	}
	
	public function init(scores : Array<Score>) {
		this.scores = scores;
	}
	
	public function getScores() : Array<Score> {
		return scores;
	}
	
	public function addScore(name : String, score : Int) {
		scores.push(new Score(name, score));
		scores.sort(function(score1 : Score, score2 : Score) {
			return score2.getScore() - score1.getScore();
		});
		Loader.getInstance().saveHighscore(new Score(name, score));
	}
}