var project = new Project('Kha');

project.addFiles('KoreC/**', 'hl/include/**', 'hl/src/std/**', 'hl/src/alloc.c', 'hl/src/hl.h', 'hl/src/hlc.h', 'hl/src/hlmodule.h', 'hl/src/opcodes.h');
project.addExcludes('hl/src/std/unicase.c');
project.addIncludeDirs('hl/src', 'hl/include/pcre');

if (platform == Platform.OSX) project.addDefine('KORE_DEBUGDIR="osx-hl"');
if (platform == Platform.iOS) project.addDefine('KORE_DEBUGDIR="ios-hl"');

project.addDefine('KORE');
project.addDefine('KOREC');
project.addDefine('ROTATE90');

if (platform === Platform.Windows || platform === Platform.WindowsApp) {
	project.addDefine('_WINSOCK_DEPRECATED_NO_WARNINGS');
}
if (platform === Platform.Windows) {
	project.addLib('ws2_32');
}

return project;
