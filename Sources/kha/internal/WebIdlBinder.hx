package kha.internal;

#if macro
import haxe.Json;
import haxe.macro.Printer;
import haxe.macro.Expr;

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
    autoGC:Bool,
    includes:Array<String>
}

class WebIdlBinder {

    public static function generate(optionJsonString:String, noCache:Bool = false) {
        var bindOpts:KhabindOptions = Json.parse(optionJsonString);
        var includeCode = bindOpts.includes.map((inc) -> {return "#include " + inc;}).join("\n");
        var webIdlOpts:WebIdlOptions = {
            idlFile: bindOpts.idlFile,
            nativeLib: bindOpts.nativeLib,
            includeCode: includeCode,
            chopPrefix: bindOpts.chopPrefix,
            autoGC: bindOpts.autoGC,
        }

        var invalidateCache = noCache;
        var sourceFile = bindOpts.idlFile;

        if (!invalidateCache) {
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
        }

        if (invalidateCache) {
            // Generate C++ Bindings
            Generate.generateCpp(webIdlOpts);
            FileSystem.createDirectory("khabind");
            FileSystem.rename(bindOpts.nativeLib + ".cpp", "khabind/" + bindOpts.nativeLib + ".cpp");

            // Genterate Haxe externs
            var printer = new Printer("    ");
            FileSystem.createDirectory("Sources/" + bindOpts.nativeLib);

            var hlTypes = Module.buildTypes(webIdlOpts, true);
            var jsTypes = Module.buildTypes(webIdlOpts, false);

            for (i in 0...hlTypes.length) {
                var hlType = hlTypes[i];
                var jsType = jsTypes[i];

                var moduleContent = 'package ${bindOpts.nativeLib};\n\n#if hl\n';
                moduleContent += printer.printTypeDefinition(hlType) + "\n";
                moduleContent += "#elseif js\n";
                moduleContent += printer.printTypeDefinition(jsType) + "\n";
                moduleContent += "#end\n";

                File.saveContent(
                    ["Sources", bindOpts.nativeLib, hlType.name + ".hx"].join("/"),
                    moduleContent
                );
            }
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
#end
