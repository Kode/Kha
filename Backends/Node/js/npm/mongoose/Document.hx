package js.npm.mongoose;

import js.support.Callback;
import js.support.Error;

typedef DocumentToObjectOptions<T> = {
	?getters : Bool,
	?virtuals : Bool,
	?minimize : Bool,
	?transform : T->T
}

extern class Document<T>
extends js.node.events.EventEmitter #if !haxe3 , #end
implements npm.Package.RequireNamespace<"mongoose","*">
implements Dynamic {
	//public static var schema : Schema<Dynamic>;
	public var isNew : Bool;
	public var id : Null<String>;
	public var errors : {};

	public function new( doc : {} , fields : {} , skipId : Bool ) : Void;
	public function update( doc : {} , options : {} , fn : Callback0 ) : Void;
	@:overload( function( values : {} , ?options : {} ) : Document<T> {} )
	public function set( path : String , val : Dynamic , ?type : Dynamic , ?options : {} ) : Document<T>;

	public function get( path : String , ?type : Dynamic ) : Dynamic;
	public function markModified( path : String ) : Void;
	public function modifiedPaths() : Array<String>;
	public function isModified( ?path : String ) : Bool;
	public function isDirectModified( path : String ) : Bool;
	public function isInit( path : String ) : Bool;
	public function isSelected( path : String ) : Bool;
	public function validate( cb : Callback0 ) : Void;
	public function invalidate( path : String , err : Error , val : Dynamic ) : Void;
	public function toObject( ?options : DocumentToObjectOptions<T> ) : T;
}