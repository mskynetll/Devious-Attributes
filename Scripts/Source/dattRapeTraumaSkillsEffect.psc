Scriptname dattRapeTraumaSkillsEffect extends ActiveMagicEffect  

Actor Property PlayerRef Auto
dattConstants Property Constants Auto
dattAttributes Property Attributes Auto

Spell Property RapeTraumaSpell Auto

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

	PlayerLevel = PlayerRef.GetLevel()		

	float debuffModifier = -1 * (PlayerLevel * 5) * LessTraumaMultiplier

    PlayerRef.ModAV("OneHanded", debuffModifier)
	PlayerRef.ModAV("TwoHanded", debuffModifier)
	PlayerRef.ModAV("Marksman", debuffModifier)

	PlayerRef.ModAV("Alteration", debuffModifier)
	PlayerRef.ModAV("Conjuration", debuffModifier)
	PlayerRef.ModAV("Destruction", debuffModifier)
	PlayerRef.ModAV("Illusion", debuffModifier)
	PlayerRef.ModAV("Restoration", debuffModifier)
	PlayerRef.ModAV("Enchanting", debuffModifier)

	RegisterForSingleUpdateGameTime(traumaDuration)
	RegisterForSleep()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	If(PlayerRef.HasSpell(RapeTraumaSpell))
		PlayerRef.RemoveSpell(RapeTraumaSpell)			
	Endif
	
	float buffModifier = (PlayerLevel * 5) * LessTraumaMultiplier
    PlayerRef.ModAV("OneHanded", buffModifier)
	PlayerRef.ModAV("TwoHanded", buffModifier)
	PlayerRef.ModAV("Marksman", buffModifier)

	PlayerRef.ModAV("Alteration", buffModifier)
	PlayerRef.ModAV("Conjuration", buffModifier)
	PlayerRef.ModAV("Destruction", buffModifier)
	PlayerRef.ModAV("Illusion", buffModifier)
	PlayerRef.ModAV("Restoration", buffModifier)
	PlayerRef.ModAV("Enchanting", buffModifier)
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