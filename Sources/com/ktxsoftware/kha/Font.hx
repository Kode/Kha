package com.ktxsoftware.kha;

interface Font {
	/*public static var PLAIN : Int = 0;
	public static var BOLD : Int = 1;
	public static var ITALIC : Int = 2;
	public static var UNDERLINED : Int = 4;*/
	
	function getHeight() : Float;
	function charWidth(ch : String) : Float;
	function charsWidth(ch : String, offset : Int, length : Int) : Float;
	function stringWidth(str : String) : Float;
	function getBaselinePosition() : Float;
}