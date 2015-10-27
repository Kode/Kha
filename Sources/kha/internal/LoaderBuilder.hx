package kha.internal;

import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import sys.io.File;

class LoaderBuilder {
	macro static public function build(type: String): Array<Field> {
		var fields = Context.getBuildFields();
		
		var p = Context.resolvePath("files.json");
		var content = Json.parse(File.getContent(p));
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
					case "music":
						fields.push({
							name: file.name,
							doc: null,
							meta: [],
							access: [APublic],
							kind: FVar(macro: kha.Music, macro null),
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
							Loader.loadImage($v{name}, function (image: Image) {
								$i{name} = image;
								done();
							});
						};
					case "sound":
						loadExpressions = macro {
							Loader.loadSound($v{name}, function (sound: Sound) {
								$i{name} = sound;
								done();
							});
						};
					case "music":
						loadExpressions = macro {
							Loader.loadMusic($v{name}, function (music: Music) {
								$i{name} = music;
								done();
							});
						};
					case "blob":
						loadExpressions = macro {
							Loader.loadBlob($v{name}, function (blob: Blob) {
								$i{name} = blob;
								done();
							});
						};
					case "video":
						loadExpressions = macro {
							Loader.loadVideo($v{name}, function (video: Video) {
								$i{name} = video;
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
