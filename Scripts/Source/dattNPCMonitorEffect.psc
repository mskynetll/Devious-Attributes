Scriptname dattNPCMonitorEffect extends ActiveMagicEffect  

Actor Property Myself Auto
Spell Property MonitorSpell Auto
dattNPCScannerQuest Property NPCScanner Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)	
	Myself = akTarget
	RegisterForModEvent("Datt_PlayerCellChange","OnPlayerCellChange")
	RegisterForModEvent("Datt_ForceRemoveNPCMonitor","OnForceRemoveMonitor")
	NPCScanner.OnNPCDetected(akTarget)	
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	Myself.RemoveSpell(MonitorSpell)
	NPCScanner.OnNPCTooFar(Myself)
EndEvent

Event OnForceRemoveMonitor()
	Dispel()
EndEvent

Event OnPlayerCellChange(Form newCell)	
	Dispel()
EndEvent
