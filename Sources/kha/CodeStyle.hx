package kha;

class CodeStyle { //upper camel case class names
	public function new() { //egyptian style curly brackets
		
	}
	
	public function doIt(): Void { //lower camel case method and function names
		var i = 0;
		switch (i) {
		case 1: //case in same column as switch
			playSfx(2);
		}
	}
	
	public function playSfx(soundId: Int) { //lower camel case for parameters and locals, camel case is used for akronyms, too

	}
}
