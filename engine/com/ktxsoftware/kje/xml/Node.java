package com.ktxsoftware.kje.xml;

import java.util.List;

public interface Node {
	String getAttribute(String name);
	String getName();
	String getValue();
	void require(String name);
	List<Node> getChilds();
}