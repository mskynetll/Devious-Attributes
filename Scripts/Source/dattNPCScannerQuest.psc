Scriptname dattNPCScannerQuest extends dattQuestBase

dattMutex Property Mutex Auto
Faction Property CurrentFollowerFaction Auto
GlobalVariable Property PlayerFollowerCount Auto
Actor Property PlayerRef Auto
Spell Property RapeTraumaAbility Auto
Faction Property dattRapeTraumaFaction Auto

Function Maintenance()
	RegisterForModEvent("Datt_PlayerCellChange","OnPlayerCellChange")
	RegisterForModEvent("Datt_CancellationRequest","OnCancellationRequest")	
EndFunction

Function OnNPCDetected(Actor npc)	
	If !npc.HasSpell(RapeTraumaAbility)
		npc.AddSpell(RapeTraumaAbility, false)
	EndIf
	Form npcAsForm = npc as Form
	;adjust rape trauma, because if we meet NPC that had rape trauma some time ago,
	;this will ajust the trauma stage accordingly
	dattPeriodicEventsHelper.AdjustTrauma("Rape",npc,dattRapeTraumaFaction)
	Log("dattNPCScannerQuest -> " + npc.GetBaseObject().GetName() + " detected, adding to tracking")
	StorageUtil.FormListAdd(None, "_datt_tracked_npcs",npcAsForm, false)	

	If StorageUtil.GetIntValue(npcAsForm, "_datt_was_detected", 0) == 0
		StorageUtil.SetIntValue(npcAsForm, "_datt_was_detected", 1)
		dattUtility.SendEventWithFormParam("Datt_SetDefaults",npcAsForm)	
	EndIf
EndFunction

Function OnNPCTooFar(Actor npc)	
	If npc.HasSpell(RapeTraumaAbility)
		npc.RemoveSpell(RapeTraumaAbility)
	EndIf
	Log("dattNPCScannerQuest -> " + npc.GetBaseObject().GetName() + " is too far, removing from tracking")
	StorageUtil.FormListRemove(None, "_datt_tracked_npcs",npc as Form)	
EndFunction

Event OnPlayerCellChange(Form newCell)	
	Log("dattNPCScannerQuest -> OnPlayerCellChange")	
	dattUtility.SendParameterlessEvent("Datt_ForceNPCScan")
EndEvent
