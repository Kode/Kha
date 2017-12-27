package kha;

import haxe.io.Path;
import sys.FileSystem;

class HaxelibRunner {
	static function main() {
		if (Sys.systemName() != "Windows") {
			var tools = [
				Path.join([Sys.getCwd(), "Tools", "nodejs", "node"]),
				Path.join([Sys.getCwd(), "Tools", "kravur", "kravur"]),
				Path.join([Sys.getCwd(), "Tools", "oggenc", "oggenc"]),
				Path.join([Sys.getCwd(), "Kore", "Tools", "krafix", "krafix"]),
				Path.join([Sys.getCwd(), "Kore", "Tools", "kraffiti", "kraffiti"])
			];
			for (tool in tools) chmod(tool);
		}

		var io = Path.join([Sys.getCwd(), "Tools", "nodejs", "node" + sysExt()]);

		var args = Sys.args();
		args.unshift(Path.join([Sys.getCwd(), "Tools", "khamake", "khamake.js"]));

		var project = Path.normalize(args.pop());
		args.push("--from");
		args.push(project);
		args.push("--to");
		args.push(Path.join([project, "build"]));
		args.push("--haxe");
		args.push(haxePath());
		args.push("--kha");
		args.push(Path.normalize(Sys.getCwd()));

		if (Sys.systemName() == "Windows")
			Sys.exit(Sys.command('"' + io + '"', args));
		else
			Sys.exit(Sys.command(io, args));
	}

	private static function chmod(path: String): Void {
		Sys.command("chmod", ["a+x", path + sysExt()]);
	}

	private static function haxePath(): String {
		var path = Sys.getEnv("HAXEPATH");
		if (path == null) {
			path = "/usr/local/lib/haxe";
			if (!FileSystem.exists(path) || !FileSystem.isDirectory(path)) {
				path = "/usr/lib/haxe";
			}
		}
		return Path.normalize(path);
	}

	private static function sysExt(): String {
		switch (Sys.systemName()) {
		case "Linux":
			var process = new sys.io.Process("uname", ["-m"]);
			var value = process.stdout.readAll().toString();
			return "-linux" + (value.indexOf("64") != -1 ? "64" : "32");
		case "Windows":
			return ".exe";
		case "Mac":
			return "-osx";
		default:
			return "";
		}
	}
}
