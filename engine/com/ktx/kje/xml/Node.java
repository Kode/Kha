package com.ktx.kje.xml;

import java.util.List;

public interface Node {
	String getAttribute(String name);
	String getName();
	void require(String name);
	List<Node> getChilds();
}