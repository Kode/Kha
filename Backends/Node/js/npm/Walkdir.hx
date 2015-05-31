package js.npm;
import js.node.fs.Stats;
import js.node.events.EventEmitter;

/**
 * ...
 * @author AS3Boyan
 */

typedef AsyncOptions =
{
	@:optional var no_recurse:Bool;
    @:optional var follow_symlinks:Bool;
    @:optional var max_depth:Dynamic;
}
    
typedef SyncOptions =
{
    // if true the sync return will be in {path:stat} format instead of [path,path,...]
	@:optional var return_object:Bool;
    
    // if true null will be returned and no array or object will be created with found paths. useful for large listings
    @:optional var no_return:Bool;
}

extern class Walkdir implements npm.Package.Require<"walkdir","*">
{	
	static function walk(path:String, options:AsyncOptions, ?onItem:String->Stats->Void):EventEmitter;
    
    static function sync(path:String, ?options:SyncOptions, ?onItem:String->Stats->Void):Array<String>;
}