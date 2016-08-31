Scriptname dattLowSelfEsteemEffect extends ActiveMagicEffect  

Actor Property PlayerRef Auto
Int Property PlayerLevel Auto Hidden
Float Property ModdedAmount Auto Hidden
Event OnEffectStart(Actor akTarget, Actor akCaster)
	PlayerLevel = PlayerRef.GetLevel()
	float speech = PlayerRef.GetAV("Speechcraft")

	;prevent debuffing more than player already has
	ModdedAmount = dattUtility.Min(speech, (GetMagnitude() + PlayerLevel) / 2)

	PlayerRef.ModAV("Speechcraft", -1 * ModdedAmount)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	PlayerRef.ModAV("Speechcraft", ModdedAmount)
EndEvent
