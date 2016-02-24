Scriptname dattPeriodicEventsHelper Extends Form Hidden

Function SetTrauma(string traumaName, Actor akActor, Faction fTraumaFaction, int traumaLevel) global
	If traumaLevel != 10 && traumaLevel != 20 && traumaLevel != 30 &&  traumaLevel != 40 &&  traumaLevel != 50
		Debug.MessageBox("SetTrauma() for traumaName = " + traumaName +", received invalid trauma level (must be 10-50), traumaLevel=" + traumaLevel)
		Return
	EndIf

	akActor.AddToFaction(fTraumaFaction)
	string lastUpdateEntryKey = "_datt_last_" + traumaName +"_trauma_update_time"
	float currentTime = Utility.GetCurrentGameTime()
	StorageUtil.SetFloatValue(akActor as Form, lastUpdateEntryKey, currentTime)
	akActor.SetFactionRank(fTraumaFaction, traumaLevel)
EndFunction

Function AdjustTrauma(string traumaName, Actor akActor, Faction fTraumaFaction) global
	akActor.AddToFaction(fTraumaFaction)
	string lastUpdateEntryKey = "_datt_last_" + traumaName +"_trauma_update_time"
	float currentTime = Utility.GetCurrentGameTime()
	StorageUtil.SetFloatValue(akActor as Form, lastUpdateEntryKey, currentTime)
	If akActor.GetFactionRank(fTraumaFaction) <= 0 ;we are at the minimum, nothing to do
		return
	EndIf

	float lastUpdateTime = StorageUtil.GetFloatValue(akActor as Form, lastUpdateEntryKey, currentTime)
	float stageDecreaseTime = StorageUtil.GetFloatValue(None, "_datt_traumaStageDecreaseTime", 12.0)

	If Math.abs(lastUpdateTime - currentTime) * 24.0 >= stageDecreaseTime
		akActor.ModFactionRank(fTraumaFaction, -10)
	EndIf
EndFunction