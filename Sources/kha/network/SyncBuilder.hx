package kha.network;

import haxe.macro.Context;
import haxe.macro.Expr.Field;

class SyncBuilder {
	macro static public function build(): Array<Field> {
		var fields = Context.getBuildFields();
		
		for (field in fields) {
			var synced = false;
			for (meta in field.meta) {
				if (meta.name == "sync" || meta.name == "synced") {
					synced = true;
					break;
				}
			}
			if (!synced) continue;
			
			switch (field.kind) {
			case FFun(f):
				var original = f.expr;
				#if sys_server
				
				var size = 1;
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
					var index = 1;
					
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
						}
					default:
					}
				}
				
				expr = macro {
					if (kha.network.Session.the() != null) {
						$expr;
						kha.network.Session.the().sendToEverybody(bytes);
					}
					$original;
				};
				
				#else
				
				var expr = macro {
					if (kha.network.Session.the() == null) {
						$original;
					}
				};
				
				fields.push({
					name: field.name + "_remotely",
					doc: null,
					meta: [],
					access: [APublic, AStatic],
					kind: FFun({
						ret: f.ret,
						params: f.params,
						expr: original,
						args: f.args
					}),
					pos: Context.currentPos()
				});
				
				#end
				f.expr = expr;
			default:
				trace("Warning: Synced property " + field.name + " is not a function.");
			}
		}
		
		return fields;
	}
}
