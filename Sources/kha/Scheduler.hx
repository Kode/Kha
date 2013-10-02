package kha;

class TimeTask {
	public var task: Void -> Bool;
	
	public var start: Float;
	public var period: Int;
	public var duration: Float;
	public var last: Float;
	public var next: Float;
	
	public var id: Int;
	public var groupId: Int;
	public var active: Bool;
	
	public function new() {
		
	}
	
	public function elapsed() : Float {
		return Scheduler.time() - Scheduler.timestampToTime(last);
	}
	
	public function remaining() : Float {
		return Scheduler.timestampToTime(next) - Scheduler.time();
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
	//bool operator<(const FrameTask& ft);
}

class Scheduler {
	private static var timeTasks: Array<TimeTask>;
	private static var frameTasks: Array<FrameTask>;
	
	private static var current: Float;
	private static var frameEnd: Float;
	private static var startstamp: Float;
	
	private static var frame_tasks_sorted: Bool;
	private static var running: Bool;
	private static var stopped: Bool;
	private static var vsync: Bool;

	private static var frequency: Float;
	private static var onedifhz: Float;

	private static var currentFrameTaskId: Int;
	private static var currentTimeTaskId: Int;
	private static var currentGroupId: Int;

	private static var halted_count: Int;

	private static var DIF_COUNT = 3;
	private static var maxframetime = 0.1;
	
	public static function init(): Void {
		difs = new Array<Float>();
		difs[DIF_COUNT - 2] = 0;
		
		running = false;
		stopped = false;
		halted_count = 0;
		frame_tasks_sorted = true; // Weil der Vektor noch leer ist
		current = 0;
		frameEnd = 0;
		startstamp = 0;
		frequency = Sys.getFrequency();

		currentFrameTaskId = 0;
		currentTimeTaskId  = 0;
		currentGroupId     = 0;
		
		timeTasks = new Array<TimeTask>();
		frameTasks = new Array<FrameTask>();
	}
	
	public static function start(): Void {
		vsync = Sys.graphics.vsynced();
		var hz = Sys.graphics.refreshRate();
		if (hz >= 57 && hz <= 63) hz = 60;
		onedifhz = 1.0 / hz;

		//std::cout << "Using " << hz << " Hz" << std::endl;
		//std::cout << "Using vsync = " << (vsync ? "true" : "false") << std::endl;

		running = true;
		startstamp = Sys.getTimestamp();
		initSchedulerRun();
		//#ifndef SYS_ANDROID
		//runScheduler();
		//stopped = true;
		//#endif
	}
	
	public static function stop(): Void {
		running = false;
	}
	
	public static function isStopped(): Bool {
		return stopped;
	}
	
	public static function executeFrame(): Void {
		stamp = Sys.getTimestamp() - startstamp;
		
		var tdif = ticksToTimespan(stamp - current);
		//tdif = 1.0 / 60.0; //force fixed frame rate
		if (halted_count > 0) {
			startstamp += stamp - current;
		}
		else if (tdif > maxframetime) {
			var mtft = timespanToTicks(maxframetime);
			frameEnd += mtft;
			startstamp += stamp - current - mtft;
		}
		else {
			if (vsync) {
				var realdif = onedifhz;
				while (realdif < tdif - onedifhz) { //0.3 -> 0.7
					realdif += onedifhz;
				}
				
				tdif = realdif;
				for (i in 0...DIF_COUNT-2) {
					tdif += difs[i];
					difs[i] = difs[i+1];
				}
				tdif += difs[DIF_COUNT-2];
				tdif /= DIF_COUNT;
				difs[DIF_COUNT-2] = realdif;
				
				frameEnd += timespanToTicks(tdif);
			}
			else {
				#if true
					var interpolated_tdif = tdif;
					for (i in 0...DIF_COUNT-2) {
						interpolated_tdif += difs[i];
						difs[i] = difs[i+1];
					}
					interpolated_tdif += difs[DIF_COUNT-2];
					interpolated_tdif /= DIF_COUNT;
					difs[DIF_COUNT-2] = tdif;
					
					frameEnd += timespanToTicks(interpolated_tdif); // Interpolierte vorhersage des Frame endes
				#else
					frameEnd = stamp; // Keine vorhersage des Frame endes. */
				#end
			}
		}

		//
		// TimeTasks bis zum frameEnd ausführen
		//
		while (timeTasks.length > 0 && timeTasks[0].next <= frameEnd) {
			var t = timeTasks[0];
			current = t.next;
			t.last = t.next;
			t.next += t.period;
			
			if (t.active && t.task()) {
				timeTasks.remove(t);
				if (t.period != 0 && (t.duration == 0 || t.duration >= t.start + t.next)) {
					insertSorted(timeTasks, t);
				}
			}
			else {
				t.active = false;
				timeTasks.remove(t);
			}
		}
		
		// getCurrentTimestamp auf frameEnd aktualisieren
		current = frameEnd;
		
		// TODO: Man könnte direkt bei "t.active = false;" entfernen
		while (true) {
			for (timeTask in timeTasks) {
				if (!timeTask.active) {
					timeTasks.remove(timeTask);
					//printf("timeTasks.erase(-> %d)\n", timeTasks.size());
					break;
				}
			}
			break;
		}

		//
		// FrameTasks ausführen
		//
		sortFrameTasks();
		for (frameTask in frameTasks) {
			if (!frameTask.task()) frameTask.active = false;
		}

		// TODO: Geschickter löschen
		while (true) {
			for (frameTask in frameTasks) {
				if (!frameTask.active) {
					frameTasks.remove(frameTask);
					//printf("frameTasks.erase(-> %d)\n", frameTasks.size());
					break;
				}
			}
			break;
		}
	}

	public static function time(): Float {
		return timestampToTime(getCurrentTimestamp());
	}
	
	public static function realticktime(): Float { //just for random generator initialization
		return getCurrentTimestamp();
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

		t.start = current + timeToTimestamp(start);
		t.period = 0;
		if (period != 0) t.period = timespanToTicks(period);
		//if (t.period == 0) throw std::exception("The period of a task must not be zero.");
		t.duration = 0; //infinite
		if (duration != 0) t.duration = t.start + timeToTimestamp(duration); //-1 ?

		t.next = t.start;
		t.last = current;
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

	public static function getTimeTask(id: Int): TimeTask {
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
	
	private static function initSchedulerRun(): Void {
		stamp = getCurrentTimestamp();
		for (i in 0...DIF_COUNT) difs[i] = 0;
	}
	
	private static function getCurrentTimestamp(): Float {
		return current - startstamp;
	}
	
	private static function ticksToTimespan(t: Float): Float {
		return t / frequency;
	}
	
	private static function timespanToTicks(timespan: Float) {
		return Math.round(timespan * frequency);
	}
	
	public static function timestampToTime(t: Float): Float {
		return t / frequency;
	}
	
	private static function timeToTimestamp(time: Float): Int {
		return Std.int(time * frequency);
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

	private static var stamp: Float;
	private static var difs: Array<Float>;
}