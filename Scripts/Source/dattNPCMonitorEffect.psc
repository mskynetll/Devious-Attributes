Scriptname dattNPCMonitorEffect extends ActiveMagicEffect  

Actor Property Myself Auto
Spell Property MonitorSpell Auto
dattNPCScannerQuest Property NPCScanner Auto

bool forceRemoveMonitoring

Event OnEffectStart(Actor akTarget, Actor akCaster)	
	Myself = akTarget
	string name = Myself.GetBaseObject().GetName()
	If(name == "")
		Dispel()
		return
	Endif
	
	forceRemoveMonitoring = false

	RegisterForModEvent("Datt_PlayerCellChange","OnPlayerCellChange")
	RegisterForModEvent("Datt_ForceRemoveNPCMonitor","OnForceRemoveMonitor")
	NPCScanner.OnNPCDetected(akTarget)	
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	Myself.RemoveSpell(MonitorSpell)
	string name = Myself.GetBaseObject().GetName()
	If((forceRemoveMonitoring == false && name != "") || forceRemoveMonitoring == true)
		NPCScanner.OnNPCTooFar(Myself)
	Endif
EndEvent

Event OnForceRemoveMonitor()
	forceRemoveMonitoring = true
	Dispel()
EndEvent

Event OnPlayerCellChange(Form newCell)	
	Dispel()
EndEvent
