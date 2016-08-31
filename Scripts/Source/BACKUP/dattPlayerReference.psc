Scriptname dattPlayerReference extends dattAttributesReferenceAlias

Spell Property NPCScannerAbility Auto
GlobalVariable Property dattPeriodicUpdateNPCList Auto

Event OnPlayerLoadGame()
	MonitorQuest.Maintenance()
	RegisterForSingleUpdate(MonitorQuest.Config.NPCScannerTickSec)
	RegisterForModEvent("Datt_ForceNPCScan", "ScanForNPCs")
EndEvent

Event OnUpdate()
	ScanForNPCs()
	RegisterForSingleUpdate(MonitorQuest.Config.NPCScannerTickSec)
EndEvent

Event ScanForNPCs()
	MonitorQuest.PlayerRef.AddSpell(NPCScannerAbility, false)
	Utility.Wait(1)
	MonitorQuest.PlayerRef.DispelSpell(NPCScannerAbility)
	MonitorQuest.PlayerRef.RemoveSpell(NPCScannerAbility)
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	dattUtility.SendParameterlessEvent("Datt_ForceRemoveNPCMonitor")
	ScanForNPCs()
endEvent
