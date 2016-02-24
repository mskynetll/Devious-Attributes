Scriptname dattPeriodicEventsQuest extends dattQuestBase

dattAttributesAPIQuest Property AttribtesAPI Auto
Faction Property dattRapeTraumaFaction Auto

Function Maintenance()
	RegisterForSingleUpdate(Config.FrequentEventUpdateLatencySec)
	RegisterForSingleUpdateGameTime(Config.PeriodicEventUpdateLatencyHours)
EndFunction

Event OnUpdate()
	RegisterForSingleUpdate(Config.FrequentEventUpdateLatencySec)
EndEvent

Event OnUpdateGameTime()
	AdjustTraumaForPCandTrackedNPCs()
	RegisterForSingleUpdateGameTime(Config.PeriodicEventUpdateLatencyHours)
EndEvent

Function AdjustTraumaForPCandTrackedNPCs()
	dattPeriodicEventsHelper.AdjustTrauma("Rape",Config.PlayerRef,dattRapeTraumaFaction)
	int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	int index = 0
    While index < npcCount
        Actor npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index) as Actor
        If(npc != None) ;precaution
            dattPeriodicEventsHelper.AdjustTrauma("Rape",npc,dattRapeTraumaFaction)
        EndIf
        index += 1
    EndWhile	
EndFunction

Int Property WillpowerBaseChange
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_willpower_base_change")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_willpower_base_change",value)
	EndFunction
EndProperty