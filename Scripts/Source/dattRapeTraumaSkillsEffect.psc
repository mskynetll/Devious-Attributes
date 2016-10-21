Scriptname dattRapeTraumaSkillsEffect extends ActiveMagicEffect  

Actor Property PlayerRef Auto
dattAttributesAPIQuest Property AttributesAPI Auto
dattConfigQuest Property Config Auto
Actor Property EffectTarget Auto Hidden

Float Property Magnitude Auto Hidden
Float Property LessTraumaMultiplier Auto Hidden 
Float Property OriginalMagickaRate Auto Hidden

Event OnEffectStart(Actor akTarget, Actor akCaster)
	EffectTarget = akTarget	
	float masochism = AttributesAPI.GetAttribute(EffectTarget, Config.MasochismAttributeId) as float
	float nympho = AttributesAPI.GetAttribute(EffectTarget, Config.NymphomaniaAttributeId) as float

	If(masochism >= 95.0 || nympho >= 95.0)
		;even if the fetishes are at max, there is still minimum damage from rape
		LessTraumaMultiplier = 0.05 
	Else
		LessTraumaMultiplier = 1.0 - (((0.5 * masochism) + (0.5 * nympho)) / 100.0)
	Endif

	Magnitude = GetMagnitude() / 100.0
	OriginalMagickaRate = EffectTarget.GetAV("MagickaRate")
	float debuffModifier = -1 * Magnitude * LessTraumaMultiplier

    EffectTarget.ModAV("OneHanded", debuffModifier)
	EffectTarget.ModAV("TwoHanded", debuffModifier)
	EffectTarget.ModAV("Marksman", debuffModifier)

	EffectTarget.ModAV("Alteration", debuffModifier)
	EffectTarget.ModAV("Conjuration", debuffModifier)
	EffectTarget.ModAV("Destruction", debuffModifier)
	EffectTarget.ModAV("Illusion", debuffModifier)
	EffectTarget.ModAV("Restoration", debuffModifier)
	EffectTarget.ModAV("Enchanting", debuffModifier)

	EffectTarget.ModAV("Magicka", (-1 * Magnitude) * LessTraumaMultiplier)
	EffectTarget.ModAV("MagickaRate", (-1 * OriginalMagickaRate) * LessTraumaMultiplier)	

	If(EffectTarget == PlayerRef)
		StorageUtil.SetIntValue(PlayerRef, "_datt_PC_has_rape_trauma", 1)
	Endif
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	float buffModifier = Magnitude * LessTraumaMultiplier
    EffectTarget.ModAV("OneHanded", buffModifier)
	EffectTarget.ModAV("TwoHanded", buffModifier)
	EffectTarget.ModAV("Marksman", buffModifier)

	EffectTarget.ModAV("Alteration", buffModifier)
	EffectTarget.ModAV("Conjuration", buffModifier)
	EffectTarget.ModAV("Destruction", buffModifier)
	EffectTarget.ModAV("Illusion", buffModifier)
	EffectTarget.ModAV("Restoration", buffModifier)
	EffectTarget.ModAV("Enchanting", buffModifier)

	EffectTarget.ModAV("Magicka", Magnitude * LessTraumaMultiplier)
	EffectTarget.ModAV("MagickaRate", OriginalMagickaRate * LessTraumaMultiplier)	

	If(EffectTarget == PlayerRef)
		StorageUtil.SetIntValue(PlayerRef, "_datt_PC_has_rape_trauma", 0)
	Endif
EndEvent