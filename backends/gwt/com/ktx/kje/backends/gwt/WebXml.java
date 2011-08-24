package com.ktx.kje.backends.gwt;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.xml.client.Element;
import com.google.gwt.xml.client.NodeList;
import com.ktx.kje.xml.Node;

public class WebXml implements Node {
	private Element element;
	
	public WebXml(Element element) {
		this.element = element;
	}
	
	@Override
	public String getAttribute(String name) {
		return element.getAttribute(name);
	}

	@Override
	public String getName() {
		return element.getNodeName();
	}

	@Override
	public void require(String name) {
		if (!getName().equals(name)) throw new RuntimeException();
	}

	@Override
	public List<Node> getChilds() {
		NodeList nodes = element.getChildNodes();
		List<Node> retNodes = new ArrayList<Node>();
		for (int i = 0; i < nodes.getLength(); ++i) if (nodes.item(i) instanceof Element) retNodes.add(new WebXml((Element)nodes.item(i)));
		return retNodes;
	}
}