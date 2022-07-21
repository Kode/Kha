#include <kinc/video.h>

#include <hl.h>

vbyte *hl_kore_video_create(vbyte *filename) {
	kinc_video_t *video = (kinc_video_t *)malloc(sizeof(kinc_video_t));
	kinc_video_init(video, (char *)filename);
	return (vbyte *)video;
}

void hl_kore_video_play(vbyte *video) {
	kinc_video_t *vid = (kinc_video_t *)video;
	kinc_video_play(vid, false);
}

void hl_kore_video_pause(vbyte *video) {
	kinc_video_t *vid = (kinc_video_t *)video;
	kinc_video_pause(vid);
}

void hl_kore_video_stop(vbyte *video) {
	kinc_video_t *vid = (kinc_video_t *)video;
	kinc_video_stop(vid);
}

int hl_kore_video_get_duration(vbyte *video) {
	kinc_video_t *vid = (kinc_video_t *)video;
	return (int)(kinc_video_duration(vid) * 1000.0);
}

int hl_kore_video_get_position(vbyte *video) {
	kinc_video_t *vid = (kinc_video_t *)video;
	return (int)(kinc_video_position(vid) * 1000.0);
}

void hl_kore_video_set_position(vbyte *video, int value) {
	kinc_video_t *vid = (kinc_video_t *)video;
	kinc_video_update(vid, value / 1000.0);
}

bool hl_kore_video_is_finished(vbyte *video) {
	kinc_video_t *vid = (kinc_video_t *)video;
	return kinc_video_finished(vid);
}

int hl_kore_video_width(vbyte *video) {
	kinc_video_t *vid = (kinc_video_t *)video;
	return kinc_video_width(vid);
}

int hl_kore_video_height(vbyte *video) {
	kinc_video_t *vid = (kinc_video_t *)video;
	return kinc_video_height(vid);
}

void hl_kore_video_unload(vbyte *video) {
	kinc_video_t *vid = (kinc_video_t *)video;
	kinc_video_destroy(vid);
	free(vid);
}
