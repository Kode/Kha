@pushd "%~dp0"
@git submodule update --init Tools/khamake
@git submodule update --init Backends/Kinc-hxcpp/khacpp
@git submodule update --init Tools/windows_x64
@git submodule update --init Kinc
@call Kinc\get_dlc.bat
@popd