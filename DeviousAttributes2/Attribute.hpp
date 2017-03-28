#pragma once
#include <mutex>

class Attribute
{
protected:
	//allows the same thread to lock the mutex multiple times
	std::recursive_mutex _mutex;
	
	float _value;

	std::string _name;
public:
	Attribute(const std::string &name)
	{
		_name = std::string(name);
	}

	const std::string& Name() const
	{
		return _name;
	}

	void Set(float val)
	{
		std::lock_guard<std::recursive_mutex> lock(_mutex);
		_value = val;		
	}

	void Mod(std::function<float(float)> mutator)
	{
		std::lock_guard<std::recursive_mutex> lock(_mutex);
		_value = mutator(_value);
	}

	float Get()
	{
		std::lock_guard<std::recursive_mutex> lock(_mutex);
		return _value;
	}	
};

