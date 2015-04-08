package util;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.TypeTools;

using util.Macro;

class NativeMap {
	#if macro
	static inline var INVALID = "Invalid";

	public static function build(){
		
		var fields = Context.getBuildFields();
		var cl = Context.getLocalClass().get();
		var lt = Context.getLocalType();
		var pos = Context.currentPos();
		
		switch(cl.kind){
			case KAbstractImpl( _ab ) :
				
				var ab = _ab.get();
				var t = Context.follow( ab.type );
				var ct = TypeTools.toComplexType(t);
				var tp = {
					pack : ab.pack,
					name : ab.name,
					params : [],
					sub : null
				};
				var rt : ComplexType = TPath(tp);
				switch(t){
					case TAnonymous( _an ) :
						
						var an = _an.get();
						var constructor =  macro {
							this = {};
						};
						
						var initExprs = switch( constructor.expr ){
							case EBlock( exprs ) : exprs;
							default : throw "assert";
						}

						fields.push({
							pos : pos,
							name : 'fromT',
							access : [AInline,AStatic],
							meta : [{
								name : ":from",
								pos : pos,
								params : []
							}],
							kind : FFun({
								ret : rt,
								args : [{type:ct,name:'val'}],
								expr : macro {
									//var t = new ATest(v);
									//t.something = "FROM TEST";
									return new $tp(val);
								}
								,
								params : []
							}) //FProp('get','set')
						});
						
						for( f in an.fields ){
							var fname = f.name;
							var nameExpr = Context.makeExpr(fname, pos);
							var nativeName = nameExpr;

							if( f.meta.has(":native") ){
								for( m in f.meta.get() ){
									if( m.name == ":native" ){
										nativeName = m.params[0];
									}
								}
							}

							var prop = ab.implementAbstractField({
								pos : f.pos,
								name : f.name,
								access : [APublic],
								meta : [],
								kind : FProp( "get", "set", TypeTools.toComplexType( f.type ) ) //FProp('get','set')
							});
							var getter = ab.implementAbstractField({
								pos : f.pos,
								name : 'get_'+f.name,
								access : [AInline],
								meta : [],
								kind : FFun({
									ret : TypeTools.toComplexType(f.type),
									args : [],
									expr : macro return untyped this[$nativeName],
									params : []
								}) //FProp('get','set')
							});

							var setter = ab.implementAbstractField( {
								pos : f.pos,
								name : 'set_'+f.name,
								access : [AInline],
								meta : [],
								kind : FFun({
									ret : TypeTools.toComplexType(f.type),
									args : [{type:TypeTools.toComplexType(f.type),name:'val'}],
									expr : macro return untyped this[$nativeName] = val,
									params : []
								}) //FProp('get','set')
							} );

							fields.push(prop);
							fields.push(getter);
							fields.push(setter);

							initExprs.push(macro untyped this[$nativeName] = val[$nameExpr] );
						}

						fields.push( ab.implementAbstractField( {
							pos : pos,
							name : 'new',
							access : [AInline],
							//meta : [],
							kind : FFun({
								ret : null,
								args : [{type:ct,name:'val'}],
								expr : constructor,
								params : []
							}) //FProp('get','set')
						} ) );

						//initExprs.push(macro return _this);

					default : throw INVALID;
				}

			default: throw INVALID;
		}

		
		return fields;
	}

	// public static function build(e : Expr){
	// 	var pos = Context.currentPos();
	// 	switch(e.expr){
	// 		case EConst(CIdent(s)) :
	// 			var t = Context.follow(Context.getType(s));

	// 			return makeFromType(s,t);
				
	// 		case EBlock(exprs) :
	// 			trace(exprs);
	// 		default:
	// 			throw INVALID;
	// 	}

	// 	return null;
	// }

	// static function makeFromType(s:String,t:haxe.macro.Type) : haxe.macro.Type {
	// 	var pos = Context.currentPos();

	// 	switch(t){
	// 		case TAnonymous(a) :
	// 			var anon = a.get();
	// 			var tname = 'A_$s';
	// 			var tpath : haxe.macro.TypePath = {
	// 				//fields : [],
	// 				pack : [],
	// 				name : tname
	// 			};
	// 			var fields = [];

	// 			var tdef : TypeDefinition = {
	// 				pos : pos,
	// 				pack : [],
	// 				name : tname,
	// 				kind : TDAbstract(TypeTools.toComplexType(t)),
	// 				fields : fields
	// 			};

	// 			var constructor =  macro {
	// 				this = cast {};
	// 			}

	// 			var initExprs = switch( constructor.expr ){
	// 				case EBlock(e) : e;
	// 				default : throw "assert";
	// 			}

	// 			fields.push({
	// 				pos : pos,
	// 				name : 'new',
	// 				access : [AInline,APublic/*,AStatic*/],
					
	// 				kind : FFun({
	// 					ret : null,
	// 					args : [{type:TypeTools.toComplexType(t),name:'val'}],
	// 					expr : constructor
	// 				}) //FProp('get','set')
	// 			});

	// 			fields.push({
	// 				pos : pos,
	// 				name : 'from$s',
	// 				access : [AInline,AStatic],
	// 				meta : [{
	// 					name : ":from",
	// 					pos : pos,
	// 					params : []
	// 				}],
	// 				kind : FFun({
	// 					ret : ComplexType.TPath( tpath ),
	// 					args : [{type:TypeTools.toComplexType(t),name:'val'}],
	// 					expr : macro {
	// 						//var t = new ATest(v);
	// 						//t.something = "FROM TEST";
	// 						return new $tpath(val);
	// 					}
	// 				}) //FProp('get','set')
	// 			});
				
	// 			for( f in anon.fields ){
	// 				var fname = f.name;
	// 				var nameExpr = Context.makeExpr(fname, pos);
	// 				var nativeName = nameExpr;


	// 				if( f.meta.has(":native") ){
	// 					for( m in f.meta.get() ){
	// 						if( m.name == ":native" ){
	// 							nativeName = m.params[0];
	// 						}
	// 					}
	// 				}
					
	// 				fields.push({
	// 					pos : f.pos,
	// 					name : f.name,
	// 					access : [APublic],
	// 					kind : FProp( "get", "set", TypeTools.toComplexType( f.type ) ) //FProp('get','set')
	// 				});

	// 				fields.push({
	// 					pos : f.pos,
	// 					name : 'get_'+f.name,
	// 					access : [AInline],
	// 					kind : FFun({
	// 						ret : TypeTools.toComplexType(f.type),
	// 						args : [],
	// 						expr : macro return untyped this[$nativeName]
	// 					}) //FProp('get','set')
	// 				});

	// 				fields.push({
	// 					pos : f.pos,
	// 					name : 'set_'+f.name,
	// 					access : [AInline],
	// 					kind : FFun({
	// 						ret : TypeTools.toComplexType(f.type),
	// 						args : [{type:TypeTools.toComplexType(f.type),name:'val'}],
	// 						expr : macro return untyped this[$nativeName] = val
	// 					}) //FProp('get','set')
	// 				});

	// 				initExprs.push(macro untyped this[$nativeName] = val[$nameExpr] );
	// 			}

	// 			Context.defineType(tdef);

	// 			//trace(haxe.macro.Context.follow(e));
	// 			return Context.getType(tname);

	// 			//trace(fields.get().fields);
	// 		default:
	// 			throw INVALID;
	// 	}

	// 	return null;

	// }
	#end
}