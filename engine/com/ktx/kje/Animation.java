package com.ktx.kje;

public class Animation {
	private int[] indices;
	private int speeddiv;
	private int count;
	private int index;
	
	public Animation(int index) {
		indices = new int[1];
		indices[0] = index;
		speeddiv = 1;
	}
	
	public Animation(int minindex, int maxindex, int speeddiv) {
		indices = new int[maxindex - minindex + 1];
		for (int i = 0; i < maxindex - minindex + 1; ++i) indices[i] = minindex + i;
		this.speeddiv = speeddiv;
	}
	
	public Animation(int[] indices, int speeddiv) {
		this.indices = indices;
		this.speeddiv = speeddiv;
	}
	
	public int get() {
		return indices[index];
	}
	
	public void next() {
		++count;
		if (count % speeddiv == 0) {
			++index;
			if (index >= indices.length) index = 0;
		}
	}
	
	public void reset() {
		count = 0;
		index = 0;
	}
}