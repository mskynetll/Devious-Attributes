Scriptname dattAttributeTrackerQuest Extends dattQuestBase

dattMutex Property Mutex Auto

Faction Property dattWillpower Auto
Faction Property dattPride Auto
Faction Property dattSelfEsteem Auto
Faction Property dattObedience Auto
Faction Property dattSubmissive Auto

Faction Property dattSadist Auto
Faction Property dattMasochist Auto
Faction Property dattNympho Auto
Faction Property dattHumiliationLover Auto
Faction Property dattExhibitionist Auto

Faction Property dattSoulState Auto

Bool Property HasQueuedChanges Auto Hidden

Function Maintenance()
	RegisterForModEvent("Datt_SetAttribute", "OnSetAttribute")
	RegisterForModEvent("Datt_ModAttribute", "OnModAttribute")
	RegisterForModEvent("Datt_SetDefaults", "OnSetDefaults")
	RegisterForModEvent("Datt_SetSoulState", "OnSetSoulState")
	RegisterForModEvent("Datt_ClearChangeQueue", "OnClearChangeQueue")
	;RegisterForSingleUpdate(15)
EndFunction

Event OnSetSoulState(Form acTargetActor, int value)
	Actor acActor = acTargetActor as Actor
	If acTargetActor == None || acActor == None
		Error("OnSetSoulState() was passed a form parameter, thats was empty or not an actor. Aborting change... ")
		Return
	EndIf
	string attributeId = "_Datt_Soul_State"

	;If Mutex.TryLock() == false
	;	QueueForChange(acTargetActor,attributeId,value, 0)
	;	return
	;EndIf

	Log("OnSetSoulState() for actor = " + (acTargetActor as Actor).GetBaseObject().GetName() +", attributeId = " + attributeId + ", value = " + value)	
	Faction attributeFaction = dattSoulState
	
	acActor.AddToFaction(attributeFaction) ;if actor already there this does nothing
	acActor.SetFactionRank(attributeFaction, value)
	StorageUtil.SetIntValue(acTargetActor, attributeId, value)
	int soulStateChangedEventId = ModEvent.Create("Datt_SoulStateChanged")
	If(soulStateChangedEventId)
  		ModEvent.PushForm(soulStateChangedEventId, acActor)
  		ModEvent.PushInt(soulStateChangedEventId, value)
 		If ModEvent.Send(soulStateChangedEventId) == false
	  		Warning("OnSetSoulState() failed to send event. EventName = Datt_SoulStateChanged")
	  		Debug.MessageBox("OnSetSoulState() failed to send event. EventName = Datt_SoulStateChanged")
	 	EndIf
	EndIf
	;Mutex.Unlock()
EndEvent

Event OnSetAttribute(Form acTargetActor, string attributeId, int value)
	Actor acActor = acTargetActor as Actor
	If acTargetActor == None || acActor == None
		Error("OnSetAttribute() was passed a form parameter, thats was empty or not an actor. Aborting change... ")
		Return
	EndIf

	;If Mutex.TryLock() == false
	;	QueueForChange(acTargetActor,attributeId,value, 0)
	;	return
	;EndIf

	Log("OnSetAttribute() for actor = " + (acTargetActor as Actor).GetBaseObject().GetName() +", attributeId = " + attributeId + ", value = " + value)	
	Faction attributeFaction = FactionByAttributeId(attributeId)
	If attributeFaction == None
		Return
	EndIf	

	acActor.AddToFaction(attributeFaction) ;if actor already there this does nothing	
	If value >= Config.MaxAttributeValue ;already at max value, nothing to do
		acActor.SetFactionRank(attributeFaction, Config.MaxAttributeValue)
		StorageUtil.SetIntValue(acTargetActor, attributeId, Config.MaxAttributeValue)
		Log("OnSetAttribute() for actor = " + (acTargetActor as Actor).GetBaseObject().GetName() +", attributeId = " + attributeId + ",	nothing to do - reached max value")
		return
	EndIf

	acActor.SetFactionRank(attributeFaction, value)
	StorageUtil.SetIntValue(acTargetActor, attributeId, value)
	NotifyOfChange("Datt_AttributeChanged",acTargetActor,attributeId,value)

	;Mutex.Unlock()
