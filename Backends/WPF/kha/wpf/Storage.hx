package kha.wpf;

import kha.FontStyle;
import system.io.File;

class Storage extends kha.Storage {
	
	override function saveToFile(filename : String, content : String) {
		File.WriteAllText(filename, content);
	}
	
	override function appendToFile(filename : String, content : String) {
		File.AppendAllText(filename, content);
	}
}