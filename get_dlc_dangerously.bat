@pushd "%~dp0"
@if exist Tools\khamake\khamake.js (
@git submodule update --remote --merge Tools/khamake
) else (
@git submodule update --init --remote Tools/khamake
@git -C Tools/khamake checkout main
)
@if exist Backends\Kinc-hxcpp\khacpp\LICENSE.txt (
@git submodule update --remote --merge Backends/Kinc-hxcpp/khacpp
) else (
@git submodule update --init --remote Backends/Kinc-hxcpp/khacpp
@git -C Backends/Kinc-hxcpp/khacpp checkout main
)
@if exist Tools\windows_x64\LICENSE.txt (
@git submodule update --remote --merge Tools/windows_x64
) else (
@git submodule update --init --remote Tools/windows_x64
@git -C Tools/windows_x64 checkout main
)
@if exist Kinc\get_dlc_dangerously (
@git submodule update --remote --merge Kinc
) else (
@git submodule update --init --remote Kinc
@git -C Kinc checkout main
)
@call Kinc\get_dlc_dangerously.bat
@popd