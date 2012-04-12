package com.ktxsoftware.kha;

interface Font {
	function getHeight() : Float;
	function charWidth(ch : String) : Float;
	function charsWidth(ch : String, offset : Int, length : Int) : Float;
	function stringWidth(str : String) : Float;
	function getBaselinePosition() : Float;
}