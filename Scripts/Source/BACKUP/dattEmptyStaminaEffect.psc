Scriptname dattEmptyStaminaEffect extends ActiveMagicEffect

Event OnEffectStart(Actor akTarget, Actor akCaster)
	float stamina = akTarget.GetAV("Stamina")
	akTarget.DamageAV("Stamina", stamina)
EndEvent