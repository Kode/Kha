package kha;

class TimeTask {
	public var task: Void -> Bool;
	
	public var start: Float;
	public var period: Float;
	public var duration: Float;
	public var next: Float;
	
	public var id: Int;
	public var groupId: Int;
	public var active: Bool;
	
	public function new() {
		
	}
}

class FrameTask {
	public var task: Void -> Bool;
	public var priority: Int;
	public var id: Int;
	public var active: Bool;
	
	public function new(task: Void -> Bool, priority: Int, id: Int) {
		this.task = task;
		this.priority = priority;
		this.id = id;
		active = true;
	}
}

class Scheduler {
	private static var timeTasks: Array<TimeTask>;
	private static var frameTasks: Array<FrameTask>;
	
	private static var current: Float;
	private static var lastTime: Float;
	
	private static var frame_tasks_sorted: Bool;
	private static var stopped: Bool;
	private static var vsync: Bool;

	private static var onedifhz: Float;

	private static var currentFrameTaskId: Int;
	private static var currentTimeTaskId: Int;
	private static var currentGroupId: Int;

	private static var halted_count: Int;

	private static var DIF_COUNT = 3;
	private static var maxframetime = 0.1;
	
	private static var difs: Array<Float>;
	
	private static var delta:Float = 0;
	private static var dScale:Float = 1;
	
	private static var startTime: Float = 0;
	
	public static function init(): Void {
		difs = new Array<Float>();
		for (i in 0...DIF_COUNT-1) difs[i] = 0;
		
		stopped = true;
		halted_count = 0;
		frame_tasks_sorted = true;
		current = realTime();
		lastTime = realTime();

		currentFrameTaskId = 0;
		currentTimeTaskId  = 0;
		currentGroupId     = 0;
		
		timeTasks = new Array<TimeTask>();
		frameTasks = new Array<FrameTask>();
		Configuration.schedulerInitialized();
	}
	
	public static function start(): Void {
		vsync = Sys.vsynced();
		var hz = Sys.refreshRate();
		if (hz >= 57 && hz <= 63) hz = 60;
		onedifhz = 1.0 / hz;

		stopped = false;
		resetTime();
		lastTime = realTime();
		for (i in 0...DIF_COUNT-1) difs[i] = 0;
	}
	
	public static function stop(): Void {
		stopped = true;
	}
	
	public static function isStopped(): Bool {
		return stopped;
	}
	
	public static function back(time: Float): Void {
		lastTime = time;
		for (timeTask in timeTasks) {
			if (timeTask.start >= time) {
				timeTask.next = timeTask.start;
			}
			else {
				timeTask.next = timeTask.start;
				while (timeTask.next < time) { // TODO: Implement without looping
					timeTask.next += timeTask.period;
				}
			}
		}
	}
	
	public static function executeFrame(): Void {
		Sys.mouse.update();
		
		var now: Float = realTime();
		delta = now - lastTime;
		lastTime = now;
		var frameEnd: Float = current;
		 
		if (delta < 0 || stopped) {
			return;
		}
		
		//tdif = 1.0 / 60.0; //force fixed frame rate
		
		if (halted_count > 0) {
			delta = 0;
		}
		else if (delta > maxframetime) {
			delta = maxframetime;
		}
		else {
			if (vsync) {
				// TODO: fix it!
				// this commulates delta errors with Scheduler.time()
				// running quite different (faster) than Sys.time()
				var realdif = onedifhz;
				while (realdif < delta - onedifhz) {
					realdif += onedifhz;
				}
				
				delta = realdif;
				for (i in 0...DIF_COUNT - 2) {
					delta += difs[i];
					difs[i] = difs[i + 1];
				}
				delta += difs[DIF_COUNT - 2];
				delta /= DIF_COUNT;
				difs[DIF_COUNT - 2] = realdif;
			}
			else {
				#if true
					var interpolated_delta = delta;
					for (i in 0...DIF_COUNT-2) {
						interpolated_delta += difs[i];
						difs[i] = difs[i+1];
					}
					interpolated_delta += difs[DIF_COUNT-2];
					interpolated_delta /= DIF_COUNT;
					difs[DIF_COUNT-2] = delta;
					
					delta =interpolated_delta; // average the frame end estimation
				#end
			}
		}
		
		delta = dScale * delta;
		frameEnd += delta;
		
		while (timeTasks.length > 0 && timeTasks[0].next <= frameEnd) {
			var t = timeTasks[0];
			current = t.next;
			t.next += t.period;
			timeTasks.remove(t);
			
			if (t.active && t.task()) {
				if (t.period > 0 && (t.duration == 0 || t.duration >= t.start + t.next)) {
					insertSorted(timeTasks, t);
				}
			}
			else {
				t.active = false;
			}
		}
		
		current = frameEnd;
		
		while (true) {
			for (timeTask in timeTasks) {
				if (!timeTask.active) {
					timeTasks.remove(timeTask);
					break;
				}
			}
			break;
		}

		sortFrameTasks();
		for (frameTask in frameTasks) {
			if (!frameTask.task()) frameTask.active = false;
		}

		while (true) {
			for (frameTask in frameTasks) {
				if (!frameTask.active) {
					frameTasks.remove(frameTask);
					break;
				}
			}
			break;
		}
	}

	public static function time(): Float {
		return current;
	}
	
	public static function realTime(): Float {
		return Sys.getTime() - startTime;
	}
	
	public static function resetTime(): Void {
		var now = Sys.getTime();
		var dif = now - startTime;
		startTime = now;
		for (timeTask in timeTasks) {
			timeTask.start -= dif;
			timeTask.next -= dif;
		}
		for (i in 0...DIF_COUNT-1) difs[i] = 0;
		current = 0;
		lastTime = 0;
	}
	
	public static function addBreakableFrameTask(task: Void -> Bool, priority: Int): Int {
		frameTasks.push(new FrameTask(task, priority, ++currentFrameTaskId));
		frame_tasks_sorted = false;
		return currentFrameTaskId;
	}
	
	public static function addFrameTask(task: Void -> Void, priority: Int): Int {
		return addBreakableFrameTask(function() { task(); return true; }, priority);
	}
	
	public static function removeFrameTask(id: Int): Void {
		for (frameTask in frameTasks) {
			if (frameTask.id == id) {
				frameTask.active = false;
				frameTasks.remove(frameTask);
				break;
			}
		}
	}

	public static function generateGroupId(): Int {
		return ++currentGroupId;
	}
	
	public static function addBreakableTimeTaskToGroup(groupId: Int, task: Void -> Bool, start: Float, period: Float = 0, duration: Float = 0): Int {
		var t = new TimeTask();
		t.active = true;
		t.task = task;
		t.id = ++currentTimeTaskId;
		t.groupId = groupId;

		t.start = current + start;
		t.period = 0;
		if (period != 0) t.period = period;
		//if (t.period == 0) throw std::exception("The period of a task must not be zero.");
		t.duration = 0; //infinite
		if (duration != 0) t.duration = t.start + duration; //-1 ?

		t.next = t.start;
		insertSorted(timeTasks, t);
		return t.id;
	}
	
	public static function addTimeTaskToGroup(groupId: Int, task: Void -> Void, start: Float, period: Float = 0, duration: Float = 0): Int {
		return addBreakableTimeTaskToGroup(groupId, function() { task(); return true; }, start, period, duration);
	}
	
	public static function addBreakableTimeTask(task: Void -> Bool, start: Float, period: Float = 0, duration: Float = 0): Int {
		return addBreakableTimeTaskToGroup(0, task, start, period, duration);
	}
	
	public static function addTimeTask(task: Void -> Void, start: Float, period: Float = 0, duration: Float = 0): Int {
		return addTimeTaskToGroup(0, task, start, period, duration);
	}

	private static function getTimeTask(id: Int): TimeTask {
		for (timeTask in timeTasks) {
			if (timeTask.id == id) {
				return timeTask;
			}
		}
		return null;
	}

	public static function removeTimeTask(id: Int): Void {
		var timeTask : TimeTask = getTimeTask(id);
		if (timeTask != null) {
			timeTask.active = false;
			timeTasks.remove(timeTask);
		}
	}
	
	public static function removeTimeTasks(groupId: Int): Void {
		while (true) {
			for (timeTask in timeTasks) {
				if (timeTask.groupId == groupId) {
					timeTask.active = false;
					timeTasks.remove(timeTask);
					break;
				}
			}
			break;
		}
	}

	public static function numTasksInSchedule(): Int {
		return timeTasks.length + frameTasks.length;
	}
	
	private static function insertSorted(list: Array<TimeTask>, task: TimeTask) {
		for (i in 0...list.length) {
			if (list[i].next > task.next) {
				list.insert(i, task);
				return;
			}
		}
		list.push(task);
	}
	
	private static function sortFrameTasks(): Void {
		if (frame_tasks_sorted) return;
		frameTasks.sort(function(a: FrameTask, b: FrameTask): Int { return a.priority > b.priority ? 1 : ((a.priority < b.priority) ? -1 : 0); } );
		frame_tasks_sorted = true;
	}
	
	private static function get_deltaTime():Float 
	{
		return delta;
	}
	
	/** Delta time between frames*/
	static public var deltaTime(get_deltaTime, null):Float;
	
	private static function get_deltaScale():Float 
	{
		return dScale;
	}
	
	private static function set_deltaScale(value:Float):Float 
	{
		return dScale = value;
	}
	
	/** Multiplier for delta time*/
	static public var deltaScale(get_deltaScale, set_deltaScale):Float;
}
