package js.npm;

extern class ExcelBuilder 
implements npm.Package.Require<"msexcel-builder","0.0.2">
{
	public static function createWorkbook( path : String , filename : String ) : js.npm.excelbuilder.Workbook;

}