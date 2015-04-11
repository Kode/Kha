package kha.networking;

import haxe.macro.Context;
import haxe.macro.Expr.Field;

class ControllerBuilder {
	macro static public function build(): Array<Field> {
		var fields = Context.getBuildFields();
		
		for (field in fields) {
			switch (field.kind) {
			case FFun(f):
				var expr = macro {
					var bytes = haxe.io.Bytes.alloc(100);
				};
				var index: Int = 0;
				for (arg in f.args) {
					switch (arg.type) {
						case TPath(p):
							switch (p.name) {
							case "Int":
								var argname = arg.name;
								expr = macro {
									$expr;
									//bytes.setInt32($v { index }, $v { argname });
								};
								index += 4;
							case "String":
								var argname = arg.name;
								expr = macro {
									$expr;
									//bytes.set($v { index }, $v { argname }.charCodeAt(0));
								};
								index += 1;
							}
						default:
					}
				}
				var original = f.expr;
				f.expr = macro { $expr; $original; };
			default:
			}
		}
		
		return fields;
	}
}
