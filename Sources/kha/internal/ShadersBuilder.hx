package kha.internal;

import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.Serializer;
import sys.io.File;

using StringTools;

class ShadersBuilder {
	macro static public function build(): Array<Field> {
		var fields = Context.getBuildFields();
		
		var content = Json.parse(File.getContent(AssetsBuilder.findResources() + "files.json"));
		var files: Iterable<Dynamic> = content.files;
		
		var init = macro { };
		
		for (file in files) {
			var name: String = file.name;
			var fixedName: String = name;
			var dataName = fixedName + "Data";
			var filename = file.files[0];
			
			if (file.type == "shader") {
				var serialized = Serializer.run(File.getBytes(AssetsBuilder.findResources() + file.files[0]));
				fields.push({
					name: dataName,
					doc: null,
					meta: [],
					access: [APrivate, AStatic],
					kind: FVar(macro: String, macro $v { serialized } ),
					pos: Context.currentPos()
				});
				
				if (name.endsWith("_vert")) {
					fields.push({
						name: fixedName,
						doc: null,
						meta: [],
						access: [APublic, AStatic],
						kind: FVar(macro: kha.graphics4.VertexShader, macro null),
						pos: Context.currentPos()
					});
					
					init = macro {
						$init;
						{
							var data = Reflect.field(Shaders, $v { dataName } );
							var bytes: haxe.io.Bytes = haxe.Unserializer.run(data);
							$i { fixedName } = new kha.graphics4.VertexShader(kha.Blob.fromBytes(bytes));
						}
					};
				}
				else {
					fields.push({
						name: fixedName,
						doc: null,
						meta: [],
						access: [APublic, AStatic],
						kind: FVar(macro: kha.graphics4.FragmentShader, macro null),
						pos: Context.currentPos()
					});
					
					init = macro {
						$init;
						{
							var data = Reflect.field(Shaders, $v { dataName } );
							var bytes: haxe.io.Bytes = haxe.Unserializer.run(data);
							$i { fixedName } = new kha.graphics4.FragmentShader(kha.Blob.fromBytes(bytes));
						}
					};
				}
			}
		}
		
		fields.push({
			name: "init",
			doc: null,
			meta: [],
			access: [APublic, AStatic],
			kind: FFun({
				ret: null,
				params: null,
				expr: init,
				args: []
			}),
			pos: Context.currentPos()
		});
		
		return fields;
	}
}
