Scriptname dattNPCScannerQuest extends dattQuestBase

dattMutex Property Mutex Auto
Faction Property CurrentFollowerFaction Auto
GlobalVariable Property PlayerFollowerCount Auto
Actor Property PlayerRef Auto

Bool Property IsCancellationRequested Auto Hidden

Function Maintenance()
	RegisterForModEvent("Datt_PlayerCellChange","OnPlayerCellChange")
	RegisterForModEvent("Datt_CancellationRequest","OnCancellationRequest")	
EndFunction

Function OnNPCDetected(Actor npc)	
	StorageUtil.FormListAdd(None, "_datt_tracked_npcs",npc as Form, false)	
EndFunction

Function OnNPCTooFar(Actor npc)	
	StorageUtil.FormListRemove(None, "_datt_tracked_npcs",npc as Form)	
EndFunction

Event OnCancellationRequest()
	IsCancellationRequested = true
EndEvent

Event OnPlayerCellChange(Form newCell)	
	Log("[Datt] dattNPCScannerQuest -> OnPlayerCellChange")	
	dattUtility.SendParameterlessEvent("Datt_ForceNPCScan")
EndEvent

