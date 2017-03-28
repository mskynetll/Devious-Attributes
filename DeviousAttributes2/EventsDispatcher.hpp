#pragma once
#include <skse/PapyrusNativeFunctions.h>
#include <skse/PapyrusArgs.h>
#include <skse/GameData.h>
#include <skse/GameEvents.h>
#include <skse/GameReferences.h>
#include <skse/GameForms.h>

#include "AttributesTracker.h"

namespace EventsDispatcher
{
	void OnGameTimePassed(StaticFunctionTag* tag, float currentGameTime, float hoursPassed)
	{
		g_AttributesTracker.OnGameTimePassed(currentGameTime, hoursPassed);
	}

	void OnPlayerSleepEvent(StaticFunctionTag* tag, float timeSlept, bool wasInterupted)
	{
		g_AttributesTracker.OnPlayerSleepEvent(timeSlept, wasInterupted);
	}

	void OnPlayerCastMagic(StaticFunctionTag* tag)
	{
		g_AttributesTracker.OnPlayerCastMagic();
	}

	void OnPlayerDeviceEquip(StaticFunctionTag* tag, TESObjectARMO* armor)
	{
		g_AttributesTracker.OnPlayerDeviceEquip(armor);
	}

	void OnPlayerDeviceUnequip(StaticFunctionTag* tag, TESObjectARMO* armor)
	{		
		g_AttributesTracker.OnPlayerDeviceUnequip(armor);
	}

	void OnPlayerSexEnd(StaticFunctionTag* tag, SInt32 numOfActors, bool isPlayerVictim, bool isPlayerAggressor)
	{
		g_AttributesTracker.OnPlayerSexEnd(numOfActors, isPlayerVictim, isPlayerAggressor);
	}

	bool RegisterFuncs(VMClassRegistry* registry) {

		registry->RegisterFunction(new NativeFunction2 <StaticFunctionTag, void, float, float>
			("OnGameTimePassed", "dattEventsDispatcher", OnGameTimePassed, registry));
		
		registry->RegisterFunction(new NativeFunction2 <StaticFunctionTag, void, float, bool>
			("OnPlayerSleepEvent", "dattEventsDispatcher", OnPlayerSleepEvent, registry));

		registry->RegisterFunction(new NativeFunction0 <StaticFunctionTag, void>
			("OnPlayerCastMagic", "dattEventsDispatcher", OnPlayerCastMagic, registry));

		registry->RegisterFunction(new NativeFunction1 <StaticFunctionTag, void, TESObjectARMO*>
			("OnPlayerDeviceEquip", "dattEventsDispatcher", OnPlayerDeviceEquip, registry));

		registry->RegisterFunction(new NativeFunction1 <StaticFunctionTag, void, TESObjectARMO*>
			("OnPlayerDeviceUnequip", "dattEventsDispatcher", OnPlayerDeviceUnequip, registry));

		registry->RegisterFunction(new NativeFunction3 <StaticFunctionTag, void, SInt32, bool, bool>
			("OnPlayerSexEnd", "dattEventsDispatcher", OnPlayerSexEnd, registry));

		return true;
	}
}