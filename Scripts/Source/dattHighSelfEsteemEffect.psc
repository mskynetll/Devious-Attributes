Scriptname dattHighSelfEsteemEffect extends ActiveMagicEffect  

Actor Property PlayerRef Auto
Int Property PlayerLevel Auto Hidden
Float Property ModdedAmount Auto Hidden
Event OnEffectStart(Actor akTarget, Actor akCaster)
	PlayerLevel = PlayerRef.GetLevel()
	
	ModdedAmount = (GetMagnitude() + PlayerLevel) / 2
	PlayerRef.ModAV("Speechcraft", ModdedAmount)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	PlayerRef.ModAV("Speechcraft", -1 * ModdedAmount)
EndEvent
