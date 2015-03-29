package kha.networking;

/*class Entity {
	public var id: Int;
	
	public function new() {
		id = 0;
	}
	
	public function simulate(tdif: Float): Void {
		
	}
}*/

@:autoBuild(kha.networking.EntityBuilder.build())
interface Entity {
	public function id(): Int;
	public function simulate(tdif: Float): Void;
}
