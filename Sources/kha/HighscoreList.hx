package kha;

import haxe.Http;

class HighscoreList {
	var name : String;
	var scores : Array<Score>;
	
	public function new(name : String) {
		this.name = name;
		scores = [];
		updateScores();
	}
	
	public function init(scores : Array<Score>) {
		this.scores = scores;
	}
	
	function updateScores() {
		var request = new Http("http://localhost:8080/getscores");
		request.setParameter("game", name);
		request.setParameter("count", "10");
		request.onData = function(data : String) {
			var json = Json.parse(data);
			var newscores = new Array<Score>();
			for (i in 0...10) {
				newscores.push(new Score(json[i].name, json[i].score));
			}
			scores = newscores;
		};
		request.request(false);
	}
	
	public function getScores() : Array<Score> {
		return scores;
	}
	
	public function addScore(name : String, score : Int) {
		scores.push(new Score(name, score));
		scores.sort(function(score1 : Score, score2 : Score) {
			return score2.getScore() - score1.getScore();
		});
		var request = new Http("http://localhost:8080/addscore");
		request.setParameter("game", this.name);
		request.setParameter("name", name);
		request.setParameter("score", Std.string(score));
		request.request(false);
	}
}