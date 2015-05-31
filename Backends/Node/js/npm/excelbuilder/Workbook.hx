package js.npm.excelbuilder;

import js.support.Callback;

extern class Workbook {
	
	public function createSheet( sheetName : String , columnCount : Int , rowCount : Int ) : Sheet;
	public function save( cb : Callback0 ) : Void;

}