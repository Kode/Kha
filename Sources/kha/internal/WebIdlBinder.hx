package kha.internal;

import haxe.Json;
import haxe.macro.Printer;

import sys.io.File;
import sys.FileSystem;

import webidl.Options as WebIdlOptions;
import webidl.Generate;
import webidl.Module;

using StringTools;

typedef KhabindOptions = {
    idlFile:String,
    nativeLib:String,
    sourcesDir:String,
    chopPrefix:String,
    hxPackageName:String,
    hxModuleName:String,
    autoGC:Bool,
    includes:Array<String>
}

class WebIdlBinder {

    public static function generate() {
        var bindOpts:KhabindOptions = Json.parse(File.getContent("khabind.json"));
        var includeCode = bindOpts.includes.map((inc) -> {return "#include " + inc;}).join("\n");
        var webIdlOpts:WebIdlOptions = {
            idlFile: bindOpts.idlFile,
            nativeLib: bindOpts.nativeLib,
            includeCode: includeCode,
            chopPrefix: bindOpts.chopPrefix,
            autoGC: bindOpts.autoGC,
        }

        var invalidateCache = false;
        var sourceFile = bindOpts.idlFile;

        var targetFile = "khabind/" + bindOpts.nativeLib + ".cpp";
        var sourceModTime = 0.;
        var targetModTime = 0.; 
        if (FileSystem.exists(targetFile)) {
            sourceModTime = FileSystem.stat(sourceFile).mtime.getTime();
            targetModTime = FileSystem.stat(targetFile).mtime.getTime();
            if (sourceModTime > targetModTime) invalidateCache = true;
        } else {
            invalidateCache = true;
        }

        if (invalidateCache) {
            // Generate C++ Bindings
            Generate.generateCpp(webIdlOpts);
            FileSystem.createDirectory("khabind");
            FileSystem.rename(bindOpts.nativeLib + ".cpp", "khabind/" + bindOpts.nativeLib + ".cpp");

            // Genterate Haxe externs
            var printer = new Printer("    ");
            FileSystem.createDirectory(["Sources", bindOpts.hxPackageName.replace(".", "/")].join("/"));

            var content = 'package ${bindOpts.hxPackageName};\n\n#if hl\n' + Module.buildTypes(webIdlOpts, true).map((type) -> {
                    return printer.printTypeDefinition(type);
                }).join("\n") + "\n#elseif js\n" + Module.buildTypes(webIdlOpts).map((type) -> {
                    return printer.printTypeDefinition(type);
                }).join("\n") + "#end\n";

            File.saveContent(
                ["Sources", bindOpts.hxPackageName.replace(".", "/"), capitalize(bindOpts.hxModuleName) + ".hx"].join("/"),
                content
            );
        }
    }

    /**
	 * Capitalize the first letter of a string
	 * @param text The string to capitalize
	 */
	private static function capitalize(text:String) {
		return text.charAt(0).toUpperCase() + text.substring(1);
	}
}
