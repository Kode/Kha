class Secondary2 {
	public function new( id : Int ) {
		kha.System.notifyOnRender(render, id);
	}

	function render( framebuffer : kha.Framebuffer ) {
		framebuffer.g2.begin(kha.Color.Blue);
		framebuffer.g2.end();
	}
}
