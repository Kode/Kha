package kha;

class TimeTask {
	public var task: Void->Bool;

	public var start: Float;
	public var period: Float;
	public var duration: Float;
	public var next: Float;

	public var id: Int;
	public var groupId: Int;
	public var active: Bool;
	public var paused: Bool;

	public function new() {}
}

class FrameTask {
	public var task: Void->Bool;
	public var priority: Int;
	public var id: Int;
	public var active: Bool;
	public var paused: Bool;

	public function new(task: Void->Bool, priority: Int, id: Int) {
		this.task = task;
		this.priority = priority;
		this.id = id;
		active = true;
		paused = false;
	}
}

class Scheduler {
	static var timeTasks: Array<TimeTask>;
	static var pausedTimeTasks: Array<TimeTask>;
	static var outdatedTimeTasks: Array<TimeTask>;
	static var timeTasksScratchpad: Array<TimeTask>;
	static inline var timeWarpSaveTime: Float = 10.0;

	static var frameTasks: Array<FrameTask>;
	static var toDeleteFrame: Array<FrameTask>;

	static var current: Float;
	static var lastTime: Float;
	static var lastFrameEnd: Float;

	static var frame_tasks_sorted: Bool;
	static var stopped: Bool;
	static var vsync: Bool;

	static var onedifhz: Float;

	static var currentFrameTaskId: Int;
	static var currentTimeTaskId: Int;
	static var currentGroupId: Int;

	static var DIF_COUNT = 3;
	static var maxframetime = 0.5;

	static var deltas: Array<Float>;

	static var startTime: Float = 0;

	static var activeTimeTask: TimeTask = null;

	public static function init(): Void {
		deltas = new Array<Float>();
		for (i in 0...DIF_COUNT)
			deltas[i] = 0;

		stopped = true;
		frame_tasks_sorted = true;
		current = lastTime = lastFrameEnd = realTime();

		currentFrameTaskId = 0;
		currentTimeTaskId = 0;
		currentGroupId = 0;

		timeTasks = [];
		pausedTimeTasks = [];
		outdatedTimeTasks = [];
		timeTasksScratchpad = [];
		frameTasks = [];
		toDeleteFrame = [];
	}

	public static function start(restartTimers: Bool = false): Void {
		vsync = Window.get(0).vSynced;
		var hz = Display.primary.frequency;
		if (hz >= 57 && hz <= 63)
			hz = 60;
		onedifhz = 1.0 / hz;

		stopped = false;
		resetTime();
		lastTime = realTime() - startTime;
		for (i in 0...DIF_COUNT)
			deltas[i] = 0;

		if (restartTimers) {
			for (timeTask in timeTasks) {
				timeTask.paused = false;
			}

			for (frameTask in frameTasks) {
				frameTask.paused = false;
			}
		}
	}

	public static function stop(): Void {
		stopped = true;
	}

	public static function isStopped(): Bool {
		return stopped;
	}

	static function warpTimeTasksBack(time: Float, tasks: Array<TimeTask>): Void {
		for (timeTask in tasks) {
			if (timeTask.start >= time) {
				timeTask.next = timeTask.start;
			}
			else if (timeTask.period > 0) {
				var sinceStart = time - timeTask.start;
				var times = Math.ceil(sinceStart / timeTask.period);
				timeTask.next = timeTask.start + times * timeTask.period;
			}
		}
	}

	public static function warp(time: Float): Void {
		if (time < lastTime) {
			current = time;
			lastTime = time;
			lastFrameEnd = time;

			warpTimeTasksBack(time, outdatedTimeTasks);
			warpTimeTasksBack(time, timeTasks);

			for (task in outdatedTimeTasks) {
				if (task.next >= time) {
					timeTasksScratchpad.push(task);
				}
			}
			for (task in timeTasksScratchpad) {
				outdatedTimeTasks.remove(task);
			}
			for (task in timeTasksScratchpad) {
				insertSorted(timeTasks, task);
			}
			while (timeTasksScratchpad.length > 0) {
				timeTasksScratchpad.remove(timeTasksScratchpad[0]);
			}
		}
		else if (time > lastTime) {
			// TODO: Changing startTime line prevents clients from falling into a
			// warp-forward-then-wait-for-systemtime-to-catch-up-loop that causes
			// choppy movement (e.g. every 3rd frame forward 3 times).
			// But it causes backwards jumps in originally constant movements.
			// And on HTML5 packets are received while no frames are executed,
			// which causes the client to overtakes the server and then move
			// farther away with each packet while being unable to synch back
			// (backwards warping is not allowed to change startTime).
			startTime -= (time - lastTime);

			current = time;
			lastTime = time;
			lastFrameEnd = time;

			executeTimeTasks(time);
		}
	}

