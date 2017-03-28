#pragma once
#include <skse/PapyrusNativeFunctions.h>
#include <skse/PapyrusArgs.h>
#include <skse/GameData.h>
#include <skse/GameEvents.h>
#include <skse/GameReferences.h>
#include <skse/GameForms.h>
#include <string>
#include "AttributesTracker.h"
#include "Attribute.hpp"
#include <boost/algorithm/string.hpp>

namespace DeviousAttributes {
	Attribute* AttributeByName(BSFixedString name);

	float GetAttributeValue(StaticFunctionTag* tag, BSFixedString name)
	{
		std::lock_guard<std::recursive_mutex> lock(g_AttributesTracker.AttributeChangeMutex);

		auto attr = AttributeByName(name);
		if (attr == nullptr)
			return -1.0;

		return attr->Get();
	}

	void ModAttributeValue(StaticFunctionTag* tag, BSFixedString name, float val)
	{
		std::lock_guard<std::recursive_mutex> lock(g_AttributesTracker.AttributeChangeMutex);

		auto attr = AttributeByName(name);
		if (attr != nullptr)
		{
			attr->Mod([val](float existingVal) -> float { return existingVal + val; });
		}
	}

	void SetAttributeValue(StaticFunctionTag* tag, BSFixedString name, float val)
	{
		std::lock_guard<std::recursive_mutex> lock(g_AttributesTracker.AttributeChangeMutex);

		auto attr = AttributeByName(name);
		if (attr != nullptr)
		{
			attr->Set(val);
		}
	}

	Attribute* AttributeByName(BSFixedString name)
	{
		if (boost::iequals(name.data, g_AttributesTracker.Willpower.Name().c_str()))
		{
			return &g_AttributesTracker.Willpower;
		}
		else if (boost::iequals(name.data, g_AttributesTracker.SelfEsteem.Name().c_str()))
		{
			return &g_AttributesTracker.SelfEsteem;
		}
		else if (boost::iequals(name.data, g_AttributesTracker.Obedience.Name().c_str()))
		{
			return &g_AttributesTracker.Obedience;
		}
		else
		{
			return nullptr;
		}
	}

	bool RegisterFuncs(VMClassRegistry* registry) {

		registry->RegisterFunction(new NativeFunction1 <StaticFunctionTag, float, BSFixedString>
			("GetAttributeValue", "DeviousAttributes", GetAttributeValue, registry));
		registry->SetFunctionFlags("DeviousAttributes", "GetAttributeValue", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction2 <StaticFunctionTag, void, BSFixedString, float>
			("ModAttributeValue", "DeviousAttributes", ModAttributeValue, registry));
		registry->SetFunctionFlags("DeviousAttributes", "ModAttributeValue", VMClassRegistry::kFunctionFlag_NoWait);

		registry->RegisterFunction(new NativeFunction2 <StaticFunctionTag, void, BSFixedString, float>
			("SetAttributeValue", "DeviousAttributes", SetAttributeValue, registry));
		registry->SetFunctionFlags("DeviousAttributes", "SetAttributeValue", VMClassRegistry::kFunctionFlag_NoWait);

		return true;
	}
}