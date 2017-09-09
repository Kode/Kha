package kha;

class StringExtensions {
	public static function toCharArray(s: String): Array<Int> {
		var results = new Array<Int>();
		for (i in 0...s.length) {
			results.push(s.charCodeAt(i));
		}
		return results;
	}
}
