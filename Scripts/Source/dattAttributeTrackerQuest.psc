Scriptname dattAttributeTrackerQuest Extends dattAttributesAPIQuest

;dattMutex Property Mutex Auto

Bool Property HasQueuedChanges Auto Hidden

Function Maintenance()
	RegisterForModEvent("Datt_SetAttribute", "OnSetAttribute")
	RegisterForModEvent("Datt_ModAttribute", "OnModAttribute")
	RegisterForModEvent("Datt_SetDefaults", "OnSetDefaults")
	RegisterForModEvent("Datt_SetSoulState", "OnSetSoulState")
	RegisterForModEvent("Datt_ClearChangeQueue", "OnClearChangeQueue")
	;RegisterForSingleUpdate(15)
EndFunction

; Shorthand event for modifying souls state.
Event OnSetSoulState(Form target_actor_form, Int soul_state_value)
	ChangeAttribute(target_actor_form as Actor, Config.SoulStateAttributeId, soul_state_value)
EndEvent

; Event to set an attribute to a specific value.
Event OnSetAttribute(Form target_actor_form, String attributeId, Int attribute_value)
	ChangeAttribute(target_actor_form as Actor, attributeId, attribute_value)
EndEvent

; Event to modify an attribute.
; It uses the same function as OnSetAttribute event as it will deliver the same result
Event OnModAttribute(Form target_actor_form, String attributeId, Int attribute_value)
	ChangeAttribute(target_actor_form as Actor, attributeID, attribute_value, true)
EndEvent

; Event to reset all attributes to default.
Event OnSetDefaults(Form target_actor_form)
	SetDefaults(target_actor_form as Actor)
EndEvent



; ==============================
; Legacy Functions
; ==============================

; Event OnClearChangeQueue()
	; If Mutex.TryLock() == false
		; String msg = "OnClearChangeQueue -> Failed to acquire lock in 15 seconds...aborting"
		; Debug.Notification(msg)
		; Warning(msg)
		; return
	; EndIf
	; Int actorsInChangeQueue = StorageUtil.FormListCount(None, "_datt_queued_actors")
	; Int index = 0

	; While index < actorsInChangeQueue
		; Form akActor = StorageUtil.FormListPop(None, "_datt_queued_actors")
		; StorageUtil.StringListClear(akActor, "_datt_queued_attributeId")
		; StorageUtil.IntListClear(akActor, "_datt_queued_value")
		; StorageUtil.IntListClear(akActor, "_datt_queued_isMod")
		; index += 1
	; EndWhile
	
	; HasQueuedChanges = false
	; Mutex.Unlock()
; EndEvent

; Event OnUpdate()
	; If HasQueuedChanges == false
		; Return ;if nothing to do, or we are busy, we can process this some other time
	; EndIf

	; Int actorsCount = StorageUtil.FormListCount(None, "_datt_queued_actors")
	; Int actorIndex = 0
	; Log("OnUpdate of attribute tracker. Processing " + actorsCount + " actor changes...")
	; While actorIndex < actorsCount
		; Int changeIndex = 0
		; Form currentActor = StorageUtil.FormListGet(None, "_datt_queued_actors",actorIndex)
		; Int changeCount = StorageUtil.StringListCount(currentActor, "_datt_queued_attributeId")
		; While changeIndex < changeCount
			; String attributeId = StorageUtil.StringListGet(currentActor, "_datt_queued_attributeId", changeIndex)
			; Int value = StorageUtil.IntListGet(currentActor, "_datt_queued_value", changeIndex)
			; If(StorageUtil.IntListGet(currentActor, "_datt_queued_isMod", changeIndex) == 1)
				; OnModAttribute(currentActor, attributeId, value)
			; Else
				; OnSetAttribute(currentActor, attributeId, value)
			; EndIf
			; StorageUtil.StringListRemoveAt(currentActor, "_datt_queued_attributeId", changeIndex)
			; StorageUtil.IntListRemoveAt(currentActor, "_datt_queued_value", changeIndex)
			; StorageUtil.IntListRemoveAt(currentActor, "_datt_queued_isMod", changeIndex)

			; changeIndex += 1
		; EndWhile
		; StorageUtil.IntListRemoveAt(None, "_datt_queued_actors", actorIndex)
		; actorIndex += 1
	; EndWhile

	; HasQueuedChanges = false
	; RegisterForSingleUpdate(15)
	; Log("OnUpdate of attribute tracker. Done processing...")
; EndEvent
