if [[ "$OSTYPE" == "linux-gnu"* ]]; then
	MACHINE_TYPE=`uname -m`
	if [[ "$MACHINE_TYPE" == "armv"* ]]; then
		KINC_PLATFORM=linux_arm
	elif [[ "$MACHINE_TYPE" == "aarch64"* ]]; then
		KINC_PLATFORM=linux_arm64
	elif [[ "$MACHINE_TYPE" == "x86_64"* ]]; then
		KINC_PLATFORM=linux_x64
	else
		echo "Unknown Linux machine '$MACHINE_TYPE', please edit Tools/platform.sh"
		exit 1
	fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
	KINC_PLATFORM=macos
elif [[ "$OSTYPE" == "FreeBSD"* ]]; then
	KINC_PLATFORM=freebsd_x64
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
	KINC_PLATFORM=windows_x64
	KINC_EXE_SUFFIX=.exe
else
	echo "Unknown platform '$OSTYPE', please edit Tools/platform.sh"
	exit 1
fi
