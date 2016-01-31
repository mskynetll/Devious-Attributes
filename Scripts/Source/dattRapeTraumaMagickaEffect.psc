Scriptname dattRapeTraumaMagickaEffect extends ActiveMagicEffect  

Actor Property PlayerRef Auto
dattConstants Property Constants Auto
Spell Property RapeTraumaSpell Auto

float startingSleepTime
float lastUpdateTime

Event OnEffectStart(Actor akTarget, Actor akCaster)
	int traumaDuration = StorageUtil.GetIntValue(PlayerRef as Form, Constants.RapeTraumaDurationId, 0)
	lastUpdateTime = Utility.GetCurrentGameTime()
	RegisterForSingleUpdateGameTime(traumaDuration)
	RegisterForSleep()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If(PlayerRef.HasSpell(RapeTraumaSpell))
		PlayerRef.RemoveSpell(RapeTraumaSpell)		
	Endif
EndEvent

Event OnUpdateGameTime()
	int traumaDuration = StorageUtil.GetIntValue(PlayerRef as Form, Constants.RapeTraumaDurationId, 0)
	float hoursPassed = Math.abs(((lastUpdateTime - Utility.GetCurrentGameTime()) * 24.0))
	If(hoursPassed >= traumaDuration)
		Dispel()
	Else
		StorageUtil.SetIntValue(PlayerRef as Form, Constants.RapeTraumaDurationId, (traumaDuration - hoursPassed) as int)
		lastUpdateTime = Utility.GetCurrentGameTime()
		RegisterForSingleUpdateGameTime(traumaDuration - hoursPassed)
	Endif
EndEvent

Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)
	startingSleepTime = afSleepStartTime
EndEvent

Event OnSleepStop(bool abInterrupted)
	int traumaDuration = StorageUtil.GetIntValue(PlayerRef as Form, Constants.RapeTraumaDurationId, 0)
	float hoursPassed = Math.abs((startingSleepTime - Utility.GetCurrentGameTime()) * 24.0)
	If(hoursPassed >= traumaDuration)
		Dispel()
	Else
		StorageUtil.SetIntValue(PlayerRef as Form, Constants.RapeTraumaDurationId, (traumaDuration - hoursPassed) as int)
		RegisterForSingleUpdateGameTime(traumaDuration - hoursPassed)
	Endif
EndEvent