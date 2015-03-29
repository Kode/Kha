package kha.networking;

import haxe.rtti.Meta;

class Session {
	private var clients: Array<Client> = new Array();
	private var entities: Map<Int, Entity> = new Map();
	
	public function new() {
		
	}
	
	public function addEntity(entity: Entity): Void {
		entities.set(entity.id(), entity);
	}
	
	public function sendState(): Void {
		for (entity in entities) {
			
			var fields = Meta.getFields(Example);
			var a = 3;
			++a;
		}
		/*var state = [];
		for (entity in entities) {
			var fields = Meta.getFields(entity);
			for (field in fields) {
				if (field.replicated) {
					
				}
			}
			state.push({
				id: entity.id,
				position: entity.x,
				last_processed_input: this.last_processed_input[i]
			});
		}
		for (client in clients) {
			client.send(lag, state);
		}*/
	}
	
	public function receiveState(state: Array<Dynamic>): Void {
		/*for (data in state) {
			var entity = entities[data.id];
			var fields = Meta.getFields(data);
			for (field in fields) {
				
			}
		}*/
	}
}
