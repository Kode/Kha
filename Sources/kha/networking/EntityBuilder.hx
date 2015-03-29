package kha.networking;

import haxe.macro.Context;
import haxe.macro.Expr;

class EntityBuilder {
	macro static public function build(): Array<Field> {
		var fields = Context.getBuildFields();
		var newField = {
			name: "_id",
			doc: null,
			meta: [],
			access: [APublic],
			kind: FVar(macro: Int, macro 0),
			pos: Context.currentPos()
		};
		fields.push(newField);
		return fields;
	}
}