	public static function executeFrame(): Void {
		var real = realTime();
		var now: Float = real - startTime;
		var delta = now - lastTime;

		var frameEnd: Float = lastFrameEnd;

		if (delta >= 0) {
			if (kha.netsync.Session.the() == null) {
				// tdif = 1.0 / 60.0; //force fixed frame rate

				if (delta > maxframetime) {
					startTime += delta - maxframetime;
					now = real - startTime;
					delta = maxframetime;
					frameEnd += delta;
				}
				else {
					if (vsync) {
						// var measured = delta;
						// this is optimized not to run at exact speed
						// but to run as fluid as possible
						var frames = Math.round(delta / onedifhz);
						if (frames < 1) {
							return;
						}

						var realdif = frames * onedifhz;

						delta = realdif;
						for (i in 0...DIF_COUNT - 2) {
							delta += deltas[i];
							deltas[i] = deltas[i + 1];
						}
						delta += deltas[DIF_COUNT - 2];
						delta /= DIF_COUNT;
						deltas[DIF_COUNT - 2] = realdif;

						frameEnd += delta;

						// trace("Measured: " + measured + " Frames: " + frames +  " Delta: " + delta + " ");
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

						// delta = interpolated_delta; // average the frame end estimation

						// lastTime = now;
						frameEnd += next;
					}
				}
			}
			else {
				frameEnd += delta;
			}

			lastTime = now;

			if (!stopped) { // Stop simulation time
				lastFrameEnd = frameEnd;
			}

			// Extend endpoint by paused time (individually paused tasks)
			for (pausedTask in pausedTimeTasks) {
				pausedTask.next += delta;
			}

			if (stopped) {
				// Extend endpoint by paused time (running tasks)
				for (timeTask in timeTasks) {
					timeTask.next += delta;
				}
			}

			executeTimeTasks(frameEnd);

			// Maintain outdated task list
			for (task in outdatedTimeTasks) {
				if (task.next < frameEnd - timeWarpSaveTime) {
					timeTasksScratchpad.push(task);
				}
			}
			for (task in timeTasksScratchpad) {
				outdatedTimeTasks.remove(task);
			}
			while (timeTasksScratchpad.length > 0) {
				timeTasksScratchpad.remove(timeTasksScratchpad[0]);
			}
		}

		current = frameEnd;

		sortFrameTasks();
		for (frameTask in frameTasks) {
			if (!stopped && !frameTask.paused && frameTask.active) {
				if (!frameTask.task())
					frameTask.active = false;
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

	static function executeTimeTasks(until: Float) {
		while (timeTasks.length > 0) {
			activeTimeTask = timeTasks[0];

			if (activeTimeTask.next <= until) {
				current = activeTimeTask.next;

				activeTimeTask.next += activeTimeTask.period;
				timeTasks.remove(activeTimeTask);

				if (activeTimeTask.active && activeTimeTask.task()) {
					if (activeTimeTask.period > 0
						&& (activeTimeTask.duration == 0 || activeTimeTask.duration >= activeTimeTask.start + activeTimeTask.next)) {
						insertSorted(timeTasks, activeTimeTask);
					}
					else {
						archiveTimeTask(activeTimeTask, until);
					}
				}
				else {
					activeTimeTask.active = false;
					archiveTimeTask(activeTimeTask, until);
				}
			}
			else {
				break;
			}
		}
		activeTimeTask = null;
	}

	static function archiveTimeTask(timeTask: TimeTask, frameEnd: Float) {
		#if sys_server
		if (timeTask.next > frameEnd - timeWarpSaveTime) {
			outdatedTimeTasks.push(timeTask);
		}
		#end
	}

	/**
	 * An approximation of the amount of time (in fractional seconds) that elapsed while the game was active.
	 * This value is optimized for achieving smooth framerates.
	 */
	public static function time(): Float {
		return current;
	}

	/**
	 * The amount of time (in fractional seconds) that elapsed since the game started.
	 */
	public static function realTime(): Float {
		return System.time;
	}

	public static function resetTime(): Void {
		var now = System.time;
		var dif = now - startTime;
		startTime = now;
		for (timeTask in timeTasks) {
			timeTask.start -= dif;
			timeTask.next -= dif;
		}
		for (i in 0...DIF_COUNT)
			deltas[i] = 0;
		current = 0;
		lastTime = 0;
		lastFrameEnd = 0;
	}

	public static function addBreakableFrameTask(task: Void->Bool, priority: Int): Int {
		frameTasks.push(new FrameTask(task, priority, ++currentFrameTaskId));
		frame_tasks_sorted = false;
		return currentFrameTaskId;
	}

	public static function addFrameTask(task: Void->Void, priority: Int): Int {
		return addBreakableFrameTask(function() {
			task();
			return true;
		}, priority);
	}

	public static function pauseFrameTask(id: Int, paused: Bool): Void {
		for (frameTask in frameTasks) {
			if (frameTask.id == id) {
				frameTask.paused = paused;
				break;
			}
		}
	}

	public static function removeFrameTask(id: Int): Void {
		for (frameTask in frameTasks) {
			if (frameTask.id == id) {
				frameTask.active = false;
				break;
			}
		}
	}

	public static function generateGroupId(): Int {
		return ++currentGroupId;
	}

	public static function addBreakableTimeTaskToGroup(groupId: Int, task: Void->Bool, start: Float, period: Float = 0, duration: Float = 0): Int {
		var t = new TimeTask();
		t.active = true;
		t.task = task;
		t.id = ++currentTimeTaskId;
		t.groupId = groupId;

		t.start = current + start;
		t.period = 0;
		if (period != 0)
			t.period = period;
		t.duration = 0; // infinite
		if (duration != 0)
			t.duration = t.start + duration;

		t.next = t.start;
		insertSorted(timeTasks, t);
		return t.id;
	}

	public static function addTimeTaskToGroup(groupId: Int, task: Void->Void, start: Float, period: Float = 0, duration: Float = 0): Int {
		return addBreakableTimeTaskToGroup(groupId, function() {
			task();
			return true;
		}, start, period, duration);
	}

	public static function addBreakableTimeTask(task: Void->Bool, start: Float, period: Float = 0, duration: Float = 0): Int {
		return addBreakableTimeTaskToGroup(0, task, start, period, duration);
	}

	public static function addTimeTask(task: Void->Void, start: Float, period: Float = 0, duration: Float = 0): Int {
		return addTimeTaskToGroup(0, task, start, period, duration);
	}

	static function getTimeTask(id: Int): TimeTask {
		if (activeTimeTask != null && activeTimeTask.id == id)
			return activeTimeTask;
		for (timeTask in timeTasks) {
			if (timeTask.id == id) {
				return timeTask;
			}
		}
		for (timeTask in pausedTimeTasks) {
			if (timeTask.id == id) {
				return timeTask;
			}
		}
		return null;
	}

	public static function pauseTimeTask(id: Int, paused: Bool): Void {
		var timeTask = getTimeTask(id);
		if (timeTask != null) {
			pauseRunningTimeTask(timeTask, paused);
		}
		if (activeTimeTask != null && activeTimeTask.id == id) {
			activeTimeTask.paused = paused;
		}
	}

	static function pauseRunningTimeTask(timeTask: TimeTask, paused: Bool): Void {
		timeTask.paused = paused;
		if (paused) {
			timeTasks.remove(timeTask);
			pausedTimeTasks.push(timeTask);
		}
		else {
			insertSorted(timeTasks, timeTask);
			pausedTimeTasks.remove(timeTask);
		}
	}

	public static function pauseTimeTasks(groupId: Int, paused: Bool): Void {
		for (timeTask in timeTasks) {
			if (timeTask.groupId == groupId) {
				pauseRunningTimeTask(timeTask, paused);
			}
		}
		if (activeTimeTask != null && activeTimeTask.groupId == groupId) {
			activeTimeTask.paused = paused;
		}
	}

	public static function removeTimeTask(id: Int): Void {
		var timeTask = getTimeTask(id);
		if (timeTask != null) {
			timeTask.active = false;
			timeTasks.remove(timeTask);
		}
	}

	public static function removeTimeTasks(groupId: Int): Void {
		for (timeTask in timeTasks) {
			if (timeTask.groupId == groupId) {
				timeTask.active = false;
				timeTasksScratchpad.push(timeTask);
			}
		}
		for (timeTask in timeTasksScratchpad) {
			timeTasks.remove(timeTask);
		}
		while (timeTasksScratchpad.length > 0) {
			timeTasksScratchpad.remove(timeTasksScratchpad[0]);
		}

		if (activeTimeTask != null && activeTimeTask.groupId == groupId) {
			activeTimeTask.active = false;
		}
	}

	public static function numTasksInSchedule(): Int {
		return timeTasks.length + frameTasks.length;
	}

	static function insertSorted(list: Array<TimeTask>, task: TimeTask) {
		for (i in 0...list.length) {
			if (list[i].next > task.next) {
				list.insert(i, task);
				return;
			}
		}
		list.push(task);
	}

	static function sortFrameTasks(): Void {
		if (frame_tasks_sorted)
			return;
		frameTasks.sort(function(a: FrameTask, b: FrameTask): Int {
			return a.priority > b.priority ? 1 : ((a.priority < b.priority) ? -1 : 0);
		});
		frame_tasks_sorted = true;
	}
}
