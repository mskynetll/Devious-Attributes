Scriptname dattLowPrideEffect extends ActiveMagicEffect  

Actor Property PlayerRef Auto
Int Property PlayerLevel Auto Hidden
Float Property ModdedAmount Auto Hidden
dattAttributes Property Attributes Auto
dattConstants Property Constants Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	PlayerLevel = PlayerRef.GetLevel()
	float masochist = Attributes.GetPlayerFetish(Constants.MasochistAttributeId)
	ModdedAmount = (GetMagnitude() / 100.0) * (PlayerLevel * 25) * (1.0 - (masochist / 100.0))
	PlayerRef.ModAV("Health", -1 * ModdedAmount)

	RegisterForModEvent("Datt_PrideEffectEnd", "OnDispel")
EndEvent

Event OnDispel()
	Dispel()
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	PlayerRef.ModAV("Health", ModdedAmount)
EndEvent
