#pragma once

//#include "Path.h"
#include <fstream>
#include <map>
#include <stdexcept>
#include <string>
#include <vector>

namespace Json {
	class Root;

	class Value {
	public:
		virtual ~Value() { }
		virtual Value& operator[](int index) { throw std::runtime_error(""); }
		virtual int size() { throw std::runtime_error(""); }
		virtual Value& operator[](std::string key) { throw std::runtime_error(""); }
		virtual std::string string() { throw std::runtime_error(""); }
		virtual int number() { throw std::runtime_error(""); }
		virtual void add(Value* value) { throw std::runtime_error(""); }
		virtual void add(std::string name, Value* value) { throw std::runtime_error(""); }
		virtual bool has(std::string key) { return false; }
		//virtual void serialize(std::ofstream& stream, int indent, bool newline) = 0;
	};

	class Number : public Value {
	public:
		Number(int value) : myValue(value) { }
		int number() { return myValue; }
		//void serialize(std::ofstream& stream, int indent, bool newline);
	private:
		int myValue;
	};

	class String : public Value {
	public:
		String(std::string value) : myValue(value) { }
		std::string string() { return myValue; }
		//void serialize(std::ofstream& stream, int indent, bool newline);
	private:
		std::string myValue;
	};

	class True : public Value {
	public:
		//void serialize(std::ofstream& stream, int indent, bool newline);
	};
	
	class False : public Value {
	public:
		//void serialize(std::ofstream& stream, int indent, bool newline);
	};

	class Array : public Value {
	public:
		Array(std::vector<Value*>& values) : myValues(values) { }
		~Array() { for (size_t i = 0; i < myValues.size(); ++i) delete myValues[i]; }
		virtual Value& operator[](int index) { return *myValues[index]; }
		virtual int size() { return myValues.size(); }
		virtual void add(Value* value) { myValues.push_back(value); }
		//void serialize(std::ofstream& stream, int indent, bool newline);
	private:
		std::vector<Value*> myValues;
	};

	class Object : public Value {
	public:
		//Object() { }
		Object(std::map<std::string, Value*>& values) : myValues(values) { }
		~Object() { for (std::map<std::string, Value*>::iterator it = myValues.begin(); it != myValues.end(); ++it) delete it->second; }
		virtual Value& operator[](std::string key) { return *myValues[key]; }
		void add(std::string name, Value* value) { myValues[name] = value; }
		bool has(std::string key) { return myValues.find(key) != myValues.end(); }
		//void serialize(std::ofstream& stream, int indent, bool newline);
	private:
		std::map<std::string, Value*> myValues;
	};

	class Null : public Value {
	public:
		//void serialize(std::ofstream& stream, int indent, bool newline);
	};

	class Data {
	public:
		Data(std::string text);
		~Data() { delete myValue; }
		Value& operator[](int index) { return (*myValue)[index]; }
		int size() { return myValue->size(); }
		Value& operator[](const std::string key) { return (*myValue)[key]; }
		std::string string() { return myValue->string(); }
		void add(std::string name, Value* value) { myValue->add(name, value); }
		bool has(std::string key) { return myValue->has(key); }
		//void save(kake::Path path);
	private:
		Value* myValue;
	};
}
