package util;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.MacroStringTools;
import haxe.macro.Type;
import haxe.macro.TypeTools;

class Mongoose {

    static inline var SCHEMA_OPTIONS_META = ':schemaOptions';

	#if !macro macro #end public static function buildManager( modelType : Expr ){
		var fields = Context.getBuildFields();
		var cl = Context.getLocalClass().get();
		var pos = Context.currentPos();
		var type = Context.getLocalType();

		// retrieve class type
		var modelClass = switch( Context.typeExpr(modelType).expr ){
			case TTypeExpr(TClassDecl(c)) :
				c.get();
			default : throw "error";
		}

		// find Model in superclasses
		var superClass = cl.superClass;
		while( superClass != null ){
			var superType = superClass.t.get();

			if( superType.name == modelClass.name && superType.module == modelClass.module ){
				break;
			}

			superClass = superClass.t.get().superClass;
		}

		var modelDecl = haxe.macro.TypeTools.follow( superClass.params[0] );
		var modelFullname = MacroStringTools.toDotPath(cl.pack, cl.name);
		var modelExpr = MacroStringTools.toFieldExpr(modelFullname.split("."));

		var modelTypePath = {
			sub : null,
			params : [],
			pack : cl.pack,
			name : cl.name
		};

		var mod = haxe.macro.TypeTools.follow( superClass.params[1] );

		var cl2 = switch(mod){
			case TInst(t,params):
				t.get();
			default : throw "illegal";
		}
		var modFullname = MacroStringTools.toDotPath(cl2.pack, cl2.name); //cl2.pack.join(".") + ((cl2.pack.length>0) ? "." : "") + cl2.name;
		var modExpr = MacroStringTools.toFieldExpr(modFullname.split(".")); //macro $i{modFullname};

		switch(modelDecl){
			case TAnonymous( a ):
				var schemaDef = {
					expr : anonTypeToSchemaDef( a.get() ),
					pos : pos
				};

				// add "make" method
				fields.push({
					pos : pos,
					name : 'build',
					meta : [],
					doc : null,
					kind : FFun({
						ret : TPath({
							sub : null,
							params : [],
							pack : cl.pack,
							name : cl.name
						}),
						params : [],
						expr : macro {

							var m = untyped mongoose.model( name , $modExpr.get_Schema() , collectionName , skipInit );
							var proto = untyped $modelExpr.prototype;
							for( f in Reflect.fields(proto) ){
								untyped m[f] = proto[f];
							}

							return untyped m;

						},
						args : [{
							name : "mongoose",
							value : null,
							type : TPath({
								sub : null,
								pack : ["js","npm","mongoose"],
								name : "Mongoose",
								params : []
							}),
							opt : null
						},{
							name : "name",
							value : null,
							type : TPath({
								sub : null,
								pack : [],
								name : "String",
								params : []
							}),
							opt : null
						},{
							name : "collectionName",
							value : null,
							type : TPath({
								sub : null,
								pack : [],
								name : "String",
								params : []
							}),
							opt : true
						},{
							name : "skipInit",
							value : null,
							type : TPath({
								sub : null,
								pack : [],
								name : "Bool",
								params : []
							}),
							opt : true
						}]
					}),
					access : [AStatic,APublic,AInline]
				});
			default :
				throw "not supported";
		}

