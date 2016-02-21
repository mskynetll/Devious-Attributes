Scriptname dattPlayerReference extends dattAttributesReferenceAlias

Spell Property NPCScannerAbility Auto
GlobalVariable Property dattPeriodicUpdateNPCList Auto

Event OnPlayerLoadGame()
	MonitorQuest.Maintenance()
	RegisterForSingleUpdate(MonitorQuest.Config.NPCScannerTickSec)
	RegisterForModEvent("Datt_ForceNPCScan","ScanForNPCs")
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
	SendParameterlessEvent("Datt_ForceRemoveNPCMonitor")
	ScanForNPCs()
endEvent

Function SendParameterlessEvent(string eventName)
	int retries = 3
	While(retries > 0)
		int eventId = ModEvent.Create(eventName)
		If eventId
			If(ModEvent.Send(eventId) == true)
				retries = 0
			Else
				Utility.WaitMenuMode(0.05)
				retries -= 1
			EndIf
		Else
			Utility.WaitMenuMode(0.05)
			retries -= 1
		EndIf
	EndWhile
EndFunction