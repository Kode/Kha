package com.ktxsoftware.kje.backends.android;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

import android.content.Context;
import android.opengl.GLSurfaceView;

import com.ktxsoftware.kje.GameInfo;
import com.ktxsoftware.kje.Loader;

class OpenGLES20Renderer implements GLSurfaceView.Renderer {
	private com.ktxsoftware.kje.Game game;
	private OpenGLPainter painter;
	private int width, height;
	
	public OpenGLES20Renderer(Context context, int width, int height) {
		this.width = width;
		this.height = height;
		Loader.init(new ResourceLoader(context));
		game = GameInfo.createGame();
		Loader.getInstance().load();
		game.init();
	}

    public void onDrawFrame(GL10 glUnused) {
        game.update();
        painter.begin();
        game.render(painter);
        painter.end();
    }

    public void onSurfaceChanged(GL10 glUnused, int width, int height) {
    	painter = new OpenGLPainter(width, height);
    }

    public void onSurfaceCreated(GL10 glUnused, EGLConfig config) {
    	
    }
}