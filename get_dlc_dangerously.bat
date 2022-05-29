@git -C %~dp0 submodule update --init --remote Tools/khamake
@git -C %~dp0 submodule update --init --remote Backends/Kinc-hxcpp/khacpp
@git -C %~dp0 submodule update --init --remote Tools/windows_x64
@git -C %~dp0 submodule update --init --remote Kinc
@call %~dp0\Kinc\get_dlc_dangerously.bat