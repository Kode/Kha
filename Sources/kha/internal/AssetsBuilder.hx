package kha.internal;

import haxe.Json;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import sys.io.File;

using StringTools;

class AssetsBuilder {
	public static function findResources(): String {
		var output = Compiler.getOutput();
		output = output.substring(0, output.lastIndexOf("/"));
		var system = output.substring(output.lastIndexOf("/") + 1);
		if (system.endsWith("-build")) system = system.substr(0, system.length - "-build".length);
		output = output.substring(0, output.lastIndexOf("/"));
		return output + "/" + system + "-resources/";
	}
	
	macro static public function build(type: String): Array<Field> {
		var fields = Context.getBuildFields();
		var content = Json.parse(File.getContent(findResources() + "files.json"));
		var files: Iterable<Dynamic> = content.files;
		for (file in files) {
			var name = file.name;
			var filename = file.files[0];
			
			if (file.type == type) {
				switch (type) {
					case "image":
						fields.push({
							name: file.name,
							doc: null,
							meta: [],
							access: [APublic],
							kind: FVar(macro: kha.Image, macro null),
							pos: Context.currentPos()
						});
					case "sound":
						fields.push({
							name: file.name,
							doc: null,
							meta: [],
							access: [APublic],
							kind: FVar(macro: kha.Sound, macro null),
							pos: Context.currentPos()
						});
					case "blob":
						fields.push({
							name: file.name,
							doc: null,
							meta: [],
							access: [APublic],
							kind: FVar(macro: kha.Blob, macro null),
							pos: Context.currentPos()
						});
					case "video":
						fields.push({
							name: file.name,
							doc: null,
							meta: [],
							access: [APublic],
							kind: FVar(macro: kha.Video, macro null),
							pos: Context.currentPos()
						});
				}
				
				fields.push({
					name: file.name + "Name",
					doc: null,
					meta: [],
					access: [APublic],
					kind: FVar(macro: String, macro $v { name }),
					pos: Context.currentPos()
				});
				
				fields.push({
					name: file.name + "Description",
					doc: null,
					meta: [],
					access: [APublic],
					kind: FVar(macro: Dynamic, macro $v { file }),
					pos: Context.currentPos()
				});
				
				var loadExpressions = macro { };
				switch (type) {
					case "image":
						loadExpressions = macro {
							Assets.loadImage($v{name}, function (image: Image) {
								done();
							});
						};
					case "sound":
						loadExpressions = macro {
							Assets.loadSound($v{name}, function (sound: Sound) {
								done();
							});
						};
					case "blob":
						loadExpressions = macro {
							Assets.loadBlob($v{name}, function (blob: Blob) {
								done();
							});
						};
					case "video":
						loadExpressions = macro {
							Assets.loadVideo($v{name}, function (video: Video) {
								done();
							});
						};
				}
				
				fields.push({
					name: file.name + "Load",
					doc: null,
					meta: [],
					access: [APublic],
					kind: FFun({
						ret: null,
						params: null,
						expr: loadExpressions,
						args: [{
							value: null,
							type: Context.toComplexType(Context.getType("kha.internal.VoidCallback")),
							opt: null,
							name: "done"
						}]
					}),
					pos: Context.currentPos()
				});
				
				fields.push({
					name: file.name + "Unload",
					doc: null,
					meta: [],
					access: [APublic],
					kind: FFun({
						ret: null,
						params: null,
						expr: macro {
							$i{name}.unload();
							$i{name} = null;
						},
						args: []
					}),
					pos: Context.currentPos()
				});
			}
		}
		
		return fields;
	}
}
