package com.kontechs.kje;

import de.hsharz.beaver.Excavator;

//TODO: Remove
public class ExcavatorLifeLine {
	private static int posx;
	private static int posy;
	private static Excavator excavator;
	private static int length = 150;
	
	public static int getPosx() {
		return posx;
	}
	public static void setPosx(int posx) {
		ExcavatorLifeLine.posx = posx;
	}
	public static int getPosy() {
		return posy;
	}
	public static void setPosy(int posy) {
		ExcavatorLifeLine.posy = posy;
	}
	public static Excavator getExcavator() {
		return excavator;
	}
	public static void setExcavator(Excavator excavator) {
		ExcavatorLifeLine.excavator = excavator;
	}
	
	public static int getActualLifeLineLength(){
		int lifeLinelength = ((int) (length - 
				((double)length * 
						(1-((double)excavator.getHealthPoints() / (double)Excavator.MAX_HEALTH_POINTS)))));
		
		return lifeLinelength>0?lifeLinelength:0;
	}
}
