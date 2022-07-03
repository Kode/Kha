@pushd "%~dp0"
@git submodule update --init --remote Tools/khamake
@git submodule update --init --remote Backends/Kinc-hxcpp/khacpp
@git submodule update --init --remote Tools/windows_x64
@git submodule update --init --remote Kinc
@call Kinc\get_dlc_dangerously.bat
@popd