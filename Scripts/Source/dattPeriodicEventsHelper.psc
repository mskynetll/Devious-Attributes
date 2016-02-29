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

int Function AdjustTrauma(string traumaName, Actor akActor, Faction fTraumaFaction) global
	akActor.AddToFaction(fTraumaFaction)
	string lastUpdateEntryKey = "_datt_last_" + traumaName +"_trauma_update_time"
	float currentTime = Utility.GetCurrentGameTime()
	If akActor.GetFactionRank(fTraumaFaction) <= 0 ;we are at the minimum, nothing to do
		akActor.SetFactionRank(fTraumaFaction, 0)

		;set the last update entry anyway
		StorageUtil.SetFloatValue(akActor as Form, lastUpdateEntryKey, currentTime)
		return 0
	EndIf

	float lastUpdateTime = StorageUtil.GetFloatValue(akActor as Form, lastUpdateEntryKey)	
	If lastUpdateTime == 0.0
		akActor.ModFactionRank(fTraumaFaction, -10)
	Else
		float stageDecreaseTime = StorageUtil.GetFloatValue(None, "_datt_traumaStageDecreaseTime", 12.0)
		float hoursPassed = Math.abs(lastUpdateTime - currentTime) * 24.0
		MiscUtil.PrintConsole("[Datt] Adjust trauma for " + akActor.GetBaseObject().GetName() + ", hoursPassed = " + hoursPassed + ", will adjust trauma level by " + (-10 * Math.floor(hoursPassed)))
		If hoursPassed >= stageDecreaseTime
			akActor.ModFactionRank(fTraumaFaction, -10 * Math.floor(hoursPassed / stageDecreaseTime))
		EndIf
	EndIf
	StorageUtil.SetFloatValue(akActor as Form, lastUpdateEntryKey, currentTime)
	return akActor.GetFactionRank(fTraumaFaction)
EndFunction