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
	RemoveFarAwayNPCs()
EndFunction

;precaution, this should not do any work, but in any case...
Function RemoveFarAwayNPCs()
	int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	int index = 0
    While index < npcCount        
        Actor npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index) as Actor
        If npc != None ;precaution
        	float distance = PlayerRef.GetDistance(npc)
            if distance >= 2048 || npc.IsDead()
            	Log("Maintenance -> " + npc.GetBaseObject().GetName() + " too far away or dead, distance = " + distance)
            	OnNPCTooFar(npc)
            Else
            	Log("Maintenance -> found " + npc.GetBaseObject().GetName() + " to have distance = " + distance)
            EndIf
        Else            
            Warning("Very weird, found non-actor in _datt_tracked_npcs list. This should be reported! (npc.GetName() ==" + npc.GetName() + ")")
            StorageUtil.FormListRemoveAt(None, "_datt_tracked_npcs", index)
        EndIf
        index += 1
    EndWhile
EndFunction

Function OnNPCDetected(Actor npc)	
	string npcName = npc.GetBaseObject().GetName()
	If npcName == ""
		npcName = "[Generic NPC]"
	EndIf

	If npc.IsDead()
		Log("dattNPCScannerQuest -> " + npcName + " detected, but is dead, ignoring")
		return
	EndIf

	If !npc.HasSpell(RapeTraumaAbility)
		npc.AddSpell(RapeTraumaAbility, false)
	EndIf
	Form npcAsForm = npc as Form
	;adjust rape trauma, because if we meet NPC that had rape trauma some time ago,
	;this will ajust the trauma stage accordingly
	dattPeriodicEventsHelper.AdjustTrauma("Rape",npc,dattRapeTraumaFaction)
	Log("dattNPCScannerQuest -> " + npcName + " detected, adding to tracking")

	RegisterForLOS(npc, PlayerRef)
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
	UnregisterForLOS(npc, PlayerRef)
	Log("dattNPCScannerQuest -> " + npc.GetBaseObject().GetName() + " is too far, removing from tracking")
	StorageUtil.FormListRemove(None, "_datt_tracked_npcs",npc as Form)	
EndFunction

Event OnPlayerCellChange(Form newCell)	
	Log("dattNPCScannerQuest -> OnPlayerCellChange")	
	dattUtility.SendParameterlessEvent("Datt_ForceNPCScan")
EndEvent

Event OnGainLOS(Actor akViewer, ObjectReference akTarget)	
	Log(akViewer.GetBaseObject().GetName() + " gained LOS to player")
	dattUtility.SendEventWithFormParam("Datt_LOSGainedToPlayer", akViewer as Form)
EndEvent

Event OnLostLOS(Actor akViewer, ObjectReference akTarget)
	Log(akViewer.GetBaseObject().GetName() + " lost LOS to player")
	dattUtility.SendEventWithFormParam("Datt_LOSLostToPlayer", akViewer as Form)
EndEvent