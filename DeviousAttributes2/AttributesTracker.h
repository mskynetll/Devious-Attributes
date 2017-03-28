#pragma once
#include <skse/PapyrusNativeFunctions.h>
#include <skse/GameData.h>
#include <skse/GameEvents.h>
#include <skse/GameReferences.h>
#include <skse/GameForms.h>
#include <unordered_map>
#include <thread>
#include <chrono>
#include "Attribute.hpp"
#include <exception>
#include <skse/PluginAPI.h>	

extern const UInt32 kSerializationVersion;

class AttributesTracker :
	public BSTEventSink<TESHitEvent>,
	public BSTEventSink<TESDeathEvent>,
	public BSTEventSink<TESCombatEvent>	
{
protected:

	float _lastSleepTime;
	
	//last time player cast any spell (in game time)
	float _lastSpellCastTime;
	
	//last recorded game time during OnGameTimePassed()
	float _lastGameTimeTick;

	float GetWillpowerHourlyRestorationRate();

public:
	AttributesTracker() : 
		Willpower("willpower"),
		SelfEsteem("selfesteem"),
		Obedience("obedience"),
		Pride("pride")
	{		
		g_hitEventDispatcher->AddEventSink(this);	
		g_deathEventDispatcher->AddEventSink(this);
		g_combatEventDispatcher->AddEventSink(this);
	}

	std::recursive_mutex AttributeChangeMutex;

	virtual	EventResult ReceiveEvent(TESHitEvent* evn, EventDispatcher<TESHitEvent> * dispatcher) override;
	virtual	EventResult ReceiveEvent(TESDeathEvent* evn, EventDispatcher<TESDeathEvent> * dispatcher) override;
	virtual	EventResult ReceiveEvent(TESCombatEvent* evn, EventDispatcher<TESCombatEvent> * dispatcher) override;

	Attribute Willpower;
	Attribute SelfEsteem;
	Attribute Obedience;
	Attribute Pride;

	void Reset()
	{
		Willpower.Set(100.0);
		Pride.Set(100.0);
		SelfEsteem.Set(100.0);
		Obedience.Set(0.0);
	}

	void OnGameTimePassed(float currentGameTime, float hoursPassed);

	void OnPlayerSleepEvent(float timeSlept, bool wasInterupted);

	void OnPlayerCastMagic();

	void OnPlayerDeviceEquip(TESObjectARMO* armor);

	void OnPlayerDeviceUnequip(TESObjectARMO* armor);

	void OnPlayerSexEnd(SInt32 numOfActors, bool isPlayerVictim, bool isPlayerAggressor);

	void Save(SKSESerializationInterface* intfc)
	{
		std::lock_guard<std::recursive_mutex> lock(AttributeChangeMutex);

		if (intfc->OpenRecord('ATTR', kSerializationVersion))
		{
			_MESSAGE("Start peristing attribute values...");
			float willpowerVal = Willpower.Get();

			intfc->WriteRecordData(&willpowerVal, sizeof(float));
			_MESSAGE("Persisted willpower value: %f", willpowerVal);

			float SelfEsteemVal = SelfEsteem.Get();
			intfc->WriteRecordData(&SelfEsteemVal, sizeof(float));
			_MESSAGE("Persisted SelfEsteem value: %f", SelfEsteemVal);

			float obedienceVal = Obedience.Get();
			intfc->WriteRecordData(&obedienceVal, sizeof(float));			
			_MESSAGE("Persisted obedience value: %f", obedienceVal);
		}
		else
		{
			_MESSAGE("Failed to open persistence record, aborting persisting attribute values...");
		}
	}

	void Load(SKSESerializationInterface* intfc)
	{
		std::lock_guard<std::recursive_mutex> lock(AttributeChangeMutex);

		_MESSAGE("Start loading attribute values...");

		UInt32	type;
		UInt32	version;
		UInt32	length;
		bool	error = false;
		UInt32  recordsRead = 0;

		while (!error && intfc->GetNextRecordInfo(&type, &version, &length))
		{
			switch (type)
			{
				case 'ATTR':
					if (version == kSerializationVersion)
					{
						_MESSAGE("Loading attribute values from persistence.");

						float val;
						intfc->ReadRecordData(&val, sizeof(float));
						_MESSAGE("Loaded willpower value: %f", val);
						Willpower.Set(val);

						intfc->ReadRecordData(&val, sizeof(float));
						_MESSAGE("Loaded SelfEsteem value: %f", val);
						SelfEsteem.Set(val);

						intfc->ReadRecordData(&val, sizeof(float));
						_MESSAGE("Loaded obedience value: %f", val);
						Obedience.Set(val);
					}
					else
					{
						_MESSAGE("Error loading attribute values from persistence. Data version mismatch %u, Aborting load...\n", version);
						error = true;
					}
					break;
				default:
					_MESSAGE("Error loading attribute values from persistence.. Invalid record type %08X, Aborting load...\n", type);
					error = true;
					break;
			}
		}
	}
};


namespace AttributesTrackerPapyrus {
	bool RegisterFuncs(VMClassRegistry* registry);
}

static AttributesTracker g_AttributesTracker;