var project = new Project('Kha');

project.addFiles('hl/**');
project.addIncludeDirs('hl/include');

if (platform == Platform.OSX) project.addDefine('KORE_DEBUGDIR="osx"');
if (platform == Platform.iOS) project.addDefine('KORE_DEBUGDIR="ios"');

project.addDefine('KORE');
project.addDefine('ROTATE90');

if (platform === Platform.Windows || platform === Platform.WindowsApp) {
	project.addDefine('_WINSOCK_DEPRECATED_NO_WARNINGS');
}
if (platform === Platform.Windows) {
	project.addLib('ws2_32');
}

return project;
