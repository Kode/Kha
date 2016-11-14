package android.net;

import android.os.Parcelable;
import java.lang.Comparable;

extern class Uri implements Parcelable implements Comparable<Uri> {
	public static function parse(uriString: String): Uri;
	public function compareTo(another: Uri): Int;
}
