Scriptname dattNPCScanerCloackAppliedEffect extends ActiveMagicEffect  

Spell Property MonitorSpell Auto
MagicEffect Property MonitorEffect Auto
Actor Property PlayerRef Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
	Race targetRace = akTarget.GetRace()
	bool targetHasMagicEffect = akTarget.HasMagicEffect(MonitorEffect)
	If targetHasMagicEffect && akTarget.GetDistance(PlayerRef) >= 10000.0
		akTarget.DispelSpell(MonitorSpell)
		akTarget.RemoveSpell(MonitorSpell)
	ElseIf(!targetHasMagicEffect && akTarget.GetRelationshipRank(PlayerRef) >= 0 && targetRace != None && targetRace.IsRaceFlagSet(0x00000001) == true && akTarget.IsChild() == false && akTarget.IsGuard() == false && akTarget.IsGhost() == false && akTarget.IsFlying() == false)
		akTarget.AddSpell(MonitorSpell, false)
	EndIf
EndEvent