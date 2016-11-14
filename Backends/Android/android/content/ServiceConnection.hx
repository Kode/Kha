package android.content;

import android.os.IBinder;

extern interface ServiceConnection {
	public function onServiceDisconnected(name: ComponentName): Void;
	public function onServiceConnected(name: ComponentName, service: IBinder): Void;
}
