@git -C %~dp0 submodule update --init Tools/khamake
@git -C %~dp0 submodule update --init Backends/Kinc-hxcpp/khacpp
@git -C %~dp0 submodule update --init Tools/windows_x64
@git -C %~dp0 submodule update --init Kinc
@call %~dp0\Kinc\get_dlc.bat