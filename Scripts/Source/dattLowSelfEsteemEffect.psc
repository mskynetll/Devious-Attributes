Scriptname dattLowSelfEsteemEffect extends ActiveMagicEffect  

Actor Property PlayerRef Auto
Int Property PlayerLevel Auto Hidden
Float Property ModdedAmount Auto Hidden
Event OnEffectStart(Actor akTarget, Actor akCaster)
	PlayerLevel = PlayerRef.GetLevel()

	ModdedAmount = (GetMagnitude() / 100.0) * (PlayerLevel * 10)
	PlayerRef.ModAV("Speechcraft", -1 * ModdedAmount)

	RegisterForModEvent("Datt_SelfEsteemEffectEnd", "OnDispel")
EndEvent

Event OnDispel()
	Dispel()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	PlayerRef.ModAV("Speechcraft", ModdedAmount)
EndEvent
