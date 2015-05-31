package js.node;

/*
  Snarfed from Tong's version ...
 */ 
extern class Assert 
implements npm.Package.Require<"assert","*"> 
 {
	static function fail(actual:Dynamic,expected:Dynamic,message:Dynamic,operator:Dynamic): Void;
	static function ok(value:Dynamic,?message:Dynamic):Void;
	static function equal(actual:Dynamic,expected:Dynamic,?message:Dynamic):Void;
	static function notEqual(actual:Dynamic,expected:Dynamic,?message:Dynamic):Void;
	static function deepEqual(actual:Dynamic,expected:Dynamic,?message:Dynamic):Void;
	static function notDeepEqual(actual:Dynamic,expected:Dynamic,?message:Dynamic):Void;
	static function strictEqual(actual:Dynamic,expected:Dynamic,?message:Dynamic):Void;
	static function notStrictEqual(actual:Dynamic,expected:Dynamic,?message:Dynamic):Void;
	static function throws(block:Dynamic,error:Dynamic,?message:Dynamic):Void;
	static function doesNotThrow(block:Dynamic,error:Dynamic,?message:Dynamic):Void;
	static function ifError(value:Dynamic):Void;
	
}