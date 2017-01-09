class Primary {
	public function new( id : Int ) {
		kha.System.notifyOnRender(render, id);
	}

	function render( framebuffer : kha.Framebuffer ) {
		framebuffer.g2.begin(kha.Color.Red);
		framebuffer.g2.end();
	}
}
