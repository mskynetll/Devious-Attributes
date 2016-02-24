Scriptname dattPeriodicEventsQuest extends dattQuestBase

dattAttributesAPIQuest Property AttribtesAPI Auto
Faction Property dattRapeTraumaFaction Auto

Function Maintenance()
	RegisterForSingleUpdate(Config.FrequentEventUpdateLatencySec)
	RegisterForSingleUpdateGameTime(Config.PeriodicEventUpdateLatencyHours)
EndFunction

Event OnUpdate()
	AdjustWillpower()
	RegisterForSingleUpdate(Config.FrequentEventUpdateLatencySec)
EndEvent

Event OnUpdateGameTime()
	AdjustTraumaForPCandTrackedNPCs()
	RegisterForSingleUpdateGameTime(Config.PeriodicEventUpdateLatencyHours)
EndEvent

Function AdjustWillpower()
	Log("dattPeriodicEventsQuest - AdjustWillpower for PC and tracked NPCs")
	AttribtesAPI.ModAttribute(Config.PlayerRef,Config.WillpowerAttributeId, WillpowerBaseChange)

	int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	int index = 0
    While index < npcCount
        Actor npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index) as Actor
        If(npc != None) ;precaution
            AttribtesAPI.ModAttribute(npc,Config.WillpowerAttributeId, WillpowerBaseChange)
        EndIf
        index += 1
    EndWhile		
EndFunction

Function AdjustTraumaForPCandTrackedNPCs()

	int newPlayerTraumaLevel = dattPeriodicEventsHelper.AdjustTrauma("Rape",Config.PlayerRef,dattRapeTraumaFaction)
	If(newPlayerTraumaLevel > 0)
    	Log("dattPeriodicEventsQuest - adjust rape trauma for PC, new trauma level = " + newPlayerTraumaLevel)
    EndIf
	int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	int index = 0
    While index < npcCount
        Actor npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index) as Actor
        If(npc != None) ;precaution
            int newTraumaLevel = dattPeriodicEventsHelper.AdjustTrauma("Rape",npc,dattRapeTraumaFaction)
            If(newTraumaLevel > 0)
            	Log("dattPeriodicEventsQuest - adjust rape trauma for " + npc.GetBaseObject().GetName() + ", new trauma level = " + newTraumaLevel)
            EndIf
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