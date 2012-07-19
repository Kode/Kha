package kha;

class FrameCountTimer 
{
	var miliseconds : Int;
	var repeating : Bool;
	var active : Bool = false;
	var count : Int = 0;
	var currentTimerValue : Int = 0;
	
	public function new(miliseconds : Int, repeating : Bool) 
	{
		this.miliseconds = miliseconds;
		this.repeating = repeating;
		Game.getInstance().registerTimer(this);
	}
	
	public function setMiliseconds(miliseconds : Int) {
		this.miliseconds = miliseconds;
	}
	
	public function setRepeating(repeating : Bool) {
		this.repeating = repeating;
	}
	
	public function getActive() : Bool {
		return active;
	}
	
	public function start() {
		active = true;
	}
	
	public function stop() {
		active = false;
	}
	
	public function reset() {
		count = 0;
		stop();
	}
	
	public function unregister() {
		Game.getInstance().removeTimer(this);
	}
	
	public function update() {
		
		currentTimerValue = Std.int(count / Game.FPS);
		
		if (!active)
			return;
		
		count ++;
		if ((count / Game.FPS) > miliseconds / 1000) {
			
			count = 0;
			fireEvent();
			if (!repeating)
				active = false;
		}
	}
	
	private function fireEvent() { }
	
	public function getCurrentTimerValue() : Int {
		return currentTimerValue;
	}
	
}