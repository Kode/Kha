package kha;

import kha.internal.InstancedScheduler;

class TimeTask {
	public var task: Void -> Bool;

	public var start: Float;
	public var period: Float;
	public var duration: Float;
	public var next: Float;

	public var id: Int;
	public var groupId: Int;
	public var active: Bool;
	public var paused: Bool;

	public function new() {

	}
}

class FrameTask {
	public var task: Void -> Bool;
	public var priority: Int;
	public var id: Int;
	public var active: Bool;
	public var paused: Bool;

	public function new(task: Void -> Bool, priority: Int, id: Int) {
		this.task = task;
		this.priority = priority;
		this.id = id;
		active = true;
		paused = false;
	}
}

class Scheduler {
	static var global = new InstancedScheduler();
	static var schedulers : Array<InstancedScheduler> = [new InstancedScheduler()];

	// TODO (DK) fix all backends (SystemImpl) and remove this?
	// used in non-Kore targets
	public static function init(): Void {
		global.init();
	}

	// (DK) used in Kore targets
	public static function initAll() {
		global.init();
		
		for (s in schedulers) {
			s.init();
		}
	}

	public static inline function start(restartTimers : Bool = false): Void {
		global.start(restartTimers);
	}

	public static function startAll(restartTimers: Bool = false) {
		global.start();
		
		for (s in schedulers) {
			s.start(restartTimers);
		}
	}

	public static inline function stop(): Void {
		global.stop();
	}

	public static inline function isStopped(): Bool {
		return global.isStopped();
	}

	public static inline function back(time: Float): Void {
		global.back(time);
	}

	public static inline function executeFrame(): Void {
		global.executeFrame();
	}

	public static inline function time(): Float {
		return global.time();
	}

	public static inline function realTime(): Float {
		return global.realTime();
	}

	public static inline function resetTime(): Void {
		global.resetTime();
	}

	public static inline function addBreakableFrameTask(task: Void -> Bool, priority: Int): Int {
		return global.addBreakableFrameTask(task, priority);
	}

	public static inline function addFrameTask(task: Void -> Void, priority: Int): Int {
		return global.addFrameTask(task, priority);
	}

	public static inline function pauseFrameTask(id: Int, paused: Bool): Void {
		global.pauseFrameTask(id, paused);
	}

	public static inline function removeFrameTask(id: Int): Void {
		global.removeFrameTask(id);
	}

	public static inline function generateGroupId(): Int {
		return global.generateGroupId();
	}

	public static inline function addBreakableTimeTaskToGroup(groupId: Int, task: Void -> Bool, start: Float, period: Float = 0, duration: Float = 0): Int {
		return global.addBreakableTimeTaskToGroup(groupId, task, start, period, duration);
	}

	public static inline function addTimeTaskToGroup(groupId: Int, task: Void -> Void, start: Float, period: Float = 0, duration: Float = 0): Int {
		return global.addTimeTaskToGroup(groupId, task, start, period, duration);
	}

	public static inline function addBreakableTimeTask(task: Void -> Bool, start: Float, period: Float = 0, duration: Float = 0): Int {
		return global.addBreakableTimeTask(task, start, period, duration);
	}

	public static inline function addTimeTask(task: Void -> Void, start: Float, period: Float = 0, duration: Float = 0): Int {
		return global.addTimeTask(task, start, period, duration);
	}

	public static inline function pauseTimeTask(id: Int, paused: Bool): Void {
		global.pauseTimeTask(id, paused);
	}

	public static inline function pauseTimeTasks(groupId: Int, paused: Bool): Void {
		global.pauseTimeTasks(groupId, paused);
	}

	public static inline function removeTimeTask(id: Int): Void {
		global.removeTimeTask(id);
	}

	public static inline function removeTimeTasks(groupId: Int): Void {
		global.removeTimeTasks(groupId);
	}

	public static inline function numTasksInSchedule(): Int {
		return global.numTasksInSchedule();
	}

	public static function addInstance(): InstancedScheduler {
		var instance = new InstancedScheduler();
		schedulers.push(instance);
		return instance;
	}

	public static function getInstance(windowId: Int): InstancedScheduler {
		return schedulers[windowId];
	}

	//private static function get_deltaTime():Float
	//{
	//	return delta;
	//}

	/** Delta time between frames*/
	//static public var deltaTime(get_deltaTime, null):Float;
}