EndEvent

Event OnModAttribute(Form acTargetActor, string attributeId, int value)
	Actor acActor = acTargetActor as Actor
	If acTargetActor == None || acActor == None
		Error("OnModAttribute() was passed a form parameter, thats was empty or not an actor. Aborting change... ")
		Return
	EndIf

	;If Mutex.TryLock() == false
	;	QueueForChange(acTargetActor,attributeId, value, 1)
	;	return
	;EndIf

	Log("OnModAttribute() for actor = " + (acTargetActor as Actor).GetBaseObject().GetName() +", attributeId = " + attributeId + ", value = " + value)	
	Faction attributeFaction = FactionByAttributeId(attributeId)
	If attributeFaction == None
		Return ;loggin about this will happen in FactionByAttributeId()
	EndIf	

	acActor.AddToFaction(attributeFaction) ;if actor already in the faction this does nothing

	int newValue = StorageUtil.GetIntValue(acTargetActor, attributeId) + value
	If newValue > Config.MaxAttributeValue
		acActor.SetFactionRank(attributeFaction, 100)	
		StorageUtil.SetIntValue(acTargetActor, attributeId, 100)
		NotifyOfChange("Datt_AttributeChanged",acTargetActor,attributeId,100)
		return
	EndIf

	acActor.ModFactionRank(attributeFaction, value)	
	StorageUtil.AdjustIntValue(acTargetActor, attributeId, value)
	NotifyOfChange("Datt_AttributeChanged",acTargetActor,attributeId,newValue)

	;Mutex.Unlock()
EndEvent

Event OnSetDefaults(Form acTargetActor)
	Actor acActor = acTargetActor as Actor
	If acTargetActor == None || acActor == None
		Error("OnSetAttribute() was passed a form parameter, thats was empty or not an actor. Aborting change... ")
		Return
	EndIf
	
	OnSetAttribute(acActor, Config.PrideAttributeId, 100)
	OnSetAttribute(acActor, Config.SelfEsteemAttributeId, 100)
	OnSetAttribute(acActor, Config.WillpowerAttributeId, 100)
	OnSetAttribute(acActor, Config.ObedienceAttributeId, 0)
	OnSetAttribute(acActor, Config.SubmissivenessAttributeId, 0)

	OnSetAttribute(acActor, Config.HumiliationLoverAttributeId,0)
	OnSetAttribute(acActor, Config.MasochistAttributeId,0)
	OnSetAttribute(acActor, Config.ExhibitionistAttributeId, 0)
	OnSetAttribute(acActor, Config.NymphomaniacAttributeId, 0)
	OnSetAttribute(acActor, Config.SadistAttributeId, 0)
EndEvent

Function QueueForChange(Form akActor, string attributeId, int newValue,int isMod)
	MiscUtil.PrintConsole("QueueForChange -> " + (akActor as Actor).GetBaseObject().GetName() + ", " + attributeId + ":" + newValue)
	StorageUtil.StringListAdd(akActor, "_datt_queued_attributeId", attributeId)
	StorageUtil.IntListAdd(akActor, "_datt_queued_value", newValue)
	StorageUtil.IntListAdd(akActor, "_datt_queued_isMod", isMod)
	StorageUtil.FormListAdd(None, "_datt_queued_actors", akActor)
	HasQueuedChanges = true
EndFunction

