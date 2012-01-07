package com.ktxsoftware.kje;

class Animation {
	private var indices : Array<Int>;
	private var speeddiv : Int;
	private var count : Int;
	private var index : Int;
	
	public static function create(index : Int) {
		var indices = [index];
		return new Animation(indices, 1);
	}
	
	public static function createRange(minindex : Int, maxindex : Int, speeddiv : Int) : Animation {
		var indices = new Array<Int>();
		for (i in 0...maxindex - minindex + 1) indices.push(minindex + i);
		return new Animation(indices, speeddiv);
	}
	
	public function new(indices : Array<Int>, speeddiv : Int) {
		this.indices = indices;
		index = 0;
		this.speeddiv = speeddiv;
	}
	
	public function get() : Int {
		return indices[index];
	}
	
	public function next() {
		++count;
		if (count % speeddiv == 0) {
			++index;
			if (index >= indices.length) index = 0;
		}
	}
	
	public function reset() {
		count = 0;
		index = 0;
	}
}