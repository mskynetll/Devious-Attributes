#pragma once
#include <skse/PapyrusNativeFunctions.h>
#include <skse/GameEvents.h>
#include <skse/GameForms.h>

class DattAttributesTracker : public TESQuest,
	public BSTEventSink<TESHitEvent>,
	public BSTEventSink<TESDeathEvent>,
	public BSTEventSink<TESSleepStartEvent>,
	public BSTEventSink<TESCombatEvent>,
	public BSTEventSink<TESHarvestEvent::ItemHarvested>
{
public:
	

	virtual	EventResult ReceiveEvent(TESHitEvent * evn, EventDispatcher<TESHitEvent> * dispatcher) override;
	virtual	EventResult ReceiveEvent(TESDeathEvent * evn, EventDispatcher<TESDeathEvent> * dispatcher) override;
	virtual	EventResult ReceiveEvent(TESSleepStartEvent * evn, EventDispatcher<TESSleepStartEvent> * dispatcher) override;
	virtual	EventResult ReceiveEvent(TESCombatEvent * evn, EventDispatcher<TESCombatEvent> * dispatcher) override;
	virtual	EventResult ReceiveEvent(TESHarvestEvent::ItemHarvested * evn, EventDispatcher<TESHarvestEvent::ItemHarvested> * dispatcher) override;
};


namespace AttributesTracker {
	bool RegisterFuncs(VMClassRegistry* registry);
}