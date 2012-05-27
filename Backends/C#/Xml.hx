package ;

@:classContents('
	private System.Xml.XmlNode node;
	private bool isRoot;
	
	class XmlIterator {
		private System.Xml.XmlNodeList nodes;
		private int index;

		public XmlIterator(System.Xml.XmlNodeList nodes) {
			this.nodes = nodes;
			index = 0;
		}

		Xml next() {
			return new Xml(nodes.Item(index++));
		}

		bool hasNext() {
			return index < nodes.Count;
		}
	}

	class XmlRootIterator {
		private System.Xml.XmlNode node;
		private bool visited;

		public XmlRootIterator(System.Xml.XmlNode node) {
			this.node = node;
			visited = false;
		}

		Xml next() {
			visited = true;
			return new Xml(node);
		}

		bool hasNext() {
			return !visited;
		}
	}
	
	public Xml(System.Xml.XmlNode node, bool isRoot) {
		this.node = node;
		this.isRoot = isRoot;
	}

	public Xml(System.Xml.XmlNode node) {
		this.node = node;
		isRoot = false;
	}
')
class Xml {
	@:functionBody('
		return node.Attributes[attribute].Value;
	')
	public function get(attribute : String) : String {
		return null;
	}

	@:functionBody('
		if (isRoot) return new XmlRootIterator(node);
		else return new XmlIterator(node.ChildNodes);
	')
	public function elements() : Iterator<Xml> {
		return null;
	}
	
	public var nodeName(getNodeName,setNodeName) : String;

	public var nodeValue(getNodeValue,setNodeValue) : String;

	private function setNodeName( n : String ) : String {
		return null;
	}

	private function setNodeValue( v : String ) : String {
		return null;
	}

	@:functionBody('
		return node.Name;
	')
	public function getNodeName() : String {
		return null;
	}

	@:functionBody('
		if (isRoot) return new Xml(node);
		return new Xml(node.FirstChild);
	')
	public function firstElement() : Xml {
		return null;
	}

	@:functionBody('
		if (isRoot) return new Xml(node);
		return new Xml(node.FirstChild);
	')
	public function firstChild() : Xml {
		return null;
	}

	@:functionBody('
		return node.Value;
	')
	public function getNodeValue() : String {
		return null;
	}

	@:functionBody('
		var doc = new System.Xml.XmlDocument();
		doc.LoadXml(text);
		return new Xml(doc.DocumentElement, true);
	')
	public static function parse(text : String) : Xml {
		return null;
	}
}