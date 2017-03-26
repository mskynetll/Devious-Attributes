#include "DattAttributesTracker.h"
#include <boost\bind.hpp>

namespace AttributesTracker {
	bool RegisterFuncs(VMClassRegistry* registry) {
		auto f = boost::bind(&DattAttributesTracker::)
	/*	registry->RegisterFunction(
			new NativeFunction0 <DattAttributesTracker, SInt32>("Foo", "DattAttributesTracker", Foo, registry));*/
		return true;
	}
}

EventResult DattAttributesTracker::ReceiveEvent(TESHitEvent * evn, EventDispatcher<TESHitEvent> * dispatcher)
{	
	return EventResult::kEvent_Continue;
}

EventResult DattAttributesTracker::ReceiveEvent(TESDeathEvent * evn, EventDispatcher<TESDeathEvent> * dispatcher)
{
	return EventResult::kEvent_Continue;
}

EventResult DattAttributesTracker::ReceiveEvent(TESSleepStartEvent * evn, EventDispatcher<TESSleepStartEvent> * dispatcher)
{
	return EventResult::kEvent_Continue;
}

EventResult DattAttributesTracker::ReceiveEvent(TESCombatEvent * evn, EventDispatcher<TESCombatEvent> * dispatcher)
{
	return EventResult::kEvent_Continue;
}

EventResult DattAttributesTracker::ReceiveEvent(TESHarvestEvent::ItemHarvested * evn, EventDispatcher<TESHarvestEvent::ItemHarvested> * dispatcher)
{
	return EventResult::kEvent_Continue;
}

