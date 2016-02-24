Scriptname dattRapeTraumaSkillsEffect extends ActiveMagicEffect  

Actor Property PlayerRef Auto
dattAttributesAPIQuest Property AttributesAPI Auto
dattConfigQuest Property Config Auto

Float Property Magnitude Auto
Float Property LessTraumaMultiplier Auto
Float Property OriginalMagickaRate Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	float masochism = AttributesAPI.GetAttribute(PlayerRef, Config.MasochistAttributeId) as float
	float nympho = AttributesAPI.GetAttribute(PlayerRef, Config.NymphomaniacAttributeId) as float

	If(masochism >= 95.0 || nympho >= 95.0)
		;even if the fetishes are at max, there is still minimum damage from rape
		LessTraumaMultiplier = 0.05 
	Else
		LessTraumaMultiplier = 1.0 - (((0.5 * masochism) + (0.5 * nympho)) / 100.0)
	Endif

	Magnitude = GetMagnitude() / 100.0
	OriginalMagickaRate = PlayerRef.GetAV("MagickaRate")
	float debuffModifier = -1 * Magnitude * LessTraumaMultiplier

    PlayerRef.ModAV("OneHanded", debuffModifier)
	PlayerRef.ModAV("TwoHanded", debuffModifier)
	PlayerRef.ModAV("Marksman", debuffModifier)

	PlayerRef.ModAV("Alteration", debuffModifier)
	PlayerRef.ModAV("Conjuration", debuffModifier)
	PlayerRef.ModAV("Destruction", debuffModifier)
	PlayerRef.ModAV("Illusion", debuffModifier)
	PlayerRef.ModAV("Restoration", debuffModifier)
	PlayerRef.ModAV("Enchanting", debuffModifier)

	PlayerRef.ModAV("Magicka", (-1 * Magnitude) * LessTraumaMultiplier)
	PlayerRef.ModAV("MagickaRate", (-1 * OriginalMagickaRate) * LessTraumaMultiplier)	

	StorageUtil.SetIntValue(PlayerRef, "_datt_PC_has_rape_trauma", 1)
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	float buffModifier = Magnitude * LessTraumaMultiplier
    PlayerRef.ModAV("OneHanded", buffModifier)
	PlayerRef.ModAV("TwoHanded", buffModifier)
	PlayerRef.ModAV("Marksman", buffModifier)

	PlayerRef.ModAV("Alteration", buffModifier)
	PlayerRef.ModAV("Conjuration", buffModifier)
	PlayerRef.ModAV("Destruction", buffModifier)
	PlayerRef.ModAV("Illusion", buffModifier)
	PlayerRef.ModAV("Restoration", buffModifier)
	PlayerRef.ModAV("Enchanting", buffModifier)

	PlayerRef.ModAV("Magicka", Magnitude * LessTraumaMultiplier)
	PlayerRef.ModAV("MagickaRate", OriginalMagickaRate * LessTraumaMultiplier)	

	StorageUtil.SetIntValue(PlayerRef, "_datt_PC_has_rape_trauma", 0)
EndEvent