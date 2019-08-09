let project = new Project('Kha');

const pcreVersion = '8.42';
const tlsVersion = '2.9.0';
const zlibVersion = '1.2.11';

project.addFiles('Backends/Kore/khacpp/src/**.h', 'Backends/Kore/khacpp/src/**.cpp', 'Backends/Kore/khacpp/include/**.h');
project.addFiles('Backends/Kore/khacpp/project/libs/common/**.h', 'Backends/Kore/khacpp/project/libs/common/**.cpp');
if (platform === Platform.Windows || platform === Platform.WindowsApp) project.addFiles('Backends/Kore/khacpp/project/libs/msvccompat/**.cpp');
if (platform === Platform.Linux) project.addFiles('Backends/Kore/khacpp/project/libs/linuxcompat/**.cpp');
project.addFiles('Backends/Kore/khacpp/project/libs/regexp/**.h', 'Backends/Kore/khacpp/project/libs/regexp/**.cpp', 'Backends/Kore/khacpp/project/libs/std/**.h', 'Backends/Kore/khacpp/project/libs/std/**.cpp');

project.addFiles('Backends/Kore/khacpp/project/thirdparty/pcre-' + pcreVersion + '/**.h', 'Backends/Kore/khacpp/project/thirdparty/pcre-' + pcreVersion + '/**.c');

const zlibFiles = [
	'**.h',
	'adler32.c',
	'compress.c',
	'crc32.c',
	'gzio.c',
	'uncompr.c',
	'deflate.c',
	'trees.c',
	'zutil.c',
	'inflate.c',
	'infback.c',
	'inftrees.c',
	'inffast.c'
];

for (const file of zlibFiles) {
	project.addFile('Backends/Kore/khacpp/project/thirdparty/zlib-' + zlibVersion + '/' + file);
}

project.addFiles('Backends/Kore/khacpp/project/thirdparty/mbedtls-' + tlsVersion + '/**');

project.addFiles('Backends/Kore/*.cpp', 'Backends/Kore/*.c', 'Backends/Kore/*.h', 'Backends/Kore/*.natvis');
project.addFiles('Backends/Kore/lib/**');
project.addIncludeDir('Backends/Kore/lib');

const pcreExcludes = [
	'dftables.c',
	'pcredemo.c',
	'pcregrep.c',
	'pcretest.c',
	'pcre_jit_test.c',
	'pcre_printint.c',
	'pcre16_printint.c',
	'pcre32_printint.c',
	'sljit/**'
];

for (const file of pcreExcludes) {
	project.addExclude('Backends/Kore/khacpp/project/thirdparty/pcre-' + pcreVersion + '/' + file);
}
project.addExcludes('Backends/Kore/khacpp/src/ExampleMain.cpp', 'Backends/Kore/khacpp/src/hx/Scriptable.cpp', 'Backends/Kore/khacpp/src/hx/NoFiles.cpp', 'Backends/Kore/khacpp/src/hx/cppia/**');
project.addExcludes('Backends/Kore/khacpp/src/hx/Debugger.cpp', 'Backends/Kore/khacpp/src/hx/Profiler.cpp', 'Backends/Kore/khacpp/src/hx/Telemetry.cpp');
project.addExcludes('Backends/Kore/khacpp/src/hx/NekoAPI.cpp');
project.addExcludes('Backends/Kore/khacpp/src/hx/libs/sqlite/**');
project.addExcludes('Backends/Kore/khacpp/src/hx/libs/mysql/**');

project.addIncludeDirs('Backends/Kore/khacpp/include', 'Backends/Kore/khacpp/project/thirdparty/pcre-' + pcreVersion, 'Backends/Kore/khacpp/project/thirdparty/zlib-' + zlibVersion, 'Backends/Kore/khacpp/project/libs/nekoapi', 'Backends/Kore/khacpp/project/thirdparty/mbedtls-' + tlsVersion + '/include');

//if (options.vrApi == "rift") {
//	out += "project.addIncludeDirs('C:/khaviar/LibOVRKernel/Src/');\n";
//	out += "project.addIncludeDirs('C:/khaviar/LibOVR/Include/');\n";
//}

if (platform !== Platform.Android) {
	project.addExcludes('Backends/Kore/khacpp/src/hx/AndroidCompat.cpp');
}

if (platform === Platform.Windows) {
	project.addDefine('HX_WINDOWS');
	project.addLib('Shlwapi');
	project.addLib('Crypt32');
}
if (platform === Platform.WindowsApp) {
	project.addDefine('HX_WINDOWS');
	project.addDefine('HX_WINRT');
}
if (platform !== Platform.Windows || audio !== AudioApi.DirectSound) {
	project.addDefine('KORE_MULTITHREADED_AUDIO');
}
if (platform === Platform.OSX) {
	project.addDefine('HXCPP_M64');
	project.addDefine('HX_MACOS');
}
if (platform === Platform.Linux) project.addDefine('HX_LINUX');
if (platform === Platform.iOS) {
	project.addDefine('IPHONE');
	project.addDefine('HX_IPHONE');
}
if (platform === Platform.tvOS) {
	project.addDefine('APPLETV');
}
if (platform === Platform.Android) {
	project.addDefine('ANDROID');
	project.addDefine('_ANDROID');
	project.addDefine('HX_ANDROID');
	project.addDefine('HXCPP_ANDROID_PLATFORM=24');
}
if (platform === Platform.OSX) {
	project.addDefine('KORE_DEBUGDIR="osx"');
	project.addLib('Security');
}
if (platform === Platform.iOS) project.addDefine('KORE_DEBUGDIR="ios"');

// project:addDefine('HXCPP_SCRIPTABLE');
project.addDefine('STATIC_LINK');
project.addDefine('PCRE_STATIC');
project.addDefine('HXCPP_VISIT_ALLOCS');
project.addDefine('KHA');
project.addDefine('KORE');
project.addDefine('ROTATE90');
project.addDefine('HAVE_CONFIG_H');
project.addDefine('SUPPORT_UTF');
project.addDefine('SUPPORT_UCP');

//if (Options.vrApi === "gearvr") {
//	out += "project.addDefine('VR_GEAR_VR');\n";
//}
//else if (Options.vrApi === "cardboard") {
//	out += "project.addDefine('VR_CARDBOARD');\n";
//}
//else if (Options.vrApi === "rift") {
//	out += "project.addDefine('VR_RIFT');\n";
//}
//
//if (options.vrApi == "rift") {
//	out += "project.addLib('C:/khaviar/LibOVRKernel/Lib/Windows/Win32/Release/VS2013/LibOVRKernel');\n";
//	out += "project.addLib('C:/khaviar/LibOVR/Lib/Windows/Win32/Release/VS2013/LibOVR');\n";
//}

if (platform === Platform.Windows || platform === Platform.WindowsApp) {
	project.addDefine('_WINSOCK_DEPRECATED_NO_WARNINGS');
}
if (platform === Platform.Windows) {
	project.addLib('ws2_32');
}

resolve(project);
