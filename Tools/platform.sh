if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	MACHINE_TYPE=`uname -m`
	if [[ "$MACHINE_TYPE" == "aarch64"* ]]; then
		KORE_PLATFORM=linux_arm64
	elif [[ "$MACHINE_TYPE" == "x86_64"* ]]; then
		KORE_PLATFORM=linux_x64
	else
		echo "Unknown Linux machine '$MACHINE_TYPE', please edit Tools/platform.sh"
		exit 1
	fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
	MACHINE_TYPE=`uname -m`
	if [[ "$MACHINE_TYPE" == "arm64"* ]]; then
		KORE_PLATFORM=macos_arm64
	elif [[ "$MACHINE_TYPE" == "x86_64"* ]]; then
		KORE_PLATFORM=macos_x64
	else
		echo "Unknown macOS machine '$MACHINE_TYPE', please edit Tools/platform.sh"
		exit 1
	fi
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
	KORE_PLATFORM=windows_x64
	KORE_EXE_SUFFIX=.exe
else
	echo "Unknown platform '$OSTYPE', please edit Tools/platform.sh"
	exit 1
fi
