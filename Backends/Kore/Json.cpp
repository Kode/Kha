#include "pch.h"
#include "Json.h"

using namespace Json;

namespace {
	class Token {
	public:
		virtual bool isArrayStart()  { return false; }
		virtual bool isArrayEnd()    { return false; }
		virtual bool isObjectStart() { return false; }
		virtual bool isObjectEnd()   { return false; }
		virtual bool isWhitespace()  { return false; }
		virtual bool isKomma()       { return false; }
		virtual bool isColon()       { return false; }
		virtual bool isString()      { return false; }
		virtual bool isNumber()      { return false; }
		virtual bool isBoolean()     { return false; }
		virtual bool isTrue()        { return false; }
		virtual bool isFalse()       { return false; }
		virtual bool isEnd()         { return false; }
	};

	class True : public Token {
		virtual bool isBoolean() override { return true; }
		virtual bool isTrue() override { return true; }
	};

	class False : public Token {
		virtual bool isBoolean() override { return true; }
		virtual bool isFalse() override { return true; }
	};

	class Whitespace : public Token {
	public:
		virtual bool isWhitespace() override { return true; }
	};

	class Colon : public Token {
	public:
		virtual bool isColon() override { return true ; }
	};

	class Null {

	};

	class ArrayStart : public Token {
	public:
		virtual bool isArrayStart() override { return true; }
	};

	class ArrayEnd : public Token {
	public:
		virtual bool isArrayEnd() override { return true; }
	};

	class Komma : public Token {
	public:
		virtual bool isKomma() override { return true; }
	};

	class ObjectStart : public Token {
	public:
		virtual bool isObjectStart() override { return true; }
	};

	class ObjectEnd : public Token {
	public:
		virtual bool isObjectEnd() override { return true; }
	};

	class String : public Token {
	public:
		String(std::string value) : myValue(value) { }
		std::string value() { return myValue; }
		virtual bool isString() override { return true; }
	private:
		std::string myValue;
	};

	class Number : public Token {
	public:
		Number(int value) : myValue(value) { }
		int value() { return myValue; }
		virtual bool isNumber() override { return true; }
	private:
		int myValue;
	};

	class End : public Token {
	public:
		virtual bool isEnd() override { return true; }
	};

	bool isNumber(char c) {
		return c >= '0' && c <= '9';
	}

	bool isWhitespace(char c) {
		return c == ' ' || c == '\t' || c == '\r' || c == '\n';
	}

	Number* parseNumber(std::string text, size_t& position) {
		std::string number;
		bool afterPoint = false;
		while (position < text.length() && (isNumber(text[position]) || text[position] == '.')) {
			if (text[position] == '.') afterPoint = true;
			if (!afterPoint) number += text[position];
			++position;
		}
		return new Number(atoi(number.c_str()));
	}

	String* parseString(std::string text, size_t& position) {
		++position;
		std::string string;
		while (position < text.length() && text[position] != '"') {
			string += text[position];
			++position;
		}
		++position;
		return new String(string);
	}

	True* parseTrue(std::string text, size_t& position) {
		++position;
		if (text[position] == 'r') ++position; else throw std::runtime_error("Could not parse 'true'");
		if (text[position] == 'u') ++position; else throw std::runtime_error("Could not parse 'true'");
		if (text[position] == 'e') ++position; else throw std::runtime_error("Could not parse 'true'");
		return new True;
	}

	False* parseFalse(std::string text, size_t& position) {
		++position;
		if (text[position] == 'a') ++position; else throw std::runtime_error("Could not parse 'false'");
		if (text[position] == 'l') ++position; else throw std::runtime_error("Could not parse 'false'");
		if (text[position] == 's') ++position; else throw std::runtime_error("Could not parse 'false'");
		if (text[position] == 'e') ++position; else throw std::runtime_error("Could not parse 'false'");
		return new False;
	}

	class TokenStream {
	public:
		TokenStream(std::string text) : text(text), position(0) {
			advance();
		}

