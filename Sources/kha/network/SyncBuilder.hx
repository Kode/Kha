package kha.network;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.Field;

class SyncBuilder {
	public static var nextId: Int = 0;
	public static var objects: Array<Dynamic> = new Array<Dynamic>();

	macro static public function build(): Array<Field> {
		var fields = Context.getBuildFields();
		
		var isBaseEntity = false;
		for (i in Context.getLocalClass().get().interfaces) {
			var intf = i.t.get();
			if (intf.module == "kha.network.Sync") {
				isBaseEntity = true;
				break;
			}
		}
		
		for (field in fields) {
			if (field.name == "new") {
				switch (field.kind) {
				case FFun(f):
					var cexpr = f.expr;
					cexpr = macro @:mergeBlock {
						$cexpr;
						kha.network.SyncBuilder.objects[_syncId()] = this;
					}
					f.expr = cexpr;
					continue;
				default:
				}
			}

			var synced = false;
			// TODO: Avoid hardcoding the target ids
			var target = 0;//kha.network.Session.RPC_SERVER;
			var isStatic = field.access.lastIndexOf(AStatic) >= 0;
			for (meta in field.meta) {
				if (meta.name == "sync" || meta.name == "synced") {
					// TODO: Figure out if there is a "nicer" way to do this
					for (param in meta.params) {
						if (param.expr.equals(EConst(CString("server")))) {
							target = 0;//kha.network.Session.RPC_SERVER;
							break;
						}
						else if (param.expr.equals(EConst(CString("all")))) {
							target = 1;//kha.network.Session.RPC_ALL;
							break;
						}
					}
					synced = true;
					break;
				}
			}
			if (!synced) continue;
			
			switch (field.kind) {
			case FFun(f):
				var original = f.expr;
				
				var size = 6;
				for (arg in f.args) {
					switch (arg.type) {
					case TPath(p):
						switch (p.name) {
						case "Int":
							size += 5;
						case "Float":
							size += 9;
						case "Bool":
							size += 2;
						}
					default:
					}
				}
				
				var expr = macro @:mergeBlock {
					var size: Int = $v { size };
				};
				
				for (arg in f.args) {
					switch (arg.type) {
					case TPath(p):
						switch (p.name) {
						case "String":
							var argname = arg.name;
							expr = macro @:mergeBlock {
								$expr;
								size += $i { argname }.length + 3;
							}
						}
					default:
					}
				}
				
				var classname = Context.getLocalClass().toString();
				var methodname = field.name;

				expr = macro @:mergeBlock {
					$expr;
					size += $v { classname } .length + 2;
					size += $v { methodname } .length + 2;
					var bytes = haxe.io.Bytes.alloc(size);
					bytes.set(0, kha.network.Session.REMOTE_CALL);
					bytes.set(1, $v { target });
				}

				if (isStatic) {
					expr = macro @:mergeBlock {
						$expr;
						bytes.setInt32(2, -1);
					}
				}
				else { 
					expr = macro @:mergeBlock {
						$expr;
						bytes.setInt32(2, _syncId());
					}
				}

				expr = macro @:mergeBlock {
					$expr;
					var index = 6;
					
					bytes.setUInt16(index, $v { classname } .length);
					index += 2;
					for (i in 0...$v { classname } .length) {
						bytes.set(index, $v { classname } .charCodeAt(i));
						++index;
					}

					bytes.setUInt16(index, $v { methodname } .length);
					index += 2;
					for (i in 0...$v { methodname } .length) {
						bytes.set(index, $v { methodname } .charCodeAt(i));
						++index;
					}
				};
				for (arg in f.args) {
					switch (arg.type) {
					case TPath(p):
						switch (p.name) {
						case "Int":
							var argname = arg.name;
							expr = macro @:mergeBlock {
								$expr;
								bytes.set(index, 'I'.charCodeAt(0));
								++index;
								bytes.setInt32(index, $i { argname } );
								index += 4;
							};
						case "String":
							var argname = arg.name;
							expr = macro @:mergeBlock {
								$expr;
								bytes.set(index, 'S'.charCodeAt(0));
								++index;
								bytes.setUInt16(index, $i { argname } .length);
								index += 2;
								for (i in 0...$i { argname } .length) {
									bytes.set(index, $i { argname } .charCodeAt(i));
									++index;
								}
							};
						case "Float":
							var argname = arg.name;
							expr = macro @:mergeBlock {
								$expr;
								bytes.set(index, 'F'.charCodeAt(0) );
								++index;
								bytes.setDouble(index, $i { argname } );
								index += 8;
							};
						case "Bool":
							var argname = arg.name;
							expr = macro @:mergeBlock {
								$expr;
								bytes.set(index, 'B'.charCodeAt(0));
								++index;
								bytes.set(index, $i { argname } ? 1 : 0);
								++index;
							};
						default:
							trace("Warning: type '" + p.name + "' of property '" + arg.name + "' cannot be synced");
						}
					default:
					}
				}
				
				#if sys_server

				expr = macro {
					if (kha.network.Session.the() != null) {
						$expr;
						kha.network.Session.the().processRPC(bytes);
					}
				};
				
				#else
				
				expr = macro {
					if (kha.network.Session.the() != null) {
						$expr;
						kha.network.Session.the().sendToServer(bytes);
					}
					else {
						$original;
					}
				};
				
				#end

				fields.push({
					name: field.name + "_remotely",
					doc: null,
					meta: [],
					access: (isStatic ? [APublic, AStatic] : [APublic]),
					kind: FFun({
						ret: f.ret,
						params: f.params,
						expr: original,
						args: f.args
					}),
					pos: Context.currentPos()
				});
				
				f.expr = expr;
			default:
				trace("Warning: Synced property " + field.name + " is not a function.");
			}
		}
			
		fields.push({
			name: "_syncId",
			doc: null,
			meta: [],
			access: isBaseEntity ? [APublic] : [APublic, AOverride],
			kind: FFun({
				ret: Context.toComplexType(Context.getType("Int")),
				params: null,
				expr: macro { 
					return __syncId; },
				args: []
			}),
			pos: Context.currentPos()
		});

		if (isBaseEntity) {
			fields.push({
				name: "__syncId",
				doc: null,
				meta: [],
				access: [APublic],
				kind: FVar(macro: Int, macro kha.network.SyncBuilder.nextId++),
				pos: Context.currentPos()
			});
		}
		
		return fields;
	}
}
