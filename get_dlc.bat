@pushd "%~dp0"
@git submodule update --init Tools/khamake
@git submodule update --init Backends/Kore-hxcpp/khacpp
@git submodule update --depth 1 --init Tools/windows_x64
@git submodule update --init Kore
@call Kore\get_dlc.bat
@popd