Event OnClearChangeQueue()
	If Mutex.TryLock() == false
		string msg = "OnClearChangeQueue -> Failed to acquire lock in 15 seconds...aborting"
		Debug.Notification(msg)
		Warning(msg)
		return
	EndIf
	int actorsInChangeQueue = StorageUtil.FormListCount(None, "_datt_queued_actors")
	int index = 0

	While index < actorsInChangeQueue
		Form akActor = StorageUtil.FormListPop(None, "_datt_queued_actors")
		StorageUtil.StringListClear(akActor, "_datt_queued_attributeId")
		StorageUtil.IntListClear(akActor, "_datt_queued_value")
		StorageUtil.IntListClear(akActor, "_datt_queued_isMod")
		index += 1
	EndWhile
	
	HasQueuedChanges = false
	Mutex.Unlock()	
EndEvent

Event OnUpdate()
	If HasQueuedChanges == false
		Return ;if nothing to do, or we are busy, we can process this some other time
	EndIf

	int actorsCount = StorageUtil.FormListCount(None, "_datt_queued_actors")
	int actorIndex = 0
	Log("OnUpdate of attribute tracker. Processing " + actorsCount + " actor changes...")
	While actorIndex < actorsCount
		int changeIndex = 0
		Form currentActor = StorageUtil.FormListGet(None, "_datt_queued_actors",actorIndex)
		int changeCount = StorageUtil.StringListCount(currentActor, "_datt_queued_attributeId")
		While changeIndex < changeCount
			string attributeId = StorageUtil.StringListGet(currentActor, "_datt_queued_attributeId", changeIndex)
			int value = StorageUtil.IntListGet(currentActor, "_datt_queued_value", changeIndex)
			If(StorageUtil.IntListGet(currentActor, "_datt_queued_isMod", changeIndex) == 1)
				OnModAttribute(currentActor, attributeId, value)
			Else
				OnSetAttribute(currentActor, attributeId, value)
			EndIf
			StorageUtil.StringListRemoveAt(currentActor, "_datt_queued_attributeId", changeIndex)
			StorageUtil.IntListRemoveAt(currentActor, "_datt_queued_value", changeIndex)
			StorageUtil.IntListRemoveAt(currentActor, "_datt_queued_isMod", changeIndex)

			changeIndex += 1
		EndWhile
		StorageUtil.IntListRemoveAt(None, "_datt_queued_actors", actorIndex)
		actorIndex += 1
	EndWhile

	HasQueuedChanges = false
	RegisterForSingleUpdate(15)
	Log("OnUpdate of attribute tracker. Done processing...")
EndEvent

Function NotifyOfChange(string eventName, Form akActor, string attributeId, int value)
	int eventId = ModEvent.Create(eventName)
	If (eventId)
	  ModEvent.PushForm(eventId, akActor) 
	  ModEvent.PushString(eventId, attributeId)
	  ModEvent.PushInt(eventId, value)
	  If ModEvent.Send(eventId) == false
	  	Warning("NotifyOfChange() failed to send event. EventName = " + eventName)
	  	Debug.MessageBox("NotifyOfChange() failed to send event. EventName = " + eventName)
	  EndIf
	EndIf	
EndFunction

Faction Function FactionByAttributeId(string attributeId)
	If attributeId == Config.WillpowerAttributeId
		return dattWillpower
	EndIf

	If attributeId == Config.PrideAttributeId
		return dattPride
	EndIf

	If attributeId == Config.SelfEsteemAttributeId
		return dattSelfEsteem
	EndIf

	If attributeId == Config.ObedienceAttributeId
		return dattObedience
	EndIf

	If attributeId == Config.HumiliationLoverAttributeId
		return dattHumiliationLover
	EndIf

	If attributeId == Config.ExhibitionistAttributeId
		return dattExhibitionist
	EndIf

	If attributeId == Config.MasochistAttributeId
		return dattMasochist
	EndIf

	If attributeId == Config.SadistAttributeId
		return dattSadist
	EndIf

	If attributeId == Config.NymphomaniacAttributeId
		return dattNympho
	EndIf

	If attributeId == Config.SoulStateAttributeId
		return dattSoulState
	EndIf

	If attributeId == config.SubmissivenessAttributeId
		return dattSubmissive
	EndIf

	Warning("Couldn't find proper attribute faction, got attributeId = " + attributeId)

	return None
EndFunction
