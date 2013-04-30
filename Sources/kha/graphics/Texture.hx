package kha.graphics;

import kha.Image;

interface Texture extends Image{
	var realWidth(get, null): Int;
	var realHeight(get, null): Int;
}
