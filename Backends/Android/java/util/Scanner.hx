package java.util;

import java.io.InputStream;

extern class Scanner {
	public function new(input : InputStream) : Void;
	public function useDelimiter(text : String) : Scanner;
	public function next() : String;
}