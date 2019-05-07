#pragma once
#include <skse/GameForms.h>
#include <skse/GameRTTI.h>
#include "AttributesTracker.h"

namespace Utilities
{
	const char* GetFormName(TESForm* form)
	{
		auto pFullName = DYNAMIC_CAST(form, TESForm, TESFullName);
		if (pFullName)
			return pFullName->name.data;
		return "<empty name>";
	}

	bool IsModLoaded(StaticFunctionTag* tag, BSFixedString modFilename)
	{
		_MESSAGE("WTF");
		auto modIndex = DataHandler::GetSingleton()->GetModIndex(modFilename.data);
		_MESSAGE("IsModLoaded(\"%s\") -> %d",modFilename.data, modIndex);
		return modIndex != 255;
	}

	bool RegisterFuncs(VMClassRegistry* registry) {
		try{
			registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, bool, BSFixedString>
				("IsModLoaded", "dattUtilities", IsModLoaded, registry));
		}
		catch (const std::exception& e)
		{
			_MESSAGE(e.what());
			return false;
		}

		return true;
	}
}