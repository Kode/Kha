package js.node.fs;

typedef NodeJsDate = {
    function getTime():Int;
    function toDateString():String;
    function toUTCString():String;
}

extern class Stats 
implements npm.Package.RequireNamespace<"fs","*">
{
	var dev:Int;
	var ino:Int;
	var mode:Int;
	var nlink:Int;
	var uid:Int;
	var gid:Int;
	var rdev:Int;
	var size:Int;
	var blkSize:Int;
	var blocks:Int;
	var atime:NodeJsDate;
	var mtime:NodeJsDate;
	var ctime:NodeJsDate;

	function isFile():Bool;
	function isDirectory():Bool;
	function isBlockDevice():Bool;
	function isCharacterDevice():Bool;
	function isSymbolicLink():Bool;
	function isFIFO():Bool;
	function isSocket():Bool;

}