package com.ktxsoftware.kje.backends.android;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import com.ktxsoftware.kje.xml.Node;


public class AndroidNode implements Node{
    
    private Element element;
	
	public AndroidNode(InputStream fileIS) {
		try {
			DocumentBuilderFactory docBuilderFactory = DocumentBuilderFactory.newInstance();
    	DocumentBuilder docBuilder = docBuilderFactory.newDocumentBuilder();
    	Document doc = docBuilder.parse(fileIS);
    	element = doc.getDocumentElement();
		}
		catch (Exception ex) {
			ex.printStackTrace();
		}
	}
	
	public AndroidNode(Element element) {
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
		if (!getName().equals(name)) throw new RuntimeException("Expected node " + name + ".");
	}

	@Override
	public List<Node> getChilds() {
		NodeList nodes = element.getChildNodes();
		List<Node> retnodes = new ArrayList<Node>();
		for (int i = 0; i < nodes.getLength(); ++i) if (nodes.item(i) instanceof Element) retnodes.add(new AndroidNode((Element)nodes.item(i)));
		return retnodes;
	}
}