		void advance() {
			if (position >= text.length()) {
				if (!myCurrent->isEnd()) myCurrent = new End;
			}
			else if (isWhitespace(text[position])) {
				++position;
				while (position < text.length() && isWhitespace(text[position])) ++position;
				myCurrent = new Whitespace;
			}
			else if (isNumber(text[position])) {
				myCurrent = parseNumber(text, position);
			}
			else if (text[position] == 't') {
				myCurrent = parseTrue(text, position);
			}
			else if (text[position] == 'f') {
				myCurrent = parseFalse(text, position);
			}
			else if (text[position] == '"') {
				myCurrent = parseString(text, position);
			}
			else if (text[position] == '[') {
				++position;
				myCurrent = new ArrayStart;
			}
			else if (text[position] == ']') {
				++position;
				myCurrent = new ArrayEnd;
			}
			else if (text[position] == '{') {
				++position;
				myCurrent = new ObjectStart;
			}
			else if (text[position] == '}') {
				++position;
				myCurrent = new ObjectEnd;
			}
			else if (text[position] == ',') {
				++position;
				myCurrent = new Komma;
			}
			else if (text[position] == ':') {
				++position;
				myCurrent = new Colon;
			}
			else throw std::runtime_error("Parse error");
		}

		Token* current() {
			return myCurrent;
		}
	private:
		std::string text;
		size_t position;
		Token* myCurrent;
	};

	Json::Array* parseArray(TokenStream&);
	Json::Object* parseObject(TokenStream&);
	Json::String* parseString(TokenStream&);
	Json::Number* parseNumber(TokenStream&);
	Json::True* parseTrue(TokenStream&);
	Json::False* parseFalse(TokenStream&);

	Json::Value* parseValue(TokenStream& stream) {
		if (stream.current()->isWhitespace()) {
			stream.advance();
		}
		if (stream.current()->isArrayStart()) {
			return parseArray(stream);
		}
		else if (stream.current()->isObjectStart()) {
			return parseObject(stream);
		}
		else if (stream.current()->isString()) {
			return parseString(stream);
		}
		else if (stream.current()->isNumber()) {
			return parseNumber(stream);
		}
		else if (stream.current()->isTrue()) {
			return parseTrue(stream);
		}
		else if (stream.current()->isFalse()) {
			return parseFalse(stream);
		}
		else throw std::runtime_error("Unexpected token");
	}

	Json::String* parseString(TokenStream& stream) {
		Json::String* value = new Json::String(dynamic_cast<String*>(stream.current())->value());
		stream.advance();
		return value;
	}

	Json::Number* parseNumber(TokenStream& stream) {
		Json::Number* value = new Json::Number(dynamic_cast<Number*>(stream.current())->value());
		stream.advance();
		return value;
	}

	Json::Array* parseArray(TokenStream& stream) {
		std::vector<Json::Value*> values;
		stream.advance();
		while (!stream.current()->isArrayEnd()) {
			if (stream.current()->isWhitespace()) stream.advance();
			if (stream.current()->isArrayEnd()) break;
			values.push_back(parseValue(stream));
			stream.advance();
		}
		stream.advance();
		return new Json::Array(values);
	}

	Json::Object* parseObject(TokenStream& stream) {
		std::map<std::string, Json::Value*> values;
		stream.advance();
		while (!stream.current()->isObjectEnd()) {
			if (stream.current()->isWhitespace()) stream.advance();
			if (stream.current()->isObjectEnd()) break;
			Json::String* key = parseString(stream);
			if (stream.current()->isWhitespace()) stream.advance();
			stream.advance();
			if (stream.current()->isWhitespace()) stream.advance();
			Json::Value* value = parseValue(stream);
			values[key->string()] = value;
			if (stream.current()->isKomma()) stream.advance();
		}
		stream.advance();
		return new Json::Object(values);
	}

	Json::True* parseTrue(TokenStream& stream) {
		Json::True* value = new Json::True;
		stream.advance();
		return value;
	}

	Json::False* parseFalse(TokenStream& stream) {
		Json::False* value = new Json::False;
		stream.advance();
		return value;
	}
}

Json::Data::Data(std::string text) {
	TokenStream stream(text);
	myValue = parseValue(stream);
}
