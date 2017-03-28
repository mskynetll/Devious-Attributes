#include "AttributesTracker.h"


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

	_lastGameTimeTick = currentGameTime;

	float willpowerHorulyIncreaseRate = GetWillpowerHourlyRestorationRate();

	Willpower.Mod([hoursPassed, willpowerHorulyIncreaseRate]
		(float existingVal) -> float { return existingVal + (willpowerHorulyIncreaseRate * hoursPassed); });
}

void AttributesTracker::OnPlayerSleepEvent(float timeSlept, bool wasInterupted)
{

}

void AttributesTracker::OnPlayerCastMagic()
{

}

void AttributesTracker::OnPlayerDeviceEquip(TESObjectARMO* armor)
{

}

void AttributesTracker::OnPlayerDeviceUnequip(TESObjectARMO* armor)
{

}

void AttributesTracker::OnPlayerSexEnd(SInt32 numOfActors, bool isPlayerVictim, bool isPlayerAggressor)
{

}

EventResult AttributesTracker::ReceiveEvent(TESHitEvent * evn, EventDispatcher<TESHitEvent> * dispatcher)
{	
	try 
	{
		if ((*g_thePlayer) == (Actor*)evn->target)
		{
			//_MESSAGE("player was hit : %s --> %s", evn->caster->GetFullName(), evn->target->GetFullName());
		}
		else if ((*g_thePlayer) == (Actor*)evn->caster)
		{
			if (evn->flags & evn->kFlag_SneakAttack)
			{
				//_MESSAGE("player did the hit (as sneak attack) : %s --> %s", evn->caster->GetFullName(), evn->target->GetFullName());
			}
			else
			{
				//_MESSAGE("player did the hit : %s --> %s", evn->caster->GetFullName(), evn->target->GetFullName());
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
	return EventResult::kEvent_Continue;
}

EventResult AttributesTracker::ReceiveEvent(TESCombatEvent * evn, EventDispatcher<TESCombatEvent> * dispatcher)
{
	return EventResult::kEvent_Continue;
}

float AttributesTracker::GetWillpowerHourlyRestorationRate()
{
	float willpowerHorulyIncreaseRate = 8.0; //by default, restore willpower to full state in 12 hours

	//TODO : more calculations that change the hourly restoration rate --> like hunger, etc.

	return willpowerHorulyIncreaseRate;
}

