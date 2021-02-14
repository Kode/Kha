package android.content;

import android.os.IBinder;

extern interface ServiceConnection {
	function onServiceDisconnected(name: ComponentName): Void;
	function onServiceConnected(name: ComponentName, service: IBinder): Void;
}
