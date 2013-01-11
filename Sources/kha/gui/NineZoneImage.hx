package kha.gui;

class NineZoneImage 
{

	public function new() 
	{
		
	}
	
	public:
		NineZoneImage(Text imagename, int x1, int x2, int y1, int y2, int width, int height);
		NineZoneImage(Image image, int x1, int x2, int y1, int y2, int width, int height);
		float width();
		float height();
		void render(Painter* painter);
		void render(Painter* painter, Color color);
		void setSize(int width, int height);
		void setColor(Color myColor);
		void setImage(Image image);
		void setWidth(int width);
	private:
		int x1, x2, y1, y2;
		int myWidth, myHeight;
		Color myColor;
		Image image;

NineZoneImage::NineZoneImage(Text imagename, int x1, int x2, int y1, int y2, int width, int height) : x1(x1), x2(x2), y1(y1), y2(y2), myWidth(width), myHeight(height), image(imagename), myColor(0xffffffff) {

}

NineZoneImage::NineZoneImage(Image image, int x1, int x2, int y1, int y2, int width, int height) : x1(x1), x2(x2), y1(y1), y2(y2), myWidth(width), myHeight(height), image(image), myColor(0xffffffff) {

}

float NineZoneImage::width() {
	return static_cast<float>(myWidth);
}

float NineZoneImage::height() {
	return static_cast<float>(myHeight);
}

void NineZoneImage::setColor(Color color) {
	myColor = color;
}

void NineZoneImage::render(Painter* painter) {
	render(painter, myColor);
}

void NineZoneImage::render(Painter* painter, Color color) {
	painter->drawSubImage(image, 0, 0, 0, 0, static_cast<float>(x1), static_cast<float>(y1), color);
	painter->drawSubImage(image, static_cast<float>(x1), 0, static_cast<float>(myWidth - x2 - x1), static_cast<float>(y1), static_cast<float>(x1), 0, static_cast<float>(image.Width() - x2 - x1), static_cast<float>(y1), color);
	painter->drawSubImage(image, static_cast<float>(myWidth - x2), 0, static_cast<float>(image.Width() - x2), 0, static_cast<float>(x2), static_cast<float>(y1), color);

	painter->drawSubImage(image, 0, static_cast<float>(y1), static_cast<float>(x1), static_cast<float>(myHeight - y2 - y1), 0, static_cast<float>(y1), static_cast<float>(x1), static_cast<float>(image.Height() - y2 - y1), color);
	painter->drawSubImage(image, static_cast<float>(x1), static_cast<float>(y1), static_cast<float>(myWidth - x2 - x1), static_cast<float>(myHeight - y2 - y1), static_cast<float>(x1), static_cast<float>(y1), static_cast<float>(image.Width() - x2 - x1), static_cast<float>(image.Height() - y2 - y1), color);
	painter->drawSubImage(image, static_cast<float>(myWidth - x2), static_cast<float>(y1), static_cast<float>(x2), static_cast<float>(myHeight - y2 - y1), static_cast<float>(image.Width() - x2), static_cast<float>(y1), static_cast<float>(x2), static_cast<float>(image.Height() - y2 - y1), color);

	painter->drawSubImage(image, 0, static_cast<float>(myHeight - y2), 0, static_cast<float>(image.Height() - y2), static_cast<float>(x1), static_cast<float>(y2), color);
	painter->drawSubImage(image, static_cast<float>(x1), static_cast<float>(myHeight - y2), static_cast<float>(myWidth - x2 - x1), static_cast<float>(y2), static_cast<float>(x1), static_cast<float>(image.Height() - y2), static_cast<float>(image.Width() - x2 - x1), static_cast<float>(y2), color);
	painter->drawSubImage(image, static_cast<float>(myWidth - x2), static_cast<float>(myHeight - y2), static_cast<float>(image.Width() - x2), static_cast<float>(image.Height() - y2), static_cast<float>(x2), static_cast<float>(y2), color);
}

void NineZoneImage::setSize(int width, int height) {
	myWidth = width;
	myHeight = height;
}

void NineZoneImage::setImage(Image image) {
	this->image = image;
}

void NineZoneImage::setWidth(int width) {
	myWidth = width;
}
}