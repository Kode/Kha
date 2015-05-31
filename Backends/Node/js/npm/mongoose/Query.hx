package js.npm.mongoose;

import js.support.Callback;

extern class Query<Q> {
	public function new( criteria : {} , options : QueryOptions ) : Void;
	public function setOptions( options : QueryOptions ) : Query<Q>;
	public function bind<M:Model<Dynamic>>( model : Model.Models<M> , op : String , ?updateArgs : {} ) : Query<Q>;
	@:overload( function( op : String , ?callback : Callback<Q> ) : Promise {} )
	public function exec( ?callback : Callback<Q>) : Promise;

	@:overload( function ( callback : Callback<Q>) : Query<Q> {} )
	public function find( criteria : {} , ?callback : Callback<Q>) : Query<Q>;

	public inline function cast_<M:Model<Dynamic>>( model : Model.Models<M> , ?obj : {} ) : {} return untyped  this['cast']( model , obj );

	public function where( field : String , ?val : Dynamic ) : Query<Q>;

	@:overload( function( conditions : Void->Bool ) : Query<Q> {} )
	public inline function _where( conditions : String ) : Query<Q> return untyped this["$where"](conditions);

	public function equals( val : Dynamic ) : Query<Q>;

	public function or( array : Array<{}> ) : Query<Q>;
	public function nor( array : Array<{}> ) : Query<Q>;
	public function and( array : Array<{}> ) : Query<Q>;

	public function gt( ?path : String , val : Dynamic ) : Query<Q>;
	public function gte( ?path : String , val : Dynamic ) : Query<Q>;
	public function lt( ?path : String , val : Dynamic ) : Query<Q>;
	public function lte( ?path : String , val : Dynamic ) : Query<Q>;
	public function ne( ?path : String , val : Dynamic ) : Query<Q>;
	public inline function in_( ?path : String , val : Dynamic ) : Query<Q> {
		return if( path == null )
			untyped this["in"](val);
		else
			untyped this["in"](path,val);
		
	}
		
	public function nin( ?path : String , val : Dynamic ) : Query<Q>;
	public function all( ?path : String , val : Dynamic ) : Query<Q>;
	public function size( ?path : String , val : Dynamic ) : Query<Q>;
	public function regex( ?path : String , val : Dynamic ) : Query<Q>;
	public function maxDistance( ?path : String , val : Dynamic ) : Query<Q>;
	public function near( ?path : String , val : Dynamic ) : Query<Q>;
	public function nearSphere( ?path : String , val : Dynamic ) : Query<Q>;
	public function mod( ?path : String , val : Dynamic ) : Query<Q>;
	public function elemMatch( ?path : String , val : Dynamic ) : Query<Q>;

	public var within (default,null) : QueryGeo;
	public var intersects (default,null) : QueryGeo;

	public function box( ?path : String , val : Dynamic ) : Query<Q>;
	public function center( ?path : String , val : Dynamic , ?opts : {} ) : Query<Q>;
	public function centerSphere( ?path : String , val : Dynamic ) : Query<Q>;
	public function polygon( ?path : String , val : Dynamic ) : Query<Q>;
	public function geometry( ?path : String , val : Dynamic ) : Query<Q>;

	@:overload( function( arg : String ) : Query<Q> {} )
	public function select( arg : {} ) : Query<Q>;

	public function slice( ?path : String , val : Dynamic ) : Query<Q>;

	@:overload( function( arg : String ) : Query<Q> {} )
	public function sort( arg : {} ) : Query<Q>;

	public function limit( arg : Int ) : Query<Q>;
	public function skip( arg : Int ) : Query<Q>;
	public function maxscan( arg : Int ) : Query<Q>;
	public function batchSize( arg : Int ) : Query<Q>;
	public function comment( arg : String ) : Query<Q>;

	public function snapshot() : Query<Q>;
	public function hint( arg : {} ) : Query<Q>;
	public function slaveOk( ?arg : Bool ) : Query<Q>;

	public function read( pref : String, ?tags : Dynamic ) : Query<Q>;

	public function lean( ?arg : Bool ) : Query<Q>;
	public function tailable( ?arg : Bool ) : Query<Q>;

	public function findOne<M:Model<Dynamic>>( callback : Callback<Null<M>> ) : Query<Q>;
	public function count( callback : Callback<Int> ) : Query<Q>;

	@:overload( function(fields : {} , callback : Callback<Int>) : Query<Q> { } )
	public function distinct( fields : String, callback : Callback<Int> ) : Query<Q>;

	public function update( doc : {} , callback : Callback<Q> ) : Query<Q>;

	public function remove( callback : Callback<Q> ) : Query<Q>;

	@:overload( function( ) : Query<Q> {} )
	@:overload( function( conditions : {} , update : {} , options : {} ) : Query<Q> {} )
	@:overload( function( conditions : {} , update : {} ) : Query<Q> {} )
	public function findOneAndUpdate<M:Model<Dynamic>>( conditions : {} , update : {} , ?options : {} , callback : Callback<Null<M>> ) : Query<Q>;

	@:overload( function( conditions : {} , options : {} ) : Query<Q> {} )
	@:overload( function( ?conditions : {} ) : Query<Q> {} )
	public function findOneAndRemove<M:Model<Dynamic>>( conditions : {} , ?options : {}, callback : Callback<Null<M>> ) : Query<Q>;

	public function populate<M:Model<Dynamic>>( path : Dynamic , ?select : Dynamic , ?model : Model.Models<M> , ?match : {} , ?options : {} ) : Query<Q>;

	public function stream<M:Model<Dynamic>>( ?opts : { ?transform : M->M } ) : js.node.stream.Readable;


}

typedef QueryOptions = {
	?tailable : Bool,
	?sort : Dynamic,
	?limit : Int,
	?skip : Int,
	?maxscan : Int, 
	?batchSize : Int, 
	?comment : String, 
	?snapshot : Bool, 
	?hint : {}, 
	?slaveOk : Bool,
	?lean : Bool,
	?safe : Bool
}

typedef QueryGeo = {
	// TODO
	box : Void->Void,
	center : Void->Void,
	centerSphere : Void->Void,
	geometry : Void->Void,
	polygon : Void->Void
}