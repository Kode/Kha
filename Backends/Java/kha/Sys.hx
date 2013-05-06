package kha;

class Sys {
	public static function getFrequency(): Int {
		return 1000;
	}
	
	@:functionCode('
		return (int) System.currentTimeMillis();
	')
	public static function getTimestamp(): Int {
		return 0;
	}
}