		return fields;
	}

	#if !macro macro #end public static function buildModel( modelType : Expr ){

		// retrieve class type
		var modelClass = switch( Context.typeExpr(modelType).expr ){
			case TTypeExpr(TClassDecl(c)) :
				c.get();
			default : throw "error";
		}

		var fields = Context.getBuildFields();
		var cl = Context.getLocalClass().get();
		var pos = Context.currentPos();
		var type = Context.getLocalType();

		// find Model in superclasses
		var superClass = cl.superClass;
		while( superClass != null ){
			var superType = superClass.t.get();

			if( superType.name == modelClass.name && superType.module == modelClass.module ){
				break;
			}

			superClass = superClass.t.get().superClass;
		}

		var modelDecl = haxe.macro.TypeTools.follow( superClass.params[0] );
		var modelFullname = MacroStringTools.toDotPath(cl.pack,cl.name);
		var modelExpr = MacroStringTools.toFieldExpr( modelFullname.split(".") );

        var schemaOptions = macro {};

        // extract schema option metadata
        if( cl.meta.has( SCHEMA_OPTIONS_META ) ) {
            for( m in cl.meta.get() ){
                if( m.name == SCHEMA_OPTIONS_META ){
                    schemaOptions = m.params[0];
                }
            }
        }

		switch(modelDecl){
			case TAnonymous( a ):

				var schemaDef = {
					expr : anonTypeToSchemaDef( a.get() ),
					pos : pos
				};

				fields.push({
					pos : pos,
					name : '_schema',
					meta : [],
					doc : null,
					kind : FVar(null),
					access : [AStatic,APrivate]
				});

				fields.push({
					pos : pos,
					name : 'Schema',
					meta : [],
					doc : null,
					kind : FProp('get','null',TPath({
						sub : null,
						params : [TPType(haxe.macro.TypeTools.toComplexType(modelDecl))],
						pack : ['js','npm','mongoose'],
						name : 'Schema'

					})),
					access : [AStatic,APublic]
				});

				fields.push({
					pos : pos,
					name : 'get_Schema',
					meta : [],
					doc : null,
					kind : FFun({
						ret : null/*TPath({
							sub : null,
							params : [],
							pack : ['js','npm','mongoose'],
							name : 'Schema'
						})*/,
						params : [],
						expr : macro {
							if( _schema == null ){
								_schema = new js.npm.mongoose.Schema($schemaDef,$schemaOptions);
								var proto1 = untyped $modelExpr.prototype;
								for( f in Reflect.fields(proto1) ) untyped {
									var v = proto1[f];
									switch( Type.typeof(v) ){
										case TFunction : _schema.methods[f] = v;
										case _ :
									}
								}
							}
							return _schema;

						},
						args : []
					}),
					access : [AStatic,APublic,APrivate]
				});

				// copy anonymous fields to instance fields
				var hasId = false;
				for( f in a.get().fields ){
					var access = [APublic];
					var varType = haxe.macro.TypeTools.toComplexType( f.type );

					if( f.name == "_id" ){
						hasId = true;
					}

					if( f.meta.has(":optional") ){
						varType = TPath({
							sub : null,
							params : [TPType(varType)],
							pack : [],
							name : "Null"
						});
					}

					fields.push({
						name : f.name,
						pos : pos,
						meta : f.meta.get(),
						doc : null,
						access : access,
						kind : FVar( varType )
					});

				}

				// add _id field if not present
				if( !hasId ){
					fields.push({
						name : "_id",
						pos : pos,
						meta : [],
						doc : null,
						access : [APublic],
						kind : FVar( TPath({
							sub : null,
							params : [],
							pack : ['js','npm','mongoose','schema','types'],
							name : "ObjectId"
						}) )
					});
				}

			default :
				throw "not supported";
		}


		return fields;
	}

	static function anonTypeToSchemaDef( a : AnonType ) : ExprDef {
		var fields : Array<{ field : String, expr : haxe.macro.Expr }> = [];

		for( f in a.fields ){
			fields.push( classFieldToSchemaField(f) );
		}

		var objDecl = EObjectDecl( fields );

		return objDecl;
	}

	static function classFieldToSchemaField( f : ClassField ){

		var type = {
			pos : f.pos,
			expr : typeToSchemaType(f.type)
		};

		var expr = macro { type : $type };

		var fields = switch(expr.expr){
			case EObjectDecl( fields ) : fields;
			default : throw "assert";
		}

		//trace(type.expr);
		switch(type.expr){
			case EArrayDecl([v]):
				if( f.meta.has(':ref') ){
					var type = macro {type:$v};
					expr = macro [$type];
					switch( type.expr ){
						case EObjectDecl(f) :
							fields = f;
						default : throw "assert";
					}
				}

			default :

		}

		/*

		for(m in f.meta.get()){
			var mname = m.name.substring(1);
			switch( mname ){
				case "required","select","sparse","unique" :
					// TODO : remove :optional when required ? throw error ?
					fields.push( { field : mname , expr : m.params.length == 0 ? macro true : m.params[0] } );
				case "default","index", "validate" :
					// TODO : add :optional when default ?
					if( m.params.length != 1 )
						Context.error( "Expected 1 value" , m.pos );
					fields.push( { field : mname , expr : m.params[0] } );
				case "get","set" :
					if( m.params.length != 1 )
							Context.error( "Function expected" , m.pos );
						fields.push( { field : mname , expr : m.params[0] });
			}

		}

		// cases are wrong now

		trace( type.expr);
		switch( type.expr ){

			case EConst( CIdent( "Number" ) ) :
				for(m in f.meta.get()){
					//trace(m);
					var mname = m.name.substring(1);
					switch( mname ){
						case "trim","uppercase","lowercase" :
							fields.push( { field : mname , expr : m.params.length == 0 ? macro true : m.params[0] } );
						case "match":
							if( m.params.length != 1 )
								Context.error( "EReg expected" , m.pos );
							var regexp = m.params[0];

							fields.push( { field : mname , expr : macro js.support.RegExp.fromEReg( $regexp ) } );
						case "enum" :
							if( m.params.length != 1 )
								Context.error( "String values expected" , m.pos );
							var vals = m.params[0];

							fields.push( { field : mname , expr : macro ($vals : Array<String>) } );
						default:
					}
				}
			case EConst( CIdent( "Number" ) ) :
				for(m in f.meta.get()){
					//trace(m);
					var mname = m.name.substring(1);
					switch( mname ){
						case "min","max":
							if( m.params.length != 1 )
								Context.error( "Float expected" , m.pos );
							var val = m.params[0];

							fields.push( { field : mname , expr : macro ( $val : Float ) } );
					}
				}
			case EConst( CIdent( "Date" ) ) :
				for(m in f.meta.get()){
					//trace(m);
					var mname = m.name.substring(1);
					switch( mname ){
						case "expires":
							if( m.params.length != 1 )
								Context.error( "Date expected" , m.pos );
							var val = m.params[0];

							fields.push( { field : mname , expr : macro $val } );
					}
				}
			default:
		}*/

		for(m in f.meta.get()){
			//trace(m);
			var mname = m.name.substring(1);
			switch( mname ){
				case "required","select","sparse","unique" :
					// TODO : remove :optional when required ? throw error ?
					fields.push( { field : mname , expr : m.params.length == 0 ? macro true : m.params[0] } );
				case "default","index", "validate" :
					// TODO : add :optional when default ?
					if( m.params.length != 1 )
						Context.error( "Expected 1 value" , m.pos );
					fields.push( { field : mname , expr : m.params[0] } );
				case "get","set" :
					if( m.params.length != 1 )
							Context.error( "Function expected" , m.pos );
						fields.push( { field : mname , expr : m.params[0] });

				case "trim","uppercase","lowercase" :
					fields.push( { field : mname , expr : m.params.length == 0 ? macro true : m.params[0] } );
				case "match":
					if( m.params.length != 1 )
						Context.error( "EReg expected" , m.pos );
					var regexp = m.params[0];

					fields.push( { field : mname , expr : macro js.support.RegExp.fromEReg( $regexp ) } );
				case "enum" :
					if( m.params.length != 1 )
						Context.error( "String values expected" , m.pos );
					var vals = m.params[0];

					fields.push( { field : mname , expr : macro ($vals : Array<String>) } );

				case "min","max":
					if( m.params.length != 1 )
						Context.error( "Float expected" , m.pos );
					var val = m.params[0];

					fields.push( { field : mname , expr : macro ( $val : Float ) } );
				case "expires":
					if( m.params.length != 1 )
						Context.error( "Date expected" , m.pos );
					var val = m.params[0];

					fields.push( { field : mname , expr : macro $val } );
				default :
					fields.push( {field : mname , expr : m.params.length == 0 ? macro true : m.params[0] } );
			}
		}

		return { field : f.name , expr : expr };
	}

	static function typeToSchemaType( type : Type ) : ExprDef {
		//trace(type);
		switch( haxe.macro.TypeTools.follow(type) ){
			case TAnonymous( a ) :
				return anonTypeToSchemaDef( a.get() );

			case TInst( t , params ) :
				var i = t.get();
				var fullname = i.pack.join(".") + ( i.pack.length > 0 ? "." : "" ) + i.name;
				//trace(fullname);
				var expr = switch( fullname ){
					case "String" :
						macro untyped __js__('String');
					case "Array" : // TODO handle DocumentArray etc
						var t = { expr : typeToSchemaType(params[0]) , pos : Context.currentPos() };
						macro [$t];
					case "Date" :
						macro untyped __js__('Date');
					case "js.node.Buffer" :
						macro js.node.Buffer;
					case "js.npm.mongoose.schema.types.ObjectId" :
						macro js.npm.mongoose.schema.types.ObjectId;
					default :
						var sup = i.superClass;
						if(sup.t.toString() == "js.npm.mongoose.macro.Model"){

							for( f in i.fields.get() ){
								 if( f.name == '_id' ){
								 	return typeToSchemaType(f.type);
								 }
							}

							macro js.npm.mongoose.schema.types.ObjectId;

						}else{
							macro js.npm.mongoose.schema.types.Mixed;
						}
				}
				return expr.expr;

			case TAbstract( t , params ) :
				var i = t.get();
				var fullname = i.pack.join(".") + ( i.pack.length > 0 ? "." : "" ) + i.name;
				var expr = switch( fullname ){
					case "Float","Int" :
						macro js.Number;
					case "Bool" :
						macro untyped __js__('Boolean');
					default :
						macro js.npm.mongoose.schema.types.Mixed;
				}
				return expr.expr;

			default :
				var expr = macro js.npm.mongoose.schema.types.Mixed;
				return expr.expr;
		}

	}
}
