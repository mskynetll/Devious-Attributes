Scriptname dattPeriodicEventsQuest extends dattQuestBase

dattAttributesAPIQuest Property AttribtesAPI Auto
Faction Property dattRapeTraumaFaction Auto
Spell Property RapeTraumaAbility Auto

Spell Property WillpowerAbility Auto

Function Maintenance()
	RegisterForSingleUpdateGameTime(Config.FrequentEventUpdateLatency)
	RegisterForSleep()
EndFunction

Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)
	LastSleepStart = Utility.GetCurrentGameTime()
EndEvent

Event OnSleepStop(bool abInterrupted)
	float currentTime = Utility.GetCurrentGameTime()
	float hoursSlept = Math.abs(LastSleepStart - currentTime) * 24.0

	If hoursSlept >= Config.PeriodicEventUpdateLatencyHours
		AdjustTraumaForPCandTrackedNPCs()
		LastPeriodicUpdateTime = currentTime
	EndIf

	If hoursSlept >= Config.FrequentEventUpdateLatency
		AdjustWillpower(hoursSlept, true)
	EndIf
EndEvent

Event OnUpdateGameTime()
	float currentTime = Utility.GetCurrentGameTime()
	float hoursSinceFrequentUpdate = Math.abs(LastFrequentUpdateTime - currentTime) * 24.0
	float hoursSincePeriodicUpdate = Math.abs(LastPeriodicUpdateTime - currentTime) * 24.0

	Log("OnUpdateGameTime(), hoursSinceFrequentUpdate = " + hoursSinceFrequentUpdate + ", hoursSincePeriodicUpdate = " + hoursSincePeriodicUpdate)

	If LastPeriodicUpdateTime == 0.0 || hoursSincePeriodicUpdate >= Config.PeriodicEventUpdateLatencyHours
		AdjustTraumaForPCandTrackedNPCs()
		LastPeriodicUpdateTime = currentTime
	EndIf

	If hoursSinceFrequentUpdate == 0.0 || hoursSinceFrequentUpdate >= Config.FrequentEventUpdateLatency		
		AdjustWillpower(dattUtility.Max(hoursSinceFrequentUpdate, 1.0))
		LastFrequentUpdateTime = currentTime
	EndIf	
	RegisterForSingleUpdateGameTime(Config.FrequentEventUpdateLatency)
EndEvent

Function ReapplyRapeTrauma(Actor target)
	If !target.HasSpell(RapeTraumaAbility)
		target.AddSpell(RapeTraumaAbility, false)
	ElseIf target.HasSpell(RapeTraumaAbility)
		target.RemoveSpell(RapeTraumaAbility)
		target.AddSpell(RapeTraumaAbility, false)
	EndIf
EndFunction

Function AdjustWillpower(float hoursPassed, bool wasSleeping = false)
	Log("dattPeriodicEventsQuest - AdjustWillpower for PC and tracked NPCs")
	
	int modMagnitude
	If(wasSleeping == false)
		modMagnitude = Config.WillpowerBaseChange * Math.floor(hoursPassed)
	Else
		modMagnitude = Math.floor((Config.WillpowerBaseChange as float) * hoursPassed * 1.5)
	EndIf

	Log("Adjusting willpower for player, modMagnitude = " + modMagnitude)
	AttribtesAPI.ModAttribute(Config.PlayerRef,Config.WillpowerAttributeId, modMagnitude)

	int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	int index = 0
    While index < npcCount
        Actor npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index) as Actor
        If(npc != None) ;precaution
        	Log("Adjusting willpower for " + npc.GetBaseObject().GetName() +", modMagnitude = " + Config.WillpowerBaseChange * Math.floor(hoursPassed))
            AttribtesAPI.ModAttribute(npc,Config.WillpowerAttributeId, Config.WillpowerBaseChange * Math.floor(hoursPassed))
        EndIf
        index += 1
    EndWhile	
EndFunction

Function AdjustTraumaForPCandTrackedNPCs()
	int newPlayerTraumaLevel = dattPeriodicEventsHelper.AdjustTrauma("Rape",Config.PlayerRef,dattRapeTraumaFaction)
	If(newPlayerTraumaLevel > 0)
    	Log("dattPeriodicEventsQuest - adjust rape trauma for PC, new trauma level = " + newPlayerTraumaLevel)
    	ReapplyRapeTrauma(Config.PlayerRef)
    EndIf

	int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	int index = 0
    While index < npcCount
        Actor npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index) as Actor
        If(npc != None) ;precaution
            int newTraumaLevel = dattPeriodicEventsHelper.AdjustTrauma("Rape",npc,dattRapeTraumaFaction)
            If(newTraumaLevel > 0)
            	Log("dattPeriodicEventsQuest - adjust rape trauma for " + npc.GetBaseObject().GetName() + ", new trauma level = " + newTraumaLevel)
            	ReapplyRapeTrauma(npc)
            EndIf
        EndIf
        index += 1
    EndWhile	
EndFunction

Float Property LastPeriodicUpdateTime
	Float Function Get()
		return StorageUtil.GetFloatValue(None, "_datt_periodic_event_last_periodic_update", 0.0)
	EndFunction
	Function Set(Float value)
		StorageUtil.SetFloatValue(None, "_datt_periodic_event_last_periodic_update", value)
	EndFunction
EndProperty

Float Property LastFrequentUpdateTime
	Float Function Get()
		return StorageUtil.GetFloatValue(None, "_datt_periodic_event_last_frequent_update", 0.0)
	EndFunction
	Function Set(Float value)
		StorageUtil.SetFloatValue(None, "_datt_periodic_event_last_frequent_update", value)
	EndFunction
EndProperty

Float Property LastSleepStart
	Float Function Get()
		return StorageUtil.GetFloatValue(None, "_datt_periodic_event_LastSleepStart", 0.0)
	EndFunction
	Function Set(Float value)
		StorageUtil.SetFloatValue(None, "_datt_periodic_event_LastSleepStart", value)
	EndFunction
EndProperty