package kha.network;

import haxe.io.Bytes;
import haxe.macro.Context;
import haxe.macro.Expr;

class EntityBuilder {
	public static var nextId: Int = 0;
	
	macro static public function build(): Array<Field> {
		var fields = Context.getBuildFields();
		
		var isBaseEntity = false;
		for (i in Context.getLocalClass().get().interfaces) {
			var intf = i.t.get();
			if (intf.module == "kha.network.Entity") {
				isBaseEntity = true;
				break;
			}
		}
		
		var receive = macro {
			
		};
		
		var send = macro {
			
		};
		
		if (!isBaseEntity) {
			receive = macro {
				offset += super._receive(offset, bytes);
			};
			
			send = macro {
				offset += super._send(offset, bytes);
			};
		}
		
		var index: Int = 0;
		for (field in fields) {
			var replicated = false;
			for (meta in field.meta) {
				if (meta.name == "replicate" || meta.name == "replicated") {
					replicated = true;
					break;
				}
			}
			if (!replicated) continue;
			
			switch (field.kind) {
			case FVar(t, e):
				var fieldname = field.name;
				switch (t) {
				case TPath(p):
					switch (p.name) {
					case "Int":
						send = macro {
							$send;
							bytes.setInt32(offset + $v { index }, this.$fieldname);
						};
						receive = macro {
							$receive;
							this.$fieldname = bytes.getInt32(offset + $v { index } );
						};
						index += 4;
					case "Float":
						send = macro {
							$send;
							bytes.setDouble(offset + $v { index }, this.$fieldname);
						};
						receive = macro {
							$receive;
							this.$fieldname = bytes.getDouble(offset + $v { index } );
						};
						index += 8;
					case "Bool":
						send = macro {
							$send;
							bytes.set(offset + $v { index }, this.$fieldname ? 1 : 0);
						};
						receive = macro {
							$receive;
							this.$fieldname = bytes.get(offset + $v { index } ) == 1 ? true : false;
						};
						index += 1;
					}
				default:
				}
			default:
			}
		}
		
		send = macro {
			$send;
			return $v { index };
		};
		
		receive = macro {
			$receive;
			return $v { index };
		};
		
		fields.push({
			name: "_send",
			doc: null,
			meta: [],
			access: isBaseEntity ? [APublic] : [APublic, AOverride],
			kind: FFun({
				ret: Context.toComplexType(Context.getType("Int")),
				params: null,
				expr: send,
				args: [{
					value: null,
					type: Context.toComplexType(Context.getType("Int")),
					opt: null,
					name: "offset" },
					{
					value: null,
					type: Context.toComplexType(Context.getType("haxe.io.Bytes")),
					opt: null,
					name: "bytes"}]
			}),
			pos: Context.currentPos()
		});
		
		fields.push({
			name: "_receive",
			doc: null,
			meta: [],
			access: isBaseEntity ? [APublic] : [APublic, AOverride],
			kind: FFun({
				ret: Context.toComplexType(Context.getType("Int")),
				params: null,
				expr: receive,
				args: [{
					value: null,
					type: Context.toComplexType(Context.getType("Int")),
					opt: null,
					name: "offset" },
					{
					value: null,
					type: Context.toComplexType(Context.getType("haxe.io.Bytes")),
					opt: null,
					name: "bytes"}]
			}),
			pos: Context.currentPos()
		});
		
		fields.push({
			name: "_id",
			doc: null,
			meta: [],
			access: isBaseEntity ? [APublic] : [APublic, AOverride],
			kind: FFun({
				ret: Context.toComplexType(Context.getType("Int")),
				params: null,
				expr: macro { return __id; },
				args: []
			}),
			pos: Context.currentPos()
		});
		
		var size = macro {
			return $v { index };
		};
		
		if (!isBaseEntity) {
			size = macro {
				return super._size() + $v { index };
			};
		}
		
		fields.push({
			name: "_size",
			doc: null,
			meta: [],
			access: isBaseEntity ? [APublic] : [APublic, AOverride],
			kind: FFun({
				ret: Context.toComplexType(Context.getType("Int")),
				params: null,
				expr: size,
				args: []
			}),
			pos: Context.currentPos()
		});
			
		if (isBaseEntity) {
			fields.push({
				name: "__id",
				doc: null,
				meta: [],
				access: [APublic],
				kind: FVar(macro: Int, macro kha.network.EntityBuilder.nextId++),
				pos: Context.currentPos()
			});
		}
		
		return fields;
	}
}
