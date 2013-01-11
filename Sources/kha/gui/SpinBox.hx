package kha.gui;
import kha.gui.MouseEvent;
import kha.gui.Item;

class SpinUp extends ImageItem {
	public function new() {
		super(Skin::the()->scrollbarup());
		cursor = CursorStyle.Hand;
	}
	
	override public function mouseDown(event: MouseEvent): Item {
		box.up();
		return this;
	}
	
	public var box: SpinBox;
}

class SpinDown extends ImageItem {
	public function new() {
		super(Skin::the()->scrollbardown());
		cursor = CursorStyle.Hand;
	}

	override public function mouseDown(event: MouseEvent): Item {
		box.down();
		return this;
	}
	
	public var box: SpinBox;
}
	
class SpinBox extends Item {
	public function new() {
		upbutton = new SpinUp();
		downbutton = new SpinDown();
		text = new TextItem("1");
		add(upbutton);
		add(downbutton);
		add(text);
		upbutton.box = this;
		downbutton.box = this;
		upbutton.setPos(25, 0);
		downbutton.setPos(25, upbutton.height);
		text.setPos(0, (upbutton.height + downbutton.height) / 2 - text.height / 2);
	}

	public var changed: Void -> Void;
		
	private var start: Int;
	private var end: Int;
	private var upbutton: SpinUp;
	private var downbutton: SpinDown;
	private var text: TextItem;
	private var num: Int = 1;
	
	override private function getWidth() {
		return 25 + upbutton.width;
	}
	
	override private function getHeight() {
		return upbutton.height + downbutton.height;
	}
	
	public function setRange(start: Int, end: Int): Void {
		this.start = start;
		this.end = end;
	}
	
	public function value(): Int {
		return num;
	}
	
	public function up(): Void {
		++num;
		if (num > end) num = end;
		text.setText(Text::number(num));
		changed(num);
	}
	
	public function down(): Void {
		--num;
		if (num < start) num = start;
		text.setText(Text::number(num));
		changed(num);
	}
	
	public function setValue(i: Int): Void {
		num = i;
		text.setText(Text::number(num));
		changed(num);
	}
}