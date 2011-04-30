package com.kontechs.kje;

public abstract class System {
	private static System instance;
	
	public static void init(System system) {
		instance = system;
	}
	
	public static System getInstance() {
		return instance;
	}
	
	public abstract int getXRes();
	public abstract int getYRes();
}