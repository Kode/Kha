package android.media;

import android.media.MediaFormat;
import java.io.FileDescriptor;

extern class MediaExtractor {
	public function new(): Void;
	public function setDataSource(fileDescriptor: FileDescriptor, offset: Int, length: Int): Void;
	public function getTrackFormat(index: Int): MediaFormat;
	public function release(): Void;
}