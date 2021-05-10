#include <Kore/Video.h>
#include <hl.h>

extern "C" vbyte *hl_kore_video_create(vbyte* filename) {
	return (vbyte*)new Kore::Video((char*)filename);
}

extern "C" void hl_kore_video_play(vbyte* video) {
	Kore::Video* vid = (Kore::Video*)video;
	return vid->play();
}

extern "C" void hl_kore_video_pause(vbyte* video) {
	Kore::Video* vid = (Kore::Video*)video;
	return vid->pause();
}

extern "C" void hl_kore_video_stop(vbyte* video) {
	Kore::Video* vid = (Kore::Video*)video;
	return vid->stop();
}

extern "C" int hl_kore_video_get_duration(vbyte* video) {
	Kore::Video* vid = (Kore::Video*)video;
	return static_cast<int>(vid->duration * 1000.0);
}

extern "C" int hl_kore_video_get_position(vbyte* video) {
	Kore::Video* vid = (Kore::Video*)video;
	return static_cast<int>(vid->position * 1000.0);
}

extern "C" void hl_kore_video_set_position(vbyte* video, int value) {
	Kore::Video* vid = (Kore::Video*)video;
	vid->update(value / 1000.0);
}

extern "C" bool hl_kore_video_is_finished(vbyte* video) {
	Kore::Video* vid = (Kore::Video*)video;
	return vid->finished;
}

extern "C" int hl_kore_video_width(vbyte* video) {
	Kore::Video* vid = (Kore::Video*)video;
	return vid->width();
}

extern "C" int hl_kore_video_height(vbyte* video) {
	Kore::Video* vid = (Kore::Video*)video;
	return vid->height();
}

extern "C" void hl_kore_video_unload(vbyte* video) {
	Kore::Video* vid = (Kore::Video*)video;
	delete vid;
}
