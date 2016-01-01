package com.ktxsoftware.kha;

import android.app.Activity;
import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.Window;
import android.view.WindowManagerLayoutParams;
import java.lang.Object;
import java.lang.Runnable;
import kha.SystemImpl;

/*
import android.content.Intent;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.opengl.GLES20;
import android.os.Bundle;
import android.util.Log;
import android.view.Display;
*/

class OnCreateRunner implements Runnable {
	public function new() {
		
	}
	
	public function run(): Void {
		
	}
}

class OnStartRunner implements Runnable {
	public function new() {
		
	}
	
	public function run(): Void {
		SystemImpl.foreground();
	}
}

class OnPauseRunner implements Runnable {
	public function new() {
		
	}
	
	public function run(): Void {
		SystemImpl.pause();
	}
}

class OnResumeRunner implements Runnable {
	public function new() {
		
	}
	
	public function run(): Void {
		SystemImpl.resume();
	}
}

class OnStopRunner implements Runnable {
	public function new() {
		
	}
	
	public function run(): Void {
		SystemImpl.background();
	}
}

class OnRestartRunner implements Runnable {
	public function new() {
		
	}
	
	public function run(): Void {
		
	}
}

class OnDestroyRunner implements Runnable {
	public function new() {
		
	}
	
	public function run(): Void {
		SystemImpl.shutdown();
	}
}

class KhaActivity extends Activity /*implements SensorEventListener*/ {
	@:volatile public static var paused: Bool = true;
	//private var audio: AudioTrack;
	//private var audioThread: Thread;
	//private var bufferSize: Int;
	private var view: KhaView;
	
	//public static var sensorLock: Object = new Object();
	//private var sensorManager: SensorManager;
	//private var accelerometer: Sensor;
	//private var gyro: Sensor;
	
	private static var instance: KhaActivity;
		
	public static function the(): KhaActivity {
		return instance;
	}
	
	override public function onCreate(state: Bundle): Void {
		super.onCreate(state);
		instance = this;
		requestWindowFeature(Window.FEATURE_NO_TITLE);
		getWindow().setFlags(WindowManagerLayoutParams.FLAG_FULLSCREEN, WindowManagerLayoutParams.FLAG_FULLSCREEN);
		setContentView(view = new KhaView(this));
		//bufferSize = AudioTrack.getMinBufferSize(44100, AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_16BIT) * 2;
		//audio = new AudioTrack(AudioManager.STREAM_MUSIC, 44100, AudioFormat.CHANNEL_OUT_STEREO, AudioFormat.ENCODING_PCM_16BIT, bufferSize, AudioTrack.MODE_STREAM);
		
		//sensorManager = cast getSystemService(Context.SENSOR_SERVICE);
		//accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
		//gyro = sensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE);
		
		view.queueEvent(new OnCreateRunner());
	}
	
	override public function onStart(): Void {
		super.onStart();
		view.queueEvent(new OnStartRunner());
	}
	
	override public function onPause(): Void {
		super.onPause();
		view.onPause();
		//sensorManager.unregisterListener(this);
		paused = true;
		//audio.pause();
		//audio.flush();
		view.queueEvent(new OnPauseRunner());
	}
	
	override public function onResume(): Void {
		super.onResume();
		view.onResume();
		//sensorManager.registerListener(this, accelerometer, SensorManager.SENSOR_DELAY_NORMAL);
		//sensorManager.registerListener(this, gyro, SensorManager.SENSOR_DELAY_NORMAL);
		
		/*if (audioThread != null) {
			try {
				audioThread.join();
			}
			catch (InterruptedException e) {
				e.printStackTrace();
			}
		}*/
		
		paused = false;
		
		/*audio.play();
		Runnable audioRunnable = new Runnable() {
			public void run() {
				Thread.currentThread().setPriority(Thread.MIN_PRIORITY);
				byte[] audioBuffer = new byte[bufferSize / 2];
				for (;;) {
					if (paused) return;
					KoreLib.writeAudio(audioBuffer, audioBuffer.length);
					int written = 0;
					while (written < audioBuffer.length) {
						written += audio.write(audioBuffer, written, audioBuffer.length);
					}
				}
			}
		};
		audioThread = new Thread(audioRunnable);
		audioThread.start();*/
		
		view.queueEvent(new OnResumeRunner());
	}
	
	override public function onStop(): Void {
		super.onStop();
		view.queueEvent(new OnStopRunner());
	}
	
	
	override public function onRestart(): Void {
		super.onRestart();
		view.queueEvent(new OnRestartRunner());
	}
	
	override public function onDestroy(): Void {
		super.onDestroy();
		view.queueEvent(new OnDestroyRunner());
	}
	
	override public function onConfigurationChanged(newConfig: Configuration): Void {
		super.onConfigurationChanged(newConfig);
		
		/*switch (newConfig.orientation) {
		case Configuration.ORIENTATION_LANDSCAPE:
			
			break;
		case Configuration.ORIENTATION_PORTRAIT:
			
			break;
			
		}*/
	}

	//override public function onAccuracyChanged(sensor: Sensor, value: Int): Void {
	//	
	//}

	//override public function onSensorChanged(e: SensorEvent): Void {
	//	if (e.sensor == accelerometer) {
	//		view.accelerometer(e.values[0], e.values[1], e.values[2]);
	//	}
	//	else if (e.sensor == gyro) {
	//		view.gyro(e.values[0], e.values[1], e.values[2]);
	//	}
	//}	
}
