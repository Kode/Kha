@pushd "%~dp0"
@if exist Tools\khamake\khamake.js (
@git submodule update --remote --merge Tools/khamake
) else (
@git submodule update --init --remote Tools/khamake
@git -C Tools/khamake checkout main
)
@if exist Backends\Kore-hxcpp\khacpp\LICENSE.txt (
@git submodule update --remote --merge Backends/Kore-hxcpp/khacpp
) else (
@git submodule update --init --remote Backends/Kore-hxcpp/khacpp
@git -C Backends/Kore-hxcpp/khacpp checkout main
)
@if exist Tools\windows_x64\LICENSE.txt (
@git submodule update --remote --merge Tools/windows_x64
) else (
@git submodule update --init --remote Tools/windows_x64
@git -C Tools/windows_x64 checkout main
)
@if exist Kore\get_dlc_dangerously (
@git submodule update --remote --merge Kore
) else (
@git submodule update --init --remote Kore
@git -C Kore checkout main
)
@call Kore\get_dlc_dangerously.bat
@popd