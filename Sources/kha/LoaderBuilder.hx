package kha;

import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr.Field;

class LoaderBuilder {
	macro static public function build(): Array<Field> {
		var fields = Context.getBuildFields();

		var p = haxe.macro.Context.resolvePath("files.json");
		var content = Json.parse(sys.io.File.getContent(p));
		var files: Iterable<Dynamic> = content.files;
		for (file in files) {
			fields.push({
				name: file.type + "_" + file.name,
				doc: null,
				meta: [],
				access: [APublic, AStatic],
				kind: FVar(macro: Dynamic, macro null),
				pos: Context.currentPos()
			});
		}
		
		return fields;
	}
}
