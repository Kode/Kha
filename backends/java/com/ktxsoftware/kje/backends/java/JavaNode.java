package com.ktxsoftware.kje.backends.java;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import com.ktxsoftware.kje.xml.Node;

public class JavaNode implements Node {
	private Element element;
	
	public JavaNode(String filename) {
		try {
			DocumentBuilderFactory docBuilderFactory = DocumentBuilderFactory.newInstance();
        	DocumentBuilder docBuilder = docBuilderFactory.newDocumentBuilder();
        	Document doc = docBuilder.parse(new File(filename));
        	element = doc.getDocumentElement();
		}
		catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	public JavaNode(Element element) {
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
	public String getValue() {
		return element.getTextContent();
	}

	@Override
	public void require(String name) {
		if (!getName().equals(name)) throw new RuntimeException("Expected node " + name + ".");
	}

	@Override
	public List<Node> getChilds() {
		NodeList nodes = element.getChildNodes();
		List<Node> retnodes = new ArrayList<Node>();
		for (int i = 0; i < nodes.getLength(); ++i) if (nodes.item(i) instanceof Element) retnodes.add(new JavaNode((Element)nodes.item(i)));
		return retnodes;
	}
}