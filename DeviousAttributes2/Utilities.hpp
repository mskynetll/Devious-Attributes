#pragma once
#include <skse/GameForms.h>
#include <skse/GameRTTI.h>

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
		DataHandler* dhdl = DataHandler::GetSingleton();
		UInt32 idx = dhdl->GetModIndex(modFilename.data);
	
		return idx != 0xFF;
	}
	bool RegisterFuncs(VMClassRegistry* registry) {
		registry->RegisterFunction(new NativeFunction1<StaticFunctionTag, bool, BSFixedString>
			("IsModLoaded", "dattUtilities", IsModLoaded, registry));
	}
}