
package npm;

#if macro
import haxe.Json;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;
import sys.io.File;
#end

private typedef Pack = {
	name : String,
	?version : String
}

#if !macro extern #end
class Package {

	static var dependencies : #if haxe3 Map<String,String> #else Hash<String> #end;

	#if macro
	public static function export( path : String = "package.json" ) : Void{
		Context.onGenerate( function(_){
			if( dependencies == null ) return;
			var data : Dynamic = {}
			
			if( sys.FileSystem.exists(path) ){
				data = Json.parse( File.getContent(path) );
			}

			if( data.dependencies == null ){
				data.dependencies = {};
			}else{
				switch(Type.typeof(data.dependencies)){
					case TObject: // fine
					default: data.dependencies = {};
				}
			}

			for( name in dependencies.keys() ){
				Reflect.setField( data.dependencies , name , dependencies.get(name) );
			}

			var content =  haxe.Json.stringify( data , null , "\t" );
			sys.io.File.saveContent( path , content );

		});
	}
	#end
	
	#if haxe3 macro #else @:macro #end public static function require( name : String , ?version : String = "*" , ?isNpm : Bool = true , ?native : String = null ) {
		
		if( dependencies == null ){
			dependencies = new #if haxe3 Map #else Hash #end();
		}
		
		var nameExpr = Context.makeExpr( name , Context.currentPos() );
		
		if( isNpm )
			dependencies.set( name , version );

		var outp = macro __js__("require")( $nameExpr );
		
		if( native != null ){
			for( p in native.split(".") ){
				var pExpr = Context.makeExpr( p , Context.currentPos() );
				outp = macro $outp[$pExpr];
			}

		}

		return macro untyped $outp;
		
	}

	#if haxe3 macro #else @:macro #end public static function resolve( expr , path : String ) {
		for( p in path.split(".") ){
			var pExpr = Context.makeExpr( p , Context.currentPos() );
			expr = macro $expr[$pExpr];
		}

		return macro $expr;
	}
	
	
}

#if !macro extern #end class Include {

	#if macro
	static var requireId = 0;
	static inline var NPM_DONE_META = ':npm_done';
	static inline var USAGE = "Usage: 'implements npm.Require<\"module-name\",\"module-version\">'";
	static inline var NPM_REQUIRE = "npm.Package.Require";
	static inline var NPM_REQUIRE_NAMESPACE = "npm.Package.RequireNamespace";
	static inline var NPM_OPTION_FULL_PATH = "npm_full_path";
	static inline var JS_NODE_PACKAGE  = 'js.node';
	static inline var SEP = "__";
	static inline var INIT = "__init__";
	#end

	#if haxe3 macro #else @:macro #end public static function build() : Array<Field>{
		
		var cl = Context.getLocalClass().get();
		var fields = Context.getBuildFields();
		var required : Pack = null;
		var requireNS = false;
		var pos = Context.currentPos();
		var isNpm = !( cl.pack.slice(0,2).join('.') == JS_NODE_PACKAGE );

		// see if the type has already been processed
		if( cl.meta.has(NPM_DONE_META) )
			return fields;
	
		// mark the type as processed
		cl.meta.add( NPM_DONE_META , [] , pos );
		
		// extract infos from the implemented interfaces
		/*t.module == NPM_PACKAGE_MODULE
				&& ( t.name == NPM_CLASS_REQUIRE || t.name == NPM_CLASS_REQUIRE_NAMESPACE ) */

		var requireParams = util.Macro.extractStringParams( cl , NPM_REQUIRE );
		if( requireParams.length == 0 ){
			requireParams = util.Macro.extractStringParams( cl , NPM_REQUIRE_NAMESPACE );
			requireNS = true;
		}

		if( requireParams.length > 0 ){

			required = {
				name : requireParams[0][0],
				version : requireParams[0][1]
			};

			// exclude local files
			isNpm = isNpm && !( StringTools.startsWith(required.name,'/') || StringTools.startsWith(required.name,'./') );
			
			// set the generated class name 
			var clName = if( !Context.defined( NPM_OPTION_FULL_PATH ) )
				// if minified
				cl.name+SEP+(requireId++);
			else
				// if not, use the class' full path
				cl.pack.join(SEP) + SEP+cl.name;

			// initialization expressions
			var init = [];

			// use the type name by default
			var nativeClass = cl.name;

			if( requireNS ){
				// if the package is a namespace
				
				// check for :native class name
				var _nativeName = util.Macro.extractNative( cl );
				if( _nativeName != null ){
					nativeClass = _nativeName;
				}
			}

			if( requireNS )
				init.push( macro var $clName = untyped npm.Package.resolve( npm.Package.require( '${required.name}','${required.version}' , $v{isNpm} ) , '${nativeClass}' ) );
			else
				init.push( macro var $clName = untyped npm.Package.require( '${required.name}','${required.version}' , $v{isNpm} ) );

			// change the class' native name
			var native = 'require("${required.name}")';
			if( requireNS ){
				native = native + '.${nativeClass}';
			}
			native = '($clName||' + native + ')';
			
			cl.meta.add(":native",[macro $v{native}], pos);

			// inject the initiatization code in __init__
			var injected = false;

			// check that __init__ method already exists
			for( f in fields ){
				if( f.name == INIT ){
					switch( f.kind ){
						case FFun( fun ) :
							injected = true;
							// add the existing __init__ body in the end of the generated init expression
							init.push( { expr : fun.expr.expr , pos : fun.expr.pos } );
							var newExpr = {
								pos : fun.expr.pos,
								expr : EBlock(init)
							};
							fun.expr = newExpr;
						default :
					}
				}
			}

			// if __init__ doesn't exist, just add the whole method
			if( !injected ){
				var f = {
					name : INIT,
					pos : pos,
					meta : [],
					access : [AStatic],
					kind : FFun({
						ret : TPath({
							name : "Void",
							pack : [],
							params : [],
							sub : null
						}),
						params : [],
						args : [],
						expr : {
							pos : pos,
							expr : EBlock(init)
						}
					})
				};
				fields.push(f);
			}
			
		}

		return fields;
	}
	
}

@:autoBuild(npm.Include.build())
extern interface Require<Const,Const> {}

@:autoBuild(npm.Include.build())
extern interface RequireNamespace<Const,Const> {}

