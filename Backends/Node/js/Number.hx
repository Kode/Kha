package js;

@:native("Number")
extern class Number {

	public static var MAX_VALUE : Float;
	public static var MIN_VALUE : Float;
	public static var NEGATIVE_INFINITY : Float;
	public static var NaN : Number;
	public static var POSITIVE_INFINITY : Float;

	public function new( value : Float ) : Void;
	public function toExponential( n : Float ) : String;
	public function toFixed( n : Int ) : String;
	public function toPrecision( n : Int ) : String;
	public function valueOf() : Float;
	public function toString() : String;

}