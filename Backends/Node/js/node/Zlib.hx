package js.node;

import js.node.Buffer;
import js.Node;
import js.support.Callback;

import js.node.zlib.*;

extern class ZLib 
implements npm.Package.Require<"zlib","*">
{
    static function createGzip(?options:Dynamic):Gzip;
    static function createGunzip(?options:Dynamic):Gunzip;
    static function createDeflate(?options:Dynamic):Deflate;
    static function createInflate(?options:Dynamic):Inflate;
    static function createInflateRaw(?options:Dynamic):InflateRaw;
    static function createDeflateRaw(?options:Dynamic):DeflateRaw;
    static function createUnzip(?options:Dynamic):Unzip;

    // convenience
    @:overload(function (str:String,cb:Callback<Dynamic>):Void {})
    function deflate(buf:Buffer,cb:Callback<Dynamic>):Void;
    @:overload(function (str:String,cb:Callback<Dynamic>):Void {})
    function deflateRaw(buf:Buffer,cb:Callback<Dynamic>):Void;
    @:overload(function (str:String,cb:Callback<Dynamic>):Void {})
    function gzip(buf:Buffer,cb:Callback<Dynamic>):Void;
    @:overload(function (str:String,cb:Callback<Dynamic>):Void {})
    function gunzip(buf:Buffer,cb:Callback<Dynamic>):Void;
    @:overload(function (str:String,cb:Callback<Dynamic>):Void {})
    function inflate(buf:Buffer,cb:Callback<Dynamic>):Void;
    @:overload(function (str:String,cb:Callback<Dynamic>):Void {})
    function inflateRaw(buf:Buffer,cb:Callback<Dynamic>):Void;
    @:overload(function (str:String,cb:Callback<Dynamic>):Void {})
    function unzip(buf:Buffer,cb:Callback<Dynamic>):Void;
}