package kha.internal;

import kha.Scheduler.FrameTask;
import kha.Scheduler.TimeTask;

class InstancedScheduler {
	private var timeTasks: Array<TimeTask> = [];
	private var frameTasks: Array<FrameTask> = [];
	
	private var toDeleteTime : Array<TimeTask> = [];
	private var toDeleteFrame : Array<FrameTask> = [];
	
	private var current: Float;
	private var lastTime: Float;
	
	private var frame_tasks_sorted: Bool;
	private var stopped: Bool;
	private var vsync: Bool;

	private var onedifhz: Float;

	private var currentFrameTaskId: Int;
	private var currentTimeTaskId: Int;
	private var currentGroupId: Int;

	private static inline var DIF_COUNT = 3;
	private var maxframetime = 0.5;
	
	private var deltas: Array<Float> = [for (i in 0...DIF_COUNT) 0];
	
	private var startTime: Float = 0;
	
	private var lastNow: Float = 0;
	
	private var activeTimeTask: TimeTask = null;
	
	public function new() {
		stopped = true;
		frame_tasks_sorted = true;
		current = realTime();
		lastTime = realTime();

		currentFrameTaskId = 0;
		currentTimeTaskId  = 0;
		currentGroupId     = 0;		
	}
	
	public function start(restartTimers : Bool = false): Void {
		vsync = false; //System.vsync; (DK) hardcoded false for now, seems to work regardless of acual vsync
		var hz = System.refreshRate;
		if (hz >= 57 && hz <= 63) hz = 60;
		onedifhz = 1.0 / hz;

		stopped = false;
		resetTime();
		lastTime = realTime();
		for (i in 0...DIF_COUNT) deltas[i] = 0;
		
		if (restartTimers) {
			for (timeTask in timeTasks) {
				timeTask.paused = false;
			}
			
			for (frameTask in frameTasks) {
				frameTask.paused = false;
			}
		}
	}
	
	public function stop(): Void {
		stopped = true;
	}
	
	public function isStopped(): Bool {
		return stopped;
	}
	
	public function back(time: Float): Void {
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
	
	public function executeFrame(): Void {
		var now: Float = realTime();
		var delta = now - lastNow;
		lastNow = now;
		
		var frameEnd: Float = current;
		 
		if (delta < 0) {
			return;
		}
		
		//tdif = 1.0 / 60.0; //force fixed frame rate
		
		if (delta > maxframetime) {
			delta = maxframetime;
			frameEnd += delta;
		}
		else {
			if (vsync) {
				// this is optimized not to run at exact speed
				// but to run as fluid as possible
				var realdif = onedifhz;
				while (realdif < delta - onedifhz) {
					realdif += onedifhz;
				}
				
				delta = realdif;
				for (i in 0...DIF_COUNT - 2) {
					delta += deltas[i];
					deltas[i] = deltas[i + 1];
				}
				delta += deltas[DIF_COUNT - 2];
				delta /= DIF_COUNT;
				deltas[DIF_COUNT - 2] = realdif;
				
				frameEnd += delta;
			}
			else {
				for (i in 0...DIF_COUNT - 1) {
					deltas[i] = deltas[i + 1];
				}
				deltas[DIF_COUNT - 1] = delta;
				
				var next: Float = 0;
				for (i in 0...DIF_COUNT) {
					next += deltas[i];
				}
				next /= DIF_COUNT;
				
				//delta = interpolated_delta; // average the frame end estimation
				
				//lastTime = now;
				frameEnd += next;
			}
		}
		
		lastTime = frameEnd;
		if (!stopped) { // Stop simulation time
			current = frameEnd;
		}
		
		for (t in timeTasks) {
			activeTimeTask = t;
			if (stopped || activeTimeTask.paused) { // Extend endpoint by paused time
				activeTimeTask.next += delta;
			}
			else if (activeTimeTask.next <= frameEnd) {
				activeTimeTask.next += t.period;
				timeTasks.remove(activeTimeTask);
				
				if (activeTimeTask.active && activeTimeTask.task()) {
					if (activeTimeTask.period > 0 && (activeTimeTask.duration == 0 || activeTimeTask.duration >= activeTimeTask.start + activeTimeTask.next)) {
						insertSorted(timeTasks, activeTimeTask);
					}
				}
				else {
					activeTimeTask.active = false;
				}
			}
		}
		activeTimeTask = null;
		
		for (timeTask in timeTasks) {
			if (!timeTask.active) {
				toDeleteTime.push(timeTask);
			}
		}
		
		while (toDeleteTime.length > 0) {
			timeTasks.remove(toDeleteTime.pop());
		}

		sortFrameTasks();
		for (frameTask in frameTasks) {
			if (!stopped && !frameTask.paused) {
				if (!frameTask.task()) frameTask.active = false;
			}
		}
		
		for (frameTask in frameTasks) {
			if (!frameTask.active) {
				toDeleteFrame.push(frameTask);
			}
		}
		
		while (toDeleteFrame.length > 0) {
			frameTasks.remove(toDeleteFrame.pop());
		}
	}

	public function time(): Float {
		return current;
	}
	
	public function realTime(): Float {
		return System.time - startTime;
	}
	
	public function resetTime(): Void {
		var now = System.time;
		lastNow = 0;
		var dif = now - startTime;
		startTime = now;
		for (timeTask in timeTasks) {
			timeTask.start -= dif;
			timeTask.next -= dif;
		}
		for (i in 0...DIF_COUNT) deltas[i] = 0;
		current = 0;
		lastTime = 0;
	}
	
	public function addBreakableFrameTask(task: Void -> Bool, priority: Int): Int {
		frameTasks.push(new FrameTask(task, priority, ++currentFrameTaskId));
		frame_tasks_sorted = false;
		return currentFrameTaskId;
	}
	
	public function addFrameTask(task: Void -> Void, priority: Int): Int {
		return addBreakableFrameTask(function() { task(); return true; }, priority);
	}
	
	public function pauseFrameTask(id: Int, paused: Bool): Void {
		for (frameTask in frameTasks) {
			if (frameTask.id == id) {
				frameTask.paused = paused;
				break;
			}
		}
	}
	
	public function removeFrameTask(id: Int): Void {
		for (frameTask in frameTasks) {
			if (frameTask.id == id) {
				frameTask.active = false;
				frameTasks.remove(frameTask);
				break;
			}
		}
	}

	public function generateGroupId(): Int {
		return ++currentGroupId;
	}
	
	public function addBreakableTimeTaskToGroup(groupId: Int, task: Void -> Bool, start: Float, period: Float = 0, duration: Float = 0): Int {
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
	
	public function addTimeTaskToGroup(groupId: Int, task: Void -> Void, start: Float, period: Float = 0, duration: Float = 0): Int {
		return addBreakableTimeTaskToGroup(groupId, function() { task(); return true; }, start, period, duration);
	}
	
	public function addBreakableTimeTask(task: Void -> Bool, start: Float, period: Float = 0, duration: Float = 0): Int {
		return addBreakableTimeTaskToGroup(0, task, start, period, duration);
	}
	
	public function addTimeTask(task: Void -> Void, start: Float, period: Float = 0, duration: Float = 0): Int {
		return addTimeTaskToGroup(0, task, start, period, duration);
	}

	private function getTimeTask(id: Int): TimeTask {
		if (activeTimeTask != null && activeTimeTask.id == id) return activeTimeTask;
		for (timeTask in timeTasks) {
			if (timeTask.id == id) {
				return timeTask;
			}
		}
		return null;
	}

	public function pauseTimeTask(id: Int, paused: Bool): Void {
		var timeTask = getTimeTask(id);
		if (timeTask != null) {
			timeTask.paused = paused;
		}
	}
	
	public function pauseTimeTasks(groupId: Int, paused: Bool): Void {
		for (timeTask in timeTasks) {
			if (timeTask.groupId == groupId) {
				timeTask.paused = paused;
			}
		}
		if (activeTimeTask != null && activeTimeTask.groupId == groupId) {
			activeTimeTask.paused = true;
		}
	}

	public function removeTimeTask(id: Int): Void {
		var timeTask = getTimeTask(id);
		if (timeTask != null) {
			timeTask.active = false;
			timeTasks.remove(timeTask);
		}
	}
	
	public function removeTimeTasks(groupId: Int): Void {
		for (timeTask in timeTasks) {
			if (timeTask.groupId == groupId) {
				timeTask.active = false;
				toDeleteTime.push(timeTask);
			}
		}
		if (activeTimeTask != null && activeTimeTask.groupId == groupId) {
			activeTimeTask.paused = false;
		} 
		
		while (toDeleteTime.length > 0) {
			timeTasks.remove(toDeleteTime.pop());
		}
	}

	public function numTasksInSchedule(): Int {
		return timeTasks.length + frameTasks.length;
	}
	
	private function insertSorted(list: Array<TimeTask>, task: TimeTask) {
		for (i in 0...list.length) {
			if (list[i].next > task.next) {
				list.insert(i, task);
				return;
			}
		}
		list.push(task);
	}
	
	private function sortFrameTasks(): Void {
		if (frame_tasks_sorted) return;
		frameTasks.sort(function(a: FrameTask, b: FrameTask): Int { return a.priority > b.priority ? 1 : ((a.priority < b.priority) ? -1 : 0); } );
		frame_tasks_sorted = true;
	}
	
	//private static function get_deltaTime():Float 
	//{
	//	return delta;
	//}
	
	/** Delta time between frames*/
	//static public var deltaTime(get_deltaTime, null):Float;
}
