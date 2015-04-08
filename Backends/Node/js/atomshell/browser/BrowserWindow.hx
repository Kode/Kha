package js.atomshell.browser;
import js.node.events.EventEmitter;

/**
* @author AS3Boyan
 */
@:enum
abstract BrowserWindowNodeIntegration(String) to String
{
    var ALL = "all";
    var EXCEPT_IFRAME = "except-iframe";
    var MANUAL_ENABLE_IFRAME = "manual-enable-iframe";
}

@:build(util.NativeMap.build())
abstract BrowserWindowWebPreferences({
	@:optional var javascript:Bool;
	@:optional var images:Bool;
	@:optional var java:Bool;
	@:optional var webgl:Bool;
	@:optional var webaudio:Bool;
	@:optional var plugins:Bool;
	
	@:native("web-security")
	@:optional var webSecurity:Bool;
	
	@:native("text-areas-are-resizable")
	@:optional var textAreasAreResizable:Bool;
	
	@:native("accelerated-compositing")
	@:optional var acceleratedCompositing:Bool;
	
	@:native("extra-plugin-dirs")
	@:optional var extraPluginDirs:Array<String>;
}) {}

@:build(util.NativeMap.build())
abstract BrowserWindowOptions({
	@:optional var width:Int;
	@:optional var height:Int;
	@:optional var x:Int;
	@:optional var y:Int;
	@:optional var center:Bool;
	@:optional var resizable:Bool;
	@:optional var fullscreen:Bool;
	@:optional var kiosk:Bool;
	@:optional var title:String;
	@:optional var icon:String;
	@:optional var show:Bool;
	@:optional var frame:Bool;
	
	@:native("skip-taskbar")
	@:optional var skipTaskbar:Bool;
	
	@:native("zoom-factor")
	@:optional var zoomFactor:Float;
	
	@:native("always-on-top")
	@:optional var alwaysOnTop:Bool;
	
	@:native("use-content-size")
	@:optional var useContentSize:Bool;
	
	@:native("min-width")
	@:optional var minWidth:Int;
	
	@:native("min-height")
	@:optional var minHeight:Int;
	
	@:native("max-width")
	@:optional var maxWidth:Int;
	
	@:native("max-height")
	@:optional var maxHeight:Int;
	
	@:native("node-integration")
	@:optional var nodeIntegration:BrowserWindowNodeIntegration;
	
	@:native("accept-first-mouse")
	@:optional var acceptFirstMouse:Bool;
	
	@:native("web-preferences")
	@:optional var webPreferences:BrowserWindowWebPreferences;
}
) {}

extern class BrowserWindow implements atomshell.Package.Require<"browser-window","*"> extends EventEmitter
{
	var webContents:BrowserWindowWebContents;
	var devToolsWebContents:BrowserWindowWebContents;
	var id:Int;
	
	function new(options:BrowserWindowOptions);
	function loadUrl(path:String):Void;
	function destroy():Void;
	function close():Void;
	function focus():Void;
	function isFocused():Bool;
	function show():Void;
	function hide():Void;
	function isVisible():Bool;
	function maximize():Void;
	function unmaximize():Void;
	function isMaximized():Bool;
	function minimize():Void;
	function restore():Void;
	function setFullScreen(flag:Bool):Void;
	function isFullScreen():Bool;
	function setSize(width:Int, height:Int):Void;
	function getSize():Array<Int>;
	function setContentSize(width:Int, height:Int):Void;
	function getContentSize():Array<Int>;
	function setMinimumSize(width:Int, height:Int):Void;
	function getMinimumSize():Array<Int>;
	function setMaximumSize(width:Int, height:Int):Void;
	function getMaximumSize():Array<Int>;
	function setResizable(resizable:Bool):Void;
	function isResizable():Bool;
	function setAlwaysOnTop(flag:Bool):Void;
	function isAlwaysOnTop():Bool;
	function center():Void;
	function setPosition(x:Int, y:Int):Void;
	function getPosition():Array<Int>;
	function setTitle(title:String):Void;
	function getTitle():String;
	function flashFrame():Void;
	function setSkipTaskbar(skip:Bool):Void;
	function setKiosk(flag:Bool):Void;
	function isKiosk():Bool;
	/* OS X Only */
	function setRepresentedFilename(filename:String):Void;
	/* OS X Only */
	function setDocumentEdited(edited:Bool):Void;
	function openDevTools():Void;
	function closeDevTools():Void;
	function inspectElement(x:Int, y:Int):Void;
	function focusOnWebView():Void;
	function blurWebView():Void;
	function capturePage(?rect:{x:Int, y:Int, width:Int, height:Int}, cb:Dynamic->Void):Void;
	function reload():Void;
	/* Note: This API is not available on OS X. */
	function setMenu(menu:Dynamic):Void;
	function toggleDevTools():Void;
	
	static function getAllWindows():Array<BrowserWindow>;
	static function getFocusedWindow():Array<BrowserWindow>;
	static function fromWebContents():BrowserWindow;
	static function fromId(id:Int):BrowserWindow;
}

@:enum 
abstract BrowserWindowEvent(String) to String
{
	var CLOSED = "closed";
	var PAGE_TITLE_UPDATED = "page-title-updated";
	var CLOSE = "close";
	var UNRESPONSIVE = "unresponsive";
	var RESPONSIVE = "responsive";
	var BLUR = "blur";
	var FOCUS = "focus";	
}

extern class BrowserWindowWebContents extends EventEmitter
{
	function loadUrl(url:String):Void;
	function getUrl():String;
	function getTitle():String;
	function isLoading():Bool;
	function isWaitingForResponse():Bool;
	function stop():Void;
	function reload():Void;
	function reloadIgnoringCache():Void;
	function canGoBack():Bool;
	function canGoForward():Bool;
	function canGoToOffset(offset:Int):Bool;
	function goBack():Void;
	function goForward():Void;
	function goToIndex(index:Int):Void;
	function goToOffset(offset:Int):Void;
	function IsCrashed():Bool;
	function executeJavaScript(code:String):Void;
	function send(channel:String, ?args:Dynamic):Void;
}

@:enum
abstract WebContentsEvent(String) to String
{
	var CLOSED = "crashed";
	var DID_FINISH_LOAD = "did-finish-load";
	var DID_FRAME_FINISH_LOAD = "did-frame-finish-load";
	var DID_START_LOADING = "did-start-loading";
	var DID_STOP_LOADING = "did-stop-loading";
}