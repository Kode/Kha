package js.node;

import js.node.fs.FSWatcher;
import js.node.fs.Stats;
import js.node.Buffer;
import js.node.stream.Readable;
import js.node.stream.Writable;
import js.Node;
import js.support.Callback;
import js.support.Error;

extern class Fs 
implements npm.Package.Require<"fs","*"> 
{
  static function rename(from:String,to:String,cb:Callback0):Void;
  static function renameSync(from:String,to:String):Void;
  
  static function stat(path:String,cb:Callback<Stats>):Void;
  static function statSync(path:String):Stats;

  static function lstat(path:Dynamic,cb:Callback<Stats>):Void;
  static function lstatSync(path:String):Stats;
  
  static function fstat(fd:Int,cb:Callback<Stats>):Void;
  static function fstatSync(fd:Int):Stats;
  
  static function link(srcPath:String,dstPath:String,cb:Callback0):Void;
  static function linkSync(srcPath:String,dstPath:String):Void;

  static function unlink(path:String,cb:Callback0):Void;
  static function unlinkSync(path:String):Void;
  
  @:overload(function(linkData:Dynamic,path:String,type:String,?cb:Callback0):Void {})
  static function symlink(linkData:Dynamic,path:String,?cb:Callback0):Void;
  static function symlinkSync(linkData:Dynamic,path:String,?type:String):Void;
  
  static function readlink(path:String,cb:Callback<String>):Void;
  static function readlinkSync(path:String):String;
  
  static function realpath(path:String,cb:Callback<String>):Void;
  static function realpathSync(path:String):String;
  
  static function chmod(path:String,mode:Int,cb:Callback0):Void;
  static function chmodSync(path:String,?mode:Int):Void;

  static function fchmod(fd:Int,mode:Int,cb:Callback0):Void;
  static function fchmodSync(fd:Int,?mode:Int):Void;

  static function chown(path:String,uid:Int,gid:Int,cb:Callback0):Void ;
  static function chownSync(path:String,uid:Int,gid:Int):Void;
  
  static function fchown(fd:Int,uid:Int,gid:Int,cb:Callback0):Void ;
  static function fchownSync(fd:Int,uid:Int,gid:Int):Void;

  static function rmdir(path:String,cb:Callback0):Void;
  static function rmdirSync(path:String):Void;
  
  @:overload(function(path:String,mode:Int,?cb:Callback0):Void {})
  static function mkdir(path:String,?cb:Callback0):Void;
  static function mkdirSync(path:String,?mode:Int):Void;
  
  static function readdir(path:String,cb:Callback<Array<String>>):Void;
  static function readdirSync(path:String):Array<String>;
  
  static function close(fd:Int,cb:Callback0):Void;
  static function closeSync(fd:Int):Void;
  
  @:overload(function (path:String,flags:String,mode:Int,cb:Callback<Int>):Void {} )
  static function open(path:String,flags:String,cb:Callback<Int>):Void;
  
  static function openSync(path:String,flags:String,?mode:Int):Int;
  
  static function write(fd:Int,bufOrStr:Dynamic,offset:Int,length:Int,position:Null<Int>,?cb:Callback<Int>):Void;
  static function writeSync(fd:Int,bufOrStr:Dynamic,offset:Int,length:Int,position:Null<Int>):Int;
  
  static function read(fd:Int,buffer:Buffer,offset:Int,length:Int,position:Int,cb:Callback2<Int,Buffer>):Void;
  static function readSync(fd:Int,buffer:Buffer,offset:Int,length:Int,position:Int):Int;
  
  static function truncate(fd:Int,len:Int,cb:Callback0):Void;
  static function truncateSync(fd:Int,len:Int):Error;
  
  @:overload(function(path:String,options:FsReadFileOpt,cb:Callback<String>):Void {})
  static function readFile(path:String,cb:Callback<Buffer>):Void;
  static function readFileSync(path:String,?enc:String):String;

  @:overload(function(fileName:String,data:Buffer,cb:Callback0):Void {})
  @:overload(function(fileName:String,contents:String,enc:String,cb:Callback0):Void {})
  static function writeFile(fileName:String,contents:String,cb:Callback0):Void;
  @:overload(function(fileName:String,data:Buffer):Void {})
  static function writeFileSync(fileName:String,contents:String,?enc:String):Void;

  @:overload(function(fileName:String,data:Buffer,cb:Callback0):Void {})
  @:overload(function(fileName:String,contents:String,enc:String,cb:Callback0):Void {})
  static function appendFile(fileName:String,contents:String,cb:Callback0):Void;

  @:overload(function(fileName:String,data:Buffer):Void {})
  static function appendFileSync(fileName:String,contents:String,?enc:String):Void;

  
  static function utimes(path:String,atime:Dynamic,mtime:Dynamic,cb:Callback0):Void;
  static function utimeSync(path:String,atime:Dynamic,mtime:Dynamic):Void;

  static function futimes(fd:Int,atime:Dynamic,mtime:Dynamic,cb:Callback0):Void;
  static function futimeSync(fd:Int,atime:Dynamic,mtime:Dynamic):Void;

  static function fsync(fd:Int,cb:Callback0):Void;
  static function fsyncSync(fd:Int):Void;
  
  static function watchFile(fileName:String,?options:FsWatchOpt,listener:Stats->Stats->Void):Void;
  static function unwatchFile(fileName:String):Void;
  static function watch(fileName:String,?options:FsWatchOpt,listener:String->String->Void):FSWatcher;
  static function createReadStream(path:String,?options:FsReadStreamOpt):IReadable;
  static function createWriteStream(path:String,?options:FsWriteStreamOpt):IWritable;

  static function exists(p:String,cb:Bool->Void):Void;
  static function existsSync(p:String):Bool;
}


typedef FsReadStreamOpt = {
    flags:String,
    encoding:String,
    fd:Null<Int>,
    mode:Int,
    bufferSize:Int,
    ?start:Int,
    ?end:Int
}

typedef FsReadFileOpt = {
  ?encoding : String,
  ?flag : String
}


typedef FsWriteStreamOpt = {
  var flags:String;
  var encoding:String;
  var mode:Int;
}

typedef FsWatchOpt = {persistent:Bool,interval:Int};
