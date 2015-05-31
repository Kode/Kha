package js.npm.mongoose.schema.types;

@:native("Schema.Types.ObjectId")
extern class ObjectId
extends js.npm.mongoose.SchemaType
implements npm.Package.RequireNamespace<"mongoose","*"> {
	public function new( path : String , options : {} ) : Void;
}