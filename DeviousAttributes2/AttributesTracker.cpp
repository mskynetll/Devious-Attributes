#include "AttributesTracker.h"
#include "Utilities.hpp"


namespace AttributesTrackerPapyrus {
	bool RegisterFuncs(VMClassRegistry* registry) {
	
	/*	registry->RegisterFunction(
			new NativeFunction0 <DattAttributesTracker, SInt32>("Foo", "DattAttributesTracker", Foo, registry));*/
		return true;
	}
}

void AttributesTracker::OnGameTimePassed(float currentGameTime, float hoursPassed)
{	
	std::lock_guard<std::recursive_mutex> lock(AttributeChangeMutex);

	_MESSAGE("OnGameTimePassed, currentGameTime: %f, hoursPassed: %f",currentGameTime, hoursPassed);

	_lastGameTimeTick = currentGameTime;

	float willpowerHorulyIncreaseRate = GetWillpowerHourlyRestorationRate();

	Willpower.Mod([hoursPassed, willpowerHorulyIncreaseRate]
		(float existingVal) -> float { return existingVal + (willpowerHorulyIncreaseRate * hoursPassed); });

}

void AttributesTracker::OnPlayerSleepEvent(float timeSlept, bool wasInterupted)
{
	try 
	{
		_MESSAGE("OnPlayerSleepEvent, timeSlept: %f, WasInterupted: %s",timeSlept, wasInterupted ? "true" : "false");
	}
	catch (const std::exception& e)
	{
		_MESSAGE(e.what());
	}
}

void AttributesTracker::OnPlayerCastMagic()
{

}

void AttributesTracker::OnPlayerDeviceEquip(TESObjectARMO* armor)
{
	try 
	{
		_MESSAGE("OnPlayerDeviceEquip: %s",armor->GetName());
	}
	catch (const std::exception& e)
	{
		_MESSAGE(e.what());
	}
}

void AttributesTracker::OnPlayerDeviceUnequip(TESObjectARMO* armor)
{
	try 
	{
		_MESSAGE("OnPlayerDeviceEquip: %s",armor->GetName());
	}
	catch (const std::exception& e)
	{
		_MESSAGE(e.what());
	}
}

void AttributesTracker::OnPlayerSexEnd(SInt32 numOfActors, bool isPlayerVictim, bool isPlayerAggressor)
{
	_MESSAGE("OnPlayerSexEnd: %d, IsPlayerVictim=%s, IsPlayerAggressor=%s",numOfActors, isPlayerVictim ? "true" : "false", isPlayerAggressor? "true" : "false");
}

EventResult AttributesTracker::ReceiveEvent(TESHitEvent * evn, EventDispatcher<TESHitEvent> * dispatcher)
{	
	try 
	{		
		if ((*g_thePlayer) == (Actor*)evn->target)
		{
			_MESSAGE("player was hit : %s --> %s", Utilities::GetFormName(evn->caster->baseForm), Utilities::GetFormName(evn->target->baseForm));
		}
		else if ((*g_thePlayer) == (Actor*)evn->caster)
		{
			if (evn->flags & evn->kFlag_SneakAttack)
			{
				_MESSAGE("player did the hit (as sneak attack) : %s --> %s", Utilities::GetFormName(evn->caster->baseForm), Utilities::GetFormName(evn->target->baseForm));
			}
			else
			{
				_MESSAGE("player did the hit : %s --> %s", Utilities::GetFormName(evn->caster->baseForm), Utilities::GetFormName(evn->target->baseForm));
			}
		}
	}
	catch (const std::exception& e)
	{
		_MESSAGE(e.what());
	}
	return EventResult::kEvent_Continue;
}

EventResult AttributesTracker::ReceiveEvent(TESDeathEvent * evn, EventDispatcher<TESDeathEvent> * dispatcher)
{
	try 
	{
		_MESSAGE("Death event: %s",evn->source->baseForm->GetFullName());
	}
	catch (const std::exception& e)
	{
		_MESSAGE(e.what());
	}

	return EventResult::kEvent_Continue;
}

float AttributesTracker::GetWillpowerHourlyRestorationRate()
{
	float willpowerHorulyIncreaseRate = 8.0; //by default, restore willpower to full state in 12 hours

	//TODO : more calculations that change the hourly restoration rate --> like hunger, etc.

	return willpowerHorulyIncreaseRate;
}

