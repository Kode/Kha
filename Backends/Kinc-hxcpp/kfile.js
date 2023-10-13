let project = new Project('Kha');

const pcreVersion = '10.42';
const tlsVersion = '2.28.2';
const zlibVersion = '1.2.13';

project.addFiles('khacpp/src/**.h', 'khacpp/src/**.cpp', 'khacpp/include/**.h');
project.addFiles('khacpp/project/libs/common/**.h', 'khacpp/project/libs/common/**.cpp');
if (platform === Platform.Windows || platform === Platform.WindowsApp) project.addFiles('khacpp/project/libs/msvccompat/**.cpp');
if (platform === Platform.Linux) project.addFiles('khacpp/project/libs/linuxcompat/**.cpp');
project.addFiles('khacpp/project/libs/regexp/**.h', 'khacpp/project/libs/regexp/**.cpp', 'khacpp/project/libs/std/**.h', 'khacpp/project/libs/std/**.cpp');


project.addFiles('khacpp/project/thirdparty/pcre2-' + pcreVersion + '-8/src/**.h', 'khacpp/project/thirdparty/pcre2-' + pcreVersion + '-8/src/**.c');
project.addFiles('khacpp/project/thirdparty/pcre2-' + pcreVersion + '-16/src/**.h', 'khacpp/project/thirdparty/pcre2-' + pcreVersion + '-16/src/**.c');

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
	project.addFile('khacpp/project/thirdparty/zlib-' + zlibVersion + '/' + file);
}

project.addFiles('khacpp/project/thirdparty/mbedtls-' + tlsVersion + '/**');

project.addFiles('*.cpp', '*.c', 'Backends/Kore/*.h', '*.natvis');
project.addFiles('lib/**');
project.addIncludeDir('lib');

const pcreExcludes = [
	'pcre2_dftables.c',
	'pcre2_fuzzsupport.c',
	'pcre2_printint.c',
	'pcre2_jit_match.c',
	'pcre2_jit_misc.c',
	'pcre2_jit_test.c',
	'pcre2_ucptables.c',
	'pcre2demo.c',
	'pcre2grep.c',
	'pcre2posix.h',
	'pcre2posix.c',
	'pcre2posix_test.c',
	'pcre2test.c',
	'sljit/**'
];

for (const file of pcreExcludes) {
	project.addExclude('khacpp/project/thirdparty/pcre2-' + pcreVersion + '-8/src/' + file);
	project.addExclude('khacpp/project/thirdparty/pcre2-' + pcreVersion + '-16/src/' + file);
}
project.addExcludes('khacpp/src/ExampleMain.cpp', 'khacpp/src/hx/Scriptable.cpp', 'khacpp/src/hx/NoFiles.cpp', 'khacpp/src/hx/cppia/**');
project.addExcludes('khacpp/src/hx/Debugger.cpp', 'khacpp/src/hx/Profiler.cpp', 'khacpp/src/hx/Telemetry.cpp');
project.addExcludes('khacpp/src/hx/NekoAPI.cpp');
project.addExcludes('khacpp/src/hx/libs/sqlite/**');
project.addExcludes('khacpp/src/hx/libs/mysql/**');

project.addIncludeDirs('khacpp/include', 'khacpp/project/thirdparty/zlib-' + zlibVersion, 'khacpp/project/libs/nekoapi', 'khacpp/project/thirdparty/mbedtls-' + tlsVersion + '/include');
project.addIncludeDir('khacpp/src/hx/libs/ssl');

//if (options.vrApi == "rift") {
//	out += "project.addIncludeDirs('C:/khaviar/LibOVRKernel/Src/');\n";
//	out += "project.addIncludeDirs('C:/khaviar/LibOVR/Include/');\n";
//}

if (platform !== Platform.Android) {
	project.addExcludes('khacpp/src/hx/AndroidCompat.cpp');
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
project.addDefine('PCRE2_STATIC');
project.addDefine('HXCPP_VISIT_ALLOCS');
project.addDefine('KHA');
project.addDefine('KORE');
project.addDefine('ROTATE90');
project.addDefine('HAVE_CONFIG_H');
project.addDefine('SUPPORT_UTF');
project.addDefine('SUPPORT_UCP');
project.addDefine('SUPPORT_UNICODE');
project.addDefine('MBEDTLS_USER_CONFIG_FILE="mbedtls_config.h"');
project.addDefine('HX_SMART_STRINGS');

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
