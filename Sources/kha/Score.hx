package kha;

class Score {
	private var name: String;
	private var score: Int;
	
	public function new(name: String, score: Int) {
		this.name = name;
		this.score = score;
	}
	
	public function getName(): String {
		return name;
	}
	
	public function getScore(): Int {
		return score;
	}
	
	public function increase(amount: Int) {
		score += amount;
	}
}
