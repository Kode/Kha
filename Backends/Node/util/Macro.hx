package util;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.TypeTools;

using Lambda;

class Macro {
	#if macro
	public inline static var NATIVE_META = ":native";
	public static inline var INVALID_NATIVE = "Invalid :native";
	
	public static function extractNative( cl : ClassType ) : Null<String> {
		if( cl.meta.has(NATIVE_META) ){
			for(meta in cl.meta.get() ){
				if( meta.name == NATIVE_META ){
					if( meta.params.length != 1 )
						throw INVALID_NATIVE;
					
					switch( meta.params[0].expr ){
						case EConst( c ) : 
							switch( c ) {
								case CString( s ) :
									return s;
								default : 
									throw INVALID_NATIVE;
							}
						default :
							throw INVALID_NATIVE;
					}
				}
			}
		}

		return null;
	}

	public static function extractStringParams( cl : ClassType , type : String ) : Array<Array<String>>{

		var spl = type.split(".");
		var typeName = spl.pop();
		var typeModule = spl.join(".");

		var outp = [];

		for( i in cl.interfaces ){
			var t = i.t.get();
			if( t.module == typeModule && t.name == typeName ) {
				
				var params : Array<String> = [];
				outp.push(params);

				for( n in 0...i.params.length ){
					switch(i.params[n]){
						case TInst(name,_) :
							switch(name.get().kind){
								case KExpr(e):
									switch( e.expr ){
										case EConst(c) :
											switch(c){
												case CString(s) :
													/*if( required == null ){
														required = cast {};
													}
													switch( n ){
														case 0 :
															required.name = s;
														case 1 :
															required.version = s;
													}*/
													params[n] = s;
													
												default:
													//throw NPM_USAGE;
											}
										default: 
											//throw NPM_USAGE;
									}
								default :
									//throw NPM_USAGE;
							}
						default:
							//throw NPM_USAGE;
					}
				}
			}
		}

		return outp;

	}

	static inline var IMPL = ":impl";

	public static function implementAbstractField( a : AbstractType , f : Field ) : Field {
		var type = Context.follow( a.type );
		var complexType = TypeTools.toComplexType(type);
		var typePath = {
			pack : a.pack,
			name : a.name,
			params : [],
			sub : null
		};

		// add @:impl meta
		if( f.meta == null ) f.meta = [];
		if( !f.meta.exists( function( m ) return m.name == IMPL ) ){
			f.meta.push( { name : IMPL , params : [] , pos : f.pos } );
		}

		if( !f.access.exists( function( ac ) return ac.equals( AStatic ) ) ){
			// make the field static
			f.access.push( AStatic );
			switch( f.kind ){
				case FFun( fun ):

					// transforms constructor
					if( f.name == 'new' ){
						// changes name
						f.name = '_new';
						if( fun.expr != null ){
							var exprs = switch( fun.expr.expr ){
								case EBlock(_exprs):
									_exprs;
								default: 
									[fun.expr];
							}
							// add 'this' declaration on top
							exprs.unshift( { expr : EVars([{ name : 'this' , type : null , expr : null }]), pos : f.pos } );
							// add 'return this' on bottom
							exprs.push( macro return this );

							fun.expr.expr = EBlock(exprs);
						}

					}else{
						// if not constructor function, add 'this' argument
						fun.args.unshift( {
							type:complexType,
							name:'this'
						} );
					}
				default:
			}
		}
		
		return f;
	}

	#end

}