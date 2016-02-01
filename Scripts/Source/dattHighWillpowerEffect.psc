Scriptname dattHighWillpowerEffect extends ActiveMagicEffect  

Actor Property PlayerRef Auto
Float Property ModdedAmount Auto Hidden
Event OnEffectStart(Actor akTarget, Actor akCaster)
	ModdedAmount = PlayerRef.GetAV("Speechcraft") * (GetMagnitude() / 100.0)
	PlayerRef.ModAV("Speechcraft", ModdedAmount)

	RegisterForModEvent("Datt_WillpowerEffectEnd", "OnDispel")
EndEvent

Event OnDispel()
	Dispel()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	PlayerRef.ModAV("Speechcraft", -1 * ModdedAmount)
EndEvent
