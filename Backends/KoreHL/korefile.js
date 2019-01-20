let project = new Project('Kha', __dirname);

project.addFiles('KoreC/**', 'hl/include/**', 'hl/src/std/**', 'hl/src/alloc.c', 'hl/src/hl.h', 'hl/src/hlc.h', 'hl/src/hlmodule.h', 'hl/src/opcodes.h');
project.addExcludes('hl/src/std/unicase.c');
project.addExcludes('hl/src/std/debug.c');
project.addIncludeDirs('hl/src', 'hl/include/pcre');

if (platform == Platform.OSX) project.addDefine('KORE_DEBUGDIR="osx-hl"');
if (platform == Platform.iOS) project.addDefine('KORE_DEBUGDIR="ios-hl"');
if (platform !== Platform.Windows || audio !== AudioApi.DirectSound) {
	project.addDefine('KORE_MULTITHREADED_AUDIO');
}

project.addDefine('KORE');
project.addDefine('KOREC');
project.addDefine('ROTATE90');
project.addDefine('LIBHL_STATIC');
project.cpp11 = true;
project.c11 = true;

if (platform === Platform.Windows || platform === Platform.WindowsApp) {
	project.addDefine('_WINSOCK_DEPRECATED_NO_WARNINGS');
}
if (platform === Platform.Windows) {
	project.addLib('ws2_32');
}

resolve(project);
