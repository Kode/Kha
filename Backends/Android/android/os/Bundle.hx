package android.os;

import java.util.ArrayList;

extern class Bundle extends BaseBundle {
	public function new();
	public function putStringArrayList(key: String, value: ArrayList<String>): Void;
	public function getStringArrayList(key: String): ArrayList<String>;
	public function getParcelable<T: Parcelable>(key: String): T;
}
