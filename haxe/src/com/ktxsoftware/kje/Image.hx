package com.ktxsoftware.kje;

interface Image {
	function getWidth() : Int;
	function getHeight() : Int;
	function isAlpha(x : Int, y : Int) : Bool;
}