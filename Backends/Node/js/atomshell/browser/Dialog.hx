package js.atomshell.browser;

/**
 * @author AS3Boyan
 * MIT

 */
typedef DialogOpenOptions = 
{
	?title:String,
	?defaultPath:String,
	/* openFile, openDirectory, multiSelections and createDirectory */
	?properties:Array<String>
}

typedef DialogSaveOptions = 
{
	?title:String,
	?defaultPath:String
}

extern class Dialog implements atomshell.Package.Require<"dialog","*">
{
	static function showOpenDialog(?browserBrowserWindow:BrowserWindow, options:DialogOpenOptions, ?cb:Null<Array<String>>->Void):Null<Array<String>>;
	
	static function showSaveDialog(?browserBrowserWindow:BrowserWindow, options:DialogSaveOptions, ?cb:Null<String>->Void):Null<String>;
	
	static function showMessageBox(?browserBrowserWindow:BrowserWindow, options:{ ?type:String, ?buttons:Array<String>, ?title:String, ?message:String, ?detail:String }, ?cb:Null<Dynamic>->Void):Null<Dynamic>;
}
	
@:enum
abstract DialogOpenOptionsProperty(String) to String
{
	var OPEN_FILE = "openFile";
	var OPEN_DIRECTORY = "openDirectory";
	var MULTI_SELECTIONS = "multiSelections";
	var CREATE_DIRECTORY = "createDirectory";
}