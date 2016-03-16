package;

import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;

class Primary {
	public function new( id : Int ) {
		System.notifyOnRender(id, render);
		//Scheduler.addTimeTaskToGroup(id, update, 0, 1 / 60);
	}

	function render( framebuffer : Framebuffer ) {
		framebuffer.g2.begin(Color.Red);
		framebuffer.g2.end();
	}

	function update() {
	}
}
