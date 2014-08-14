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
		virtual bool boolean() { throw std::runtime_error(""); }
		virtual void add(Value* value) { throw std::runtime_error(""); }
		virtual void add(std::string name, Value* value) { throw std::runtime_error(""); }
		virtual bool has(std::string key) { return false; }
	};

	class Number : public Value {
	public:
		Number(int value) : myValue(value) { }
		int number() { return myValue; }
	private:
		int myValue;
	};

	class String : public Value {
	public:
		String(std::string value) : myValue(value) { }
		std::string string() { return myValue; }
	private:
		std::string myValue;
	};

	class True : public Value {
	public:
		virtual bool boolean() { return true; }
	};
	
	class False : public Value {
	public:
		virtual bool boolean() { return false; }
	};

	class Array : public Value {
	public:
		Array(std::vector<Value*>& values) : myValues(values) { }
		~Array() { for (size_t i = 0; i < myValues.size(); ++i) delete myValues[i]; }
		virtual Value& operator[](int index) { return *myValues[index]; }
		virtual int size() { return myValues.size(); }
		virtual void add(Value* value) { myValues.push_back(value); }
	private:
		std::vector<Value*> myValues;
	};

	class Object : public Value {
	public:
		Object(std::map<std::string, Value*>& values) : myValues(values) { }
		~Object() { for (std::map<std::string, Value*>::iterator it = myValues.begin(); it != myValues.end(); ++it) delete it->second; }
		virtual Value& operator[](std::string key) { return *myValues[key]; }
		void add(std::string name, Value* value) { myValues[name] = value; }
		bool has(std::string key) { return myValues.find(key) != myValues.end(); }
	private:
		std::map<std::string, Value*> myValues;
	};

	class Null : public Value {
	public:
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
	private:
		Value* myValue;
	};
}
