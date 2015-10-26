package kha;

import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.Serializer;
import sys.io.File;

class LoaderBuilder {
	macro static public function build(): Array<Field> {
		var fields = Context.getBuildFields();

		var p = Context.resolvePath("files.json");
		var content = Json.parse(File.getContent(p));
		var files: Iterable<Dynamic> = content.files;
		for (file in files) {
			var name = file.name;
			var filename = file.files[0];
			
			if (file.type == "shader") {
				var serialized = Serializer.run(File.getBytes(Context.resolvePath(file.files[0])));
				fields.push({
					name: file.type + "_" + file.name,
					doc: null,
					meta: [],
					access: [APublic, AStatic],
					kind: FVar(macro: { name: String, file: String, content: String }, macro { name: $v { name }, file: $v { filename }, content: $v { serialized } }),
					pos: Context.currentPos()
				});
			}
			else {
				fields.push({
					name: file.type + "_" + file.name,
					doc: null,
					meta: [],
					access: [APublic, AStatic],
					kind: FVar(macro: { name: String, files: Array<String> }, macro { name: $v { name }, files: [$v { filename }] }),
					pos: Context.currentPos()
				});
			}
		}
		
		return fields;
	}
}
