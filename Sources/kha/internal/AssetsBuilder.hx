package kha.internal;

import haxe.Json;
import haxe.macro.Compiler;
import haxe.macro.Context;
import haxe.macro.Expr;
#if macro
import sys.io.File;
#end

using StringTools;

class AssetsBuilder {
	public static function findResources(): String {
		#if macro
		var output = Compiler.getOutput();
		if (output == "Nothing__" || output == "") { // For Haxe background compilation
			#if kha_output
			output = Compiler.getDefine("kha_output");
			if (output.startsWith('"')) {
				output = output.substr(1, output.length - 2);
			}
			#end
		}
		output = output.replace("\\", "/");
		output = output.substring(0, output.lastIndexOf("/"));
		if (output.endsWith("/Assets")) { // For Unity
			output = output.substring(0, output.lastIndexOf("/"));
		}
		if (output.lastIndexOf("/") >= 0) {
			var system = output.substring(output.lastIndexOf("/") + 1);
			if (system.endsWith("-build"))
				system = system.substr(0, system.length - "-build".length);
			output = output.substring(0, output.lastIndexOf("/"));
			return output + "/" + system + "-resources/";
		}
		else {
			if (output.endsWith("-build"))
				output = output.substr(0, output.length - "-build".length);
			if (output == "")
				output = "empty";
			return output + "-resources/";
		}
		#else
		return "";
		#end
	}

	macro static public function build(type: String): Array<Field> {
		var fields = Context.getBuildFields();
		var content = Json.parse(File.getContent(findResources() + "files.json"));
		var files: Iterable<Dynamic> = content.files;

		var names = new Array<Expr>();

		for (file in files) {
			var name = file.name;
			final pos = Context.currentPos();
			var filesize: Int = file.file_sizes[0];

			if (file.type == type) {
				names.push(macro $v{name});

				switch (type) {
					case "image":
						fields.push({
							name: name,
							meta: [{pos: pos, name: ":keep"}],
							access: [APublic],
							kind: FVar(macro:kha.Image, macro null),
							pos: pos
						});
					case "sound":
						fields.push({
							name: name,
							meta: [{pos: pos, name: ":keep"}],
							access: [APublic],
							kind: FVar(macro:kha.Sound, macro null),
							pos: pos
						});
					case "blob":
						fields.push({
							name: name,
							meta: [{pos: pos, name: ":keep"}],
							access: [APublic],
							kind: FVar(macro:kha.Blob, macro null),
							pos: pos
						});
					case "font":
						fields.push({
							name: name,
							meta: [{pos: pos, name: ":keep"}],
							access: [APublic],
							kind: FVar(macro:kha.Font, macro null),
							pos: pos
						});
					case "video":
						fields.push({
							name: name,
							meta: [{pos: pos, name: ":keep"}],
							access: [APublic],
							kind: FVar(macro:kha.Video, macro null),
							pos: pos
						});
				}

				fields.push({
					name: name + "Name",
					meta: [],
					access: [APublic],
					kind: FVar(macro:String, macro $v{name}),
					pos: pos
				});

				fields.push({
					name: name + "Description",
					meta: [{pos: pos, name: ":keep"}],
					access: [APublic],
					kind: FVar(macro:Dynamic, macro $v{file}),
					pos: pos
				});

				fields.push({
					name: name + "Size",
					doc: null,
					meta: [],
					access: [APublic],
					kind: FVar(macro:Dynamic, macro $v{filesize}),
					pos: Context.currentPos()
				});

				var loadExpressions = macro {};
				switch (type) {
					case "image":
						loadExpressions = macro {
							Assets.loadImage($v{name}, function(image: Image) done($v{filesize}), failure);
						};
					case "sound":
						loadExpressions = macro {
							Assets.loadSound($v{name}, function(sound: Sound) done($v{filesize}), failure);
						};
					case "blob":
						loadExpressions = macro {
							Assets.loadBlob($v{name}, function(blob: Blob) done($v{filesize}), failure);
						};
					case "font":
						loadExpressions = macro {
							Assets.loadFont($v{name}, function(font: Font) done($v{filesize}), failure);
						};
					case "video":
						loadExpressions = macro {
							Assets.loadVideo($v{name}, function(video: Video) done($v{filesize}), failure);
						};
				}

				fields.push({
					name: name + "Load",
					meta: [],
					access: [APublic],
					kind: FFun({
						ret: null,
						params: null,
						expr: loadExpressions,
						args: [
							{
								value: null,
								type: Context.toComplexType(Context.getType("kha.internal.IntCallback")),
								opt: null,
								name: "done"
							},
							{
								value: null,
								type: Context.toComplexType(Context.getType("kha.internal.AssetErrorCallback")),
								opt: true,
								name: "failure"
							}
						]
					}),
					pos: pos
				});

				fields.push({
					name: name + "Unload",
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
					pos: pos
				});
			}
		}

		fields.push({
			name: "names",
			meta: [],
			access: [APublic],
			kind: FVar(macro:Array<String>, macro $a{names}),
			pos: Context.currentPos()
		});

		return fields;
	}
}
