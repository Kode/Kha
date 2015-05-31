package util;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

@:autoBuild(util.AsyncBuilder.build())
interface Async {}

class AsyncBuilder {

	#if !haxe3 @:macro #else macro #end
	public static function run( e : Expr ){
		return transform( e ).expr;
	}

	#if macro

		public static inline var asyncMeta = "async";

		static function build(){
			var fields : Array<Field> = haxe.macro.Context.getBuildFields();

			for( f in fields ){
				switch( f.kind ){
					case FieldType.FFun(fun) :
						fun.expr = transform(fun.expr).expr;
					default:
				}
			}
			return fields;
		}

		static function transform( e : Expr , ?block : Array<Expr> = null ) : { expr : Expr , block : Array<Expr> } {
			switch( e.expr ){
				case EBlock( exprs ) :
					var currentBlock = [];
					var appendBlock = ( block != null ) ? block : currentBlock;
					
					for( e1 in exprs ){
						var w = transform( e1 , block );
						var e2 = w.expr;
						var newBlock = w.block;

						appendBlock.push( e2 );

						if( newBlock != null )
							appendBlock = newBlock;
						
					}
					e.expr = EBlock( currentBlock );

				case EVars( vars ) :
					//var newVars = [];
					var newExprs = [];
					var args = [];
					var hasAsync = false;

					for( v in vars ){
						if( v.expr == null ){
							args.push(v);	
						}else{
							switch( v.expr.expr ){
								case EMeta(s,em) :
									if( s.name == asyncMeta ){
										args.push(v);
										hasAsync = true;
						
										switch( em.expr ){
									
											case ECall( e1 , params ) :
												//trace("call",e1);
												block = [];
												var funArgs = [];
												
												for(a in args){
													funArgs.push({
														name : a.name,
														opt : false,
														type : a.type,
														value : null
													});
												}

												args = [];
												params.push( {
													expr : EFunction( null , {
														ret : null,
														expr : {
															pos : v.expr.pos,
															expr : EBlock( block )
														},
														params : [],
														args : funArgs
													} ),
													pos : e.pos
												} );
												newExprs.push(v.expr);
												
											default :
												throw "invalid";
										}
									}

								default:
									var w = transform( v.expr , block );
									v.expr = w.expr;
									block = w.block;
									newExprs.push( { expr : EVars([v]), pos : e.pos } );
							}
						}
						
					}
					if( hasAsync ){
						e.expr = EBlock( newExprs );
					}else{
						e.expr = EVars( vars );
					}

				case EWhile( cond , body , normalWhile ) :
					e.expr = EWhile( cond , transform( body , block ).expr , normalWhile );

				case EFor( it , body ) :
					e.expr = EFor( it , transform( body , block ).expr );

				case EIf( cond , eif , eelse ) :
					e.expr = EIf( cond , transform( eif , block ).expr , (eelse==null) ? null : transform( eelse , block ).expr );
				
				
				default :
					if( block != null )
						block.push( e );

			
			}

			var r = { expr : e , block : block };
			
			return r;
			
		}

	#end

}