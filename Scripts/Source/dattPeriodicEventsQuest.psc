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
		AdjustSelfEsteemPeriodic(hoursSincePeriodicUpdate)		
		LastPeriodicUpdateTime = currentTime
	EndIf

	If hoursSinceFrequentUpdate == 0.0 || hoursSinceFrequentUpdate >= Config.FrequentEventUpdateLatency		
		AdjustWillpower(dattUtility.Max(hoursSinceFrequentUpdate, 1.0))		
		AdjustArousalForPCandTrackedNPCs(hoursSinceFrequentUpdate)
		LastFrequentUpdateTime = currentTime
	EndIf	
	RegisterForSingleUpdateGameTime(Config.FrequentEventUpdateLatency)
EndEvent

Function AdjustArousalForPCandTrackedNPCs(float hoursPassed)
	int playerNympho = AttribtesAPI.GetAttribute(Config.PlayerRef,Config.NymphomaniacAttributeId)
	If playerNympho > 0
		Log("Sending arousal increase for PC, nymphoValue = " + playerNympho)
		dattUtility.SendIncreaseArousal(Config.PlayerRef, AdjustNymphoValueForArousalIncrease(playerNympho) * dattUtility.Min(0.1,hoursPassed))
	EndIf

	int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	int index = 0
    While index < npcCount
        Actor npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index) as Actor
        If(npc != None) ;precaution
        	int nympho = AttribtesAPI.GetAttribute(npc,Config.NymphomaniacAttributeId)
        	If nympho > 0
        		Log("Sending arousal increase for " + npc.GetBaseObject().GetName() +", nymphoValue = " + nympho)
				dattUtility.SendIncreaseArousal(npc, AdjustNymphoValueForArousalIncrease(nympho) * dattUtility.Min(0.1,hoursPassed))
			EndIf
        EndIf
        index += 1
    EndWhile		
EndFunction

float Function AdjustNymphoValueForArousalIncrease(int nymphoValue)
	if nymphoValue <= 10
		return 0.1
	ElseIf nymphoValue > 10 && nymphoValue <= 25
		return 0.15
	ElseIf nymphoValue > 25 && nymphoValue <= 50
		return 0.2
	ElseIf nymphoValue > 50 && nymphoValue <= 75
		return 0.25
	ElseIf nymphoValue > 75
		return 0.5
	EndIf

EndFunction

Function ReapplyRapeTrauma(Actor target)
	If !target.HasSpell(RapeTraumaAbility)
		target.AddSpell(RapeTraumaAbility, false)
	ElseIf target.HasSpell(RapeTraumaAbility)
		target.RemoveSpell(RapeTraumaAbility)
		target.AddSpell(RapeTraumaAbility, false)
	EndIf
EndFunction

Function AdjustSelfEsteemPeriodic(float hoursPassed)
	int soulState = AttribtesAPI.GetAttribute(Config.PlayerRef,Config.SoulStateAttributeId)
	If soulState == 0 ;only free in spirit get periodic self-esteem increase
		AttribtesAPI.ModAttribute(Config.PlayerRef,Config.SelfEsteemAttributeId,Config.PeriodicSelfEsteemIncrease)
	EndIf
EndFunction

Function AdjustWillpower(float hoursPassed, bool wasSleeping = false)
	Log("dattPeriodicEventsQuest - AdjustWillpower for PC and tracked NPCs")
	
	int modMagnitude
	int intHoursPassed = Math.floor(hoursPassed)
	If(wasSleeping == false)
		modMagnitude = Config.WillpowerBaseChange * intHoursPassed
	Else
		modMagnitude = Math.floor((Config.WillpowerBaseChange as float) * hoursPassed * 1.5)
	EndIf	

	int playerTraumaLevel = Config.PlayerRef.GetFactionRank(dattRapeTraumaFaction)
	modMagnitude = DebuffWillpowerModBasedOnTrauma(modMagnitude, playerTraumaLevel)

	Log("Adjusting willpower for player, modMagnitude -> modMagnitude/trauma level = " + modMagnitude + ", player trauma level = " + playerTraumaLevel)
	AttribtesAPI.ModAttribute(Config.PlayerRef,Config.WillpowerAttributeId, modMagnitude)

	int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	int index = 0
    While index < npcCount
        Actor npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index) as Actor
        If(npc != None) ;precaution
        	int npcTraumaLevel = npc.GetFactionRank(dattRapeTraumaFaction)
        	int npcModMagnitude = DebuffWillpowerModBasedOnTrauma(Config.WillpowerBaseChange * intHoursPassed, npcTraumaLevel)

        	Log("Adjusting willpower for " + npc.GetBaseObject().GetName() +", modMagnitude = " + npcModMagnitude + " , trauma level = " + npcTraumaLevel)
            AttribtesAPI.ModAttribute(npc,Config.WillpowerAttributeId, npcModMagnitude)
        EndIf
        index += 1
    EndWhile	
EndFunction

Int Function DebuffWillpowerModBasedOnTrauma(int mod,int trauma)
	If trauma == 0
		return mod
	EndIf

	If trauma <= 10
		Return mod - dattUtility.MaxInt(1, mod / 5)
	EndIf

	If trauma > 10 && trauma <= 30
		Return mod - dattUtility.MaxInt(1, mod / 2)
	EndIf

	If trauma > 30 && trauma <= 40
		Return mod - dattUtility.MaxInt(1, mod - 1)
	EndIf

	Return 0
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

Float Function GetLastTimeHadSex(Actor akActor)
	return StorageUtil.GetFloatValue(akActor, "_datt_periodic_event_LastTimeHadSex", 0.0)
EndFunction

Function SetLastTimeHadSex(Actor akActor,float fTime)
	StorageUtil.SetFloatValue(akActor, "_datt_periodic_event_LastTimeHadSex", fTime)
EndFunction