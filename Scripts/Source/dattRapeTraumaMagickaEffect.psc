Scriptname dattRapeTraumaMagickaEffect extends ActiveMagicEffect  

Actor Property PlayerRef Auto
dattConstants Property Constants Auto
dattAttributes Property Attributes Auto

Spell Property RapeTraumaSpell Auto
Float Property OriginalMagickaRate Auto
Int Property PlayerLevel Auto
Float Property LessTraumaMultiplier Auto

float startingSleepTime
float lastUpdateTime

Event OnEffectStart(Actor akTarget, Actor akCaster)
	int traumaDuration = StorageUtil.GetIntValue(PlayerRef as Form, Constants.RapeTraumaDurationId, 0)
	lastUpdateTime = Utility.GetCurrentGameTime()
	
	float masochism = Attributes.GetPlayerFetish(Constants.MasochistAttributeId)
	float nympho = Attributes.GetPlayerFetish(Constants.NymphomaniacAttributeId)

	If(masochism >= 95.0 || nympho >= 95.0)
		;even if the fetishes are at max, there is still minimum damage from rape
		LessTraumaMultiplier = 0.05 
	Else
		LessTraumaMultiplier = 1.0 - (((0.5 * masochism) + (0.5 * nympho)) / 100.0)
	Endif

	OriginalMagickaRate = PlayerRef.GetAV("MagickaRate")
	PlayerLevel = PlayerRef.GetLevel()

	PlayerRef.ModAV("Magicka", (-1 * PlayerLevel * 50) * LessTraumaMultiplier)
	PlayerRef.ModAV("MagickaRate", (-1 * OriginalMagickaRate) * LessTraumaMultiplier)

	RegisterForSingleUpdateGameTime(traumaDuration)
	RegisterForSleep()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If(PlayerRef.HasSpell(RapeTraumaSpell))
		PlayerRef.RemoveSpell(RapeTraumaSpell)		

		PlayerRef.ModAV("Magicka", PlayerLevel * 50 * LessTraumaMultiplier)
		PlayerRef.ModAV("MagickaRate", OriginalMagickaRate * LessTraumaMultiplier)
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