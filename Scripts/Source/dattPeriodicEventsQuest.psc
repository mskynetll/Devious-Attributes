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
	dattPeriodicEventsHelper.AdjustTrauma("Rape",Config.PlayerRef,dattRapeTraumaFaction)
	RegisterForSingleUpdateGameTime(Config.PeriodicEventUpdateLatencyHours)
EndEvent

Int Property WillpowerBaseChange
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_willpower_base_change")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_willpower_base_change",value)
	EndFunction
EndProperty