#include <Kore/pch.h>
#include <Kore/Graphics/Graphics.h>
#include <Kore/Input/Gamepad.h>
#include <Kore/Input/Keyboard.h>
#include <Kore/Input/Mouse.h>
#include <Kore/Input/Sensor.h>
#include <Kore/Input/Surface.h>
#include <Kore/Audio/Audio.h>
#include <Kore/Audio/Mixer.h>
#include <Kore/IO/FileReader.h>
#include <Kore/Log.h>
#include <Kore/Threads/Mutex.h>
#include <Kore/Math/Random.h>
#include <Kore/System.h>
#include <Kore/Math/Core.h>

#include <limits>
#include <stdio.h>
#include <stdlib.h>

#ifdef ANDROID
#include <Kore/Vr/VrInterface.h>
#endif

extern "C" void hl_init_kore(int width, int height) {
	Kore::log(Kore::Info, "Starting Kore");

	Kore::Random::init(static_cast<int>(Kore::System::timestamp() % std::numeric_limits<int>::max()));
	Kore::System::setName("Kore HL");
	Kore::System::setup();

	width = Kore::min(width, Kore::System::desktopWidth());
	height = Kore::min(height, Kore::System::desktopHeight());

	Kore::WindowOptions options;
	options.title = "";
	options.width = width;
	options.height = height;
	options.x = Kore::System::desktopWidth() / 2 - width / 2;
	options.y = Kore::System::desktopHeight() / 2 - height / 2;
	options.targetDisplay = -1;
	options.mode = Kore::WindowModeWindow;
	options.rendererOptions.depthBufferBits = 16;
	options.rendererOptions.stencilBufferBits = 8;
	options.rendererOptions.textureFormat = 0;
	options.rendererOptions.antialiasing = 1;

	Kore::System::initWindow(options);
}

extern "C" void run_kore() {
	Kore::System::start();
}
