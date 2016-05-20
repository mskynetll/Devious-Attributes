Scriptname dattAttributesBaseQuest Extends dattQuestBase Hidden
; This script contains some basic functions in order to handle attributes.



; Changes the passed in Attribute
; If is_modify_mode set to false, it will set the attribute to the passed in attribute_value, otherwise it will add attribute_value to the current actor's stat
Function ChangeAttribute(Actor target_actor, String attribute_string, Int attribute_value, bool is_modify_mode = false)
	If target_actor == None
		Error("ChangeAttribute() was passed a form parameter, that was empty or not an actor. Aborting change...")
		Return
	EndIf
	
	If VerifyAttributeId(attribute_string) == false
		Error("ChangeAttribute() was passed an attribute \"" + attribute_string + "\" that does not exist. Aborting change...")
		Return
	EndIf
	
	;If Mutex.TryLock() == false
	;	QueueForChange(acActor as Form, attribute_string, attribute_value, 0)
	;	return
	;EndIf
	
	Log("ChangeAttribute() for actor = " + target_actor.GetBaseObject().GetName() +", attribute_string = " + attribute_string + ", value = " + attribute_value + ", is_modify_mode = " + is_modify_mode)
	Faction m_attribute_faction = FactionByAttributeId(attribute_string)
	If m_attribute_faction == None
		Error("ChangeAttribute() could not find corresponding faction for passed attribute.")
		Return
	EndIf
	
	; Initialize attribute if needed.
	CheckAttributeExistence(target_actor, attribute_string, true)
	Int m_old_attribute_value = target_actor.GetFactionRank(m_attribute_faction)
	Int m_max_attribute_value = getMaxBaseAttributeValue(attribute_string, target_actor)
	Int m_min_attribute_value = getMinAttributeValue(attribute_string, target_actor)
	
	; If in modify mode, add current actor value to attribute_value.
	; Make sure that the old actor value does not exceed the min/max values for that attribute.
	If is_modify_mode
		attribute_value += dattUtility.LimitValueInt(m_old_attribute_value, m_min_attribute_value, m_max_attribute_value)
	EndIf
	
	If attribute_value > m_max_attribute_value
		; Don't go higher than the max value for that attribute.
		attribute_value = m_max_attribute_value
		Log("ChangeAttribute() passed value of " + attribute_value + " is higher than max (" + m_max_attribute_value + "). Use max value instead...")
	ElseIf attribute_value < m_min_attribute_value
		; Don't go lower than the min value for that attribute.
		attribute_value = m_min_attribute_value
		Log("ChangeAttribute() passed value of " + attribute_value + " is lower than min (" + m_min_attribute_value + "). Use min value instead...")
	EndIf
	
	; Only do changes if the new value is different than the old one.
	If attribute_value != m_old_attribute_value
		target_actor.SetFactionRank(m_attribute_faction, attribute_value)
		StorageUtil.SetIntValue(target_actor, attribute_string, attribute_value)
		
		; If the attribute is not Soul State, set attribute state as well.
		If IsMiscAttribute(attribute_string)
			NotifyOfMiscChange(target_actor, attribute_value)
		Else
			NotifyOfChange(target_actor, attribute_string, attribute_value)
			
			; Attribute State
			Int m_new_state = GetAttributeStateOfValue(attribute_string, attribute_value)
			If m_new_state != StorageUtil.GetIntValue(target_actor, attribute_string + "_State")
				StorageUtil.SetIntValue(target_actor, attribute_string + "_State", m_new_state)
				NotifyOfChange(target_actor, attribute_string, m_new_state)
			EndIf
			
			RecalculateSubmissivenessIfNeededOnAttributeChange(target_actor, m_attribute_faction)
		EndIf
	EndIf
	;Mutex.Unlock()
EndFunction

; Recalculates submissiveness if pride, self esteem or obedience has changed
; If one of the attributes are missing, it reinitialize them with default values.
Function RecalculateSubmissivenessIfNeededOnAttributeChange(Actor target_actor, Faction attribute_faction)
	If(attribute_faction == Config.PrideAttributeFaction || attribute_faction == Config.SelfEsteemAttributeFaction || attribute_faction == Config.ObedienceAttributeFaction)
		; m_pride_value
		String m_pride_string = Config.PrideAttributeId
		String m_selfesteem_string = Config.SelfEsteemAttributeId
		String m_obedience_string = Config.ObedienceAttributeId
		
		Int m_pride_value
		Int m_selfesteem_value
		Int m_obedience_value
		
		; Pride
		If !StorageUtil.HasIntValue(target_actor, m_pride_string)
			Int m_default_value = GetDefaultAttributeValue(m_pride_string)
			Log("RecalculateSubmissivenessIfNeededOnAttributeChange() attribute \"" + m_pride_string + "\" not set for actor \"" + target_actor.GetBaseObject().GetName() + "\". Set to m_default_value values of " + m_default_value + "...")
			target_actor.SetFactionRank(Config.PrideAttributeFaction, m_default_value)
			StorageUtil.SetIntValue(target_actor, m_pride_string, m_default_value)
			m_pride_value = m_default_value
		Else
			m_pride_value = target_actor.GetFactionRank(Config.PrideAttributeFaction)
		EndIf
		
		; Self Esteem
		If StorageUtil.HasIntValue(target_actor, m_selfesteem_string)
			Int m_default_value = GetDefaultAttributeValue(m_selfesteem_string)
			Log("RecalculateSubmissivenessIfNeededOnAttributeChange() attribute \"" + m_selfesteem_string + "\" not set for actor \"" + target_actor.GetBaseObject().GetName() + "\". Set to m_default_value values of " + m_default_value + "...")
			target_actor.SetFactionRank(Config.SelfEsteemAttributeFaction, m_default_value)
			StorageUtil.SetIntValue(target_actor, m_selfesteem_string, m_default_value)
			m_selfesteem_value = m_default_value
		Else
			m_selfesteem_value = target_actor.GetFactionRank(Config.SelfEsteemAttributeFaction)
		EndIf
		
		; Obedience
		If StorageUtil.HasIntValue(target_actor, m_obedience_string)
			Int m_default_value = GetDefaultAttributeValue(m_obedience_string)
			Log("RecalculateSubmissivenessIfNeededOnAttributeChange() attribute \"" + m_obedience_string + "\" not set for actor \"" + target_actor.GetBaseObject().GetName() + "\". Set to m_default_value values of " + m_default_value + "...")
			target_actor.SetFactionRank(Config.ObedienceAttributeFaction, m_default_value)
			StorageUtil.SetIntValue(target_actor, m_obedience_string, m_default_value)
			m_obedience_value = m_default_value
		Else
			m_obedience_value = target_actor.GetFactionRank(Config.ObedienceAttributeFaction)
		EndIf
		Int m_submissiveness_value = dattUtility.MaxInt(100 - ((m_pride_value + m_selfesteem_value) / 2), m_obedience_value)
		
		target_actor.SetFactionRank(Config.SubmissiveAttributeFaction, m_submissiveness_value)
		StorageUtil.SetIntValue(target_actor, Config.SubmissivenessAttributeId, m_submissiveness_value)
	EndIf
EndFunction

; Function QueueForChange(Form akActor, String attributeId, Int newValue,Int isMod)
	; MiscUtil.PrintConsole("QueueForChange -> " + (akActor as Actor).GetBaseObject().GetName() + ", " + attributeId + ":" + newValue)
	; StorageUtil.StringListAdd(akActor, "_datt_queued_attributeId", attributeId)
	; StorageUtil.IntListAdd(akActor, "_datt_queued_value", newValue)
	; StorageUtil.IntListAdd(akActor, "_datt_queued_isMod", isMod)
	; StorageUtil.FormListAdd(None, "_datt_queued_actors", akActor)
	; HasQueuedChanges = true
; EndFunction

; Fires an event if an attribute has changed.
Function NotifyOfChange(Actor target_actor, String attribute_string, Int attribute_value, String event_name = "Datt_AttributeChanged")
	Int m_event_id = ModEvent.Create(event_name)
	If (m_event_id)
		ModEvent.PushForm(m_event_id, target_actor) 
		ModEvent.PushString(m_event_id, attribute_string)
		ModEvent.PushInt(m_event_id, attribute_value)
		If ModEvent.Send(m_event_id) == false
			Warning("NotifyOfChange() failed to send event. EventName = " + event_name)
			Debug.MessageBox("NotifyOfChange() failed to send event. EventName = " + event_name)
		EndIf
	EndIf
EndFunction

; Fires an event if the Soul State has changed.
; Currently only used to fire Soul State Changed Events.
; In the future it could also be used to fire changed events for attributes similiar to Soul State
Function NotifyOfMiscChange(Actor target_actor, Int attribute_value, String event_name = "Datt_SoulStateChanged")
	Int m_event_id = ModEvent.Create(event_name)
	If(m_event_id)
		ModEvent.PushForm(m_event_id, target_actor)
		ModEvent.PushInt(m_event_id, attribute_value)
		If ModEvent.Send(m_event_id) == false
			Warning("NotifyOfMiscChange() failed to send event. EventName = " + event_name)
			Debug.MessageBox("NotifyOfMiscChange() failed to send event. EventName = " + event_name)
		EndIf
	EndIf
EndFunction



; ==============================
; Get Attribute States
; ==============================
; TODO: Add support for possible traits

; Returns state of the attribute.
Int Function GetAttributeStateOfValue(String attribute_string, Int attribute_value)
	Int type = GetAttributeType(attribute_string)
	If type == 0		; Misc Attribute. Return passed value
		return attribute_value
	ElseIf type == 1	; Base Attribute
		return GetBaseAttributeStateOfValue(attribute_value)
	ElseIf type == 2	; Fetish Attribute
		return GetFetishAttributeStateOfValue(attribute_value)
	Else				; Unknown Attribute. Return 0
		return 0
	EndIf
EndFunction

; Returns the state of the base attribute.
; As for now, the value range for the states is hardcoded, thought that might change in the future
Int Function GetBaseAttributeStateOfValue(Int attribute_value)
	If attribute_value >= 80		; 100 to 80
		return 3
	ElseIf attribute_value >= 50	; 79 to 50
		return 2
	ElseIf attribute_value >= 20	;49 to 20
		return 1
	Else				;19 to 0
		return 0
	EndIf
EndFunction

; Returns the state of the fetish attribute.
; As for now, the value range for the states is hardcoded, thought that might change in the future
Int Function GetFetishAttributeStateOfValue(Int attribute_value)
	If attribute_value >= 80		; 100 to 80
		return 3
	ElseIf attribute_value >= 50	; 79 to 50
		return 2
	ElseIf attribute_value >= 20	;49 to 20
		return 1
	ElseIf attribute_value > -20	;19 to -19
		return 0
	ElseIf attribute_value > -50	;-20 to -49
		return -1
	ElseIf attribute_value > -80	;-50 to -79
		return -2
	Else				;-80 to -100
		return -3
	EndIf
EndFunction



; ==============================
; Get Attribute Type by Attribute ID
; ==============================

; Returns true if attribute is a misc attribute
Bool Function IsMiscAttribute(String attribute_string)
	If attribute_string == Config.SoulStateAttributeId ;|| attribute == Config.RapeTraumaAttributeID
		return true
	Else
		return false
	EndIf
EndFunction


; Returns true if attribute is a base attribute
Bool Function IsBaseAttribute(String attribute_string)
	If attribute_string == Config.WillpowerAttributeId || attribute_string == Config.PrideAttributeId || attribute_string == Config.SelfEsteemAttributeId || attribute_string == Config.ObedienceAttributeId || attribute_string == Config.SubmissivenessAttributeId
		return true
	Else
		return false
	EndIf
EndFunction

; Returns true if attribute is a fetish attribute
Bool Function IsFetishAttribute(String attribute_string)
	If attribute_string == Config.NymphomaniaAttributeId || attribute_string == Config.MasochismAttributeId || attribute_string == Config.SadismAttributeId || attribute_string == Config.HumiliationAttributeId || attribute_string == Config.ExhibitionismAttributeId
		return true
	Else
		return false
	EndIf
EndFunction

; Returns the type of the attribute as integer
; 0 if misc attribute (soul state)
; 1 if base attribute
; 2 if fetish attribute
; -1 if the attribute wasn't found
Int Function GetAttributeType(String attribute_string)
	If IsMiscAttribute(attribute_string)
		return 0
	ElseIf IsBaseAttribute(attribute_string)
		return 1
	ElseIf IsFetishAttribute(attribute_string)
		return 2
	Else
		return -1
	EndIf
EndFunction



; ==============================
; Get Attribute Type by Faction
; ==============================

; Returns true if faction is a misc faction
Bool Function IsMiscAttributeByFaction(Faction attribute_faction)
	If attribute_faction == Config.SoulStateAttributeFaction ;|| attribute == Config.RapeTraumaAttributeFaction
		return true
	Else
		return false
	EndIf
EndFunction

; Returns true if faction is a base faction
Bool Function IsBaseAttributeByFaction(Faction attribute_faction)
	If attribute_faction == Config.WillpowerAttributeFaction || attribute_faction == Config.PrideAttributeFaction || attribute_faction == Config.SelfEsteemAttributeFaction || attribute_faction == Config.ObedienceAttributeFaction || attribute_faction == Config.SubmissiveAttributeFaction
		return true
	Else
		return false
	EndIf
EndFunction

; Returns true if faction is a fetish faction
Bool Function IsFetishAttributeByFaction(Faction attribute_faction)
	If attribute_faction == Config.NymphomaniaAttributeFaction || attribute_faction == Config.MasochismAttributeFaction || attribute_faction == Config.SadismAttributeFaction || attribute_faction == Config.HumiliationAttributeFaction || attribute_faction == Config.ExhibitionismAttributeFaction
		return true
	Else
		return false
	EndIf
EndFunction

; Returns the type of the faction as integer
; 0 if misc faction (soul state)
; 1 if base faction
; 2 if fetish faction
; -1 if the faction wasn't found
Int Function GetAttributeTypeByFaction(Faction attribute_faction)
	If IsMiscAttributeByFaction(attribute_faction)
		return 0
	ElseIf IsBaseAttributeByFaction(attribute_faction)
		return 1
	ElseIf IsFetishAttributeByFaction(attribute_faction)
		return 2
	Else
		return -1
	EndIf
EndFunction



; ==============================
; Get Min and Max Attributes
; ==============================

; Returns the max value for that attribute.
; For now it only returns the max values defined in dattConfigQuest, but it can later be modified to include traits as well
Int Function GetMaxBaseAttributeValue(String attribute_string, Actor target_actor = None)
	Int attribute_value_max = 0
	
	; Misc Attributes
	; Soul State
	If attribute_string == Config.SoulStateAttributeId
		attribute_value_max = 2
	; Soul State
	;ElseIf attribute_string == Config.RapeTraumattributeId
	;	attribute_value_max = 0
	
	; Basic Attributes
	; Willpower
	ElseIf attribute_string == Config.WillpowerAttributeId
		attribute_value_max = Config.MaxBaseAttributeValue
		;If target_actor && hasTraits(target_actor, "HighWillpower")
		;	attribute_value_max += Config.TraitAttributeBonus
		;EndIf
	; Pride
	ElseIf attribute_string == Config.PrideAttributeId
		attribute_value_max = Config.MaxBaseAttributeValue
	; Self Esteem
	ElseIf attribute_string == Config.SelfEsteemAttributeId
		attribute_value_max = Config.MaxBaseAttributeValue
	; Obedience
	ElseIf attribute_string == Config.ObedienceAttributeId
		attribute_value_max = Config.MaxBaseAttributeValue
	; Submissiveness
	ElseIf attribute_string == Config.SubmissivenessAttributeId
		attribute_value_max = Config.MaxBaseAttributeValue
	
	; Fetish Attributes
	; Nymphomania
	ElseIf attribute_string == Config.NymphomaniaAttributeId
		attribute_value_max = Config.MaxFetishAttributeValue
	; Masochism
	ElseIf attribute_string == Config.MasochismAttributeId
		attribute_value_max = Config.MaxFetishAttributeValue
	; Sadism
	ElseIf attribute_string == Config.SadismAttributeId
		attribute_value_max = Config.MaxFetishAttributeValue
	; Exhibitionism
	ElseIf attribute_string == Config.ExhibitionismAttributeId
		attribute_value_max = Config.MaxFetishAttributeValue
	; Humiliation
	ElseIf attribute_string == Config.HumiliationAttributeId
		attribute_value_max = Config.MaxFetishAttributeValue
	EndIf
	
	return attribute_value_max
EndFunction

; Returns the min value for that attribute.
; For now it only returns the min values defined in dattConfigQuest, but it can later be modified to include traits as well (fetishes)
Int Function GetMinAttributeValue(String attribute_string, Actor target_actor = None)
	Int attribute_value_min = 0
	
	; Misc Attributes
	; Soul State
	If attribute_string == Config.SoulStateAttributeId
		attribute_value_min = 0
	; Rape Trauma
	;ElseIf attribute_string == Config.RapeTraumaAttributeId
	;	attribute_value_min = 0
	
	; Basic Attributes
	; Willpower
	ElseIf attribute_string == Config.WillpowerAttributeId
		attribute_value_min = 0
	; Pride
	ElseIf attribute_string == Config.PrideAttributeId
		attribute_value_min = 0
	; Self Esteem
	ElseIf attribute_string == Config.SelfEsteemAttributeId
		attribute_value_min = 0
	; Obedience
	ElseIf attribute_string == Config.ObedienceAttributeId
		attribute_value_min = 0
	; Submissiveness
	ElseIf attribute_string == Config.SubmissivenessAttributeId
		attribute_value_min = 0
	
	; Fetish Attributes
	; Nymphomania
	ElseIf attribute_string == Config.NymphomaniaAttributeId
		attribute_value_min = Config.MinFetishAttributeValue
	; Masochism
	ElseIf attribute_string == Config.MasochismAttributeId
		attribute_value_min = Config.MinFetishAttributeValue
	; Sadism
	ElseIf attribute_string == Config.SadismAttributeId
		attribute_value_min = Config.MinFetishAttributeValue
	; Humiliation
	ElseIf attribute_string == Config.HumiliationAttributeId
		attribute_value_min = Config.MinFetishAttributeValue
	; Exhibitionism
	ElseIf attribute_string == Config.ExhibitionismAttributeId
		attribute_value_min = Config.MinFetishAttributeValue
	EndIf
	
	return attribute_value_min
EndFunction

; Returns the default value for the passed in attribute
Int Function GetDefaultAttributeValue(String attribute_string)
	Int attribute_value_default = 0
	
	; Misc Attributes
	; Soul State
	If attribute_string == Config.SoulStateAttributeId
		attribute_value_default = 0
	; Rape Trauma
	;ElseIf attribute_string == Config.RapeTraumaAttributeId
	;	attribute_value_default = 0
	
	; Basic Attributes
	; Willpower
	ElseIf attribute_string == Config.WillpowerAttributeId
		attribute_value_default = Config.WillpowerAttributeDefault
	; Pride
	ElseIf attribute_string == Config.PrideAttributeId
		attribute_value_default = Config.PrideAttributeDefault
	; Self Esteem
	ElseIf attribute_string == Config.SelfEsteemAttributeId
		attribute_value_default = Config.SelfEsteemAttributeDefault
	; Obedience
	ElseIf attribute_string == Config.ObedienceAttributeId
		attribute_value_default = Config.ObedienceAttributeDefault
	; Submissiveness
	ElseIf attribute_string == Config.SubmissivenessAttributeId
		attribute_value_default = Config.SubmissivenessAttributeDefault
	
	; Fetish Attributes
	; Nymphomania
	ElseIf attribute_string == Config.NymphomaniaAttributeId
		attribute_value_default = Config.NymphomaniaAttributeDefault
	; Masochism
	ElseIf attribute_string == Config.MasochismAttributeId
		attribute_value_default = Config.MasochismAttributeDefault
	; Sadism
	ElseIf attribute_string == Config.SadismAttributeId
		attribute_value_default = Config.SadismAttributeDefault
	; Humiliation
	ElseIf attribute_string == Config.HumiliationAttributeId
		attribute_value_default = Config.HumiliationAttributeDefault
	; Exhibitionism
	ElseIf attribute_string == Config.ExhibitionismAttributeId
		attribute_value_default = Config.ExhibitionismAttributeDefault
	EndIf
	
	return attribute_value_default
EndFunction

; Returns the corresponding faction for the attributeID
Faction Function FactionByAttributeId(String attribute_string)
	; Misc Attributes
	; Soul State
	If attribute_string == Config.SoulStateAttributeId
		return Config.SoulStateAttributeFaction
	; Rape Trauma
	;ElseIf attribute_string == Config.RapeTraumaAttributeId
	;	return Config.RapeTraumaAttributeFaction
	
	; Base Attributes
	; Willpower
	ElseIf attribute_string == Config.WillpowerAttributeId
		return Config.WillpowerAttributeFaction
	; Pride
	ElseIf attribute_string == Config.PrideAttributeId
		return Config.PrideAttributeFaction
	; Self Esteem
	ElseIf attribute_string == Config.SelfEsteemAttributeId
		return Config.SelfEsteemAttributeFaction
	; Obedience
	ElseIf attribute_string == Config.ObedienceAttributeId
		return Config.ObedienceAttributeFaction
	; Submissiveness
	ElseIf attribute_string == config.SubmissivenessAttributeId
		return Config.SubmissiveAttributeFaction
	
	; Fetish Attributes
	; Nymphomania
	ElseIf attribute_string == Config.NymphomaniaAttributeId
		return Config.NymphomaniaAttributeFaction
	; Masochism
	ElseIf attribute_string == Config.MasochismAttributeId
		return Config.MasochismAttributeFaction
	; Sadism
	ElseIf attribute_string == Config.SadismAttributeId
		return Config.SadismAttributeFaction
	; Humiliation
	ElseIf attribute_string == Config.HumiliationAttributeId
		return Config.HumiliationAttributeFaction
	; Exhibitionism
	ElseIf attribute_string == Config.ExhibitionismAttributeId
		return Config.ExhibitionismAttributeFaction
	Else
		;Warning("FactionByAttributeId() could not find attribute faction for attribute_string = " + attribute_string + ".")
		return None
	EndIf
EndFunction



; ==============================
; Sanity Checks
; ==============================

; Verifies if the inputted attribute is an existing attribute
bool Function VerifyAttributeId(String attribute_string)
	; Misc Attributes
	If(attribute_string == Config.SoulStateAttributeId)
		return true
	;ElseIf(attribute_string == Config.RapeTraumaAttributeId)
	;	return true
	
	; Base Attributes
	ElseIf(attribute_string == Config.WillpowerAttributeId)
		return true
	ElseIf(attribute_string == Config.PrideAttributeId)
		return true
	ElseIf(attribute_string == Config.SelfEsteemAttributeId)
		return true
	ElseIf(attribute_string == Config.ObedienceAttributeId)
		return true
	ElseIf(attribute_string == Config.SubmissivenessAttributeId)
		return true
	
	; Fetish Attributes
	ElseIf(attribute_string == Config.NymphomaniaAttributeId)
		return true
	ElseIf(attribute_string == Config.MasochismAttributeId)
		return true
	ElseIf(attribute_string == Config.SadismAttributeId)
		return true
	ElseIf(attribute_string == Config.HumiliationAttributeId)
		return true
	ElseIf(attribute_string == Config.ExhibitionismAttributeId)
		return true
	Else
		return false
	EndIf
EndFunction

; Check if the attribute has been set to the actor.
; Optionally it can initialize the attribute
; returns -1 on error or if not existent
; returns 0 if no attribute was not found and had been set to defaults
; returns 1 if attribute has been found
Int Function CheckAttributeExistence(Actor target_actor, String attribute_string, bool set_defaults_on_missing = true)
	If !VerifyAttributeId(attribute_string)
		Warning("CheckAttributeExistence() received invalid attribute_string \"" + attribute_string + "\". Aborting...")
		Return -1
	EndIf
	
	If target_actor == None
		Warning("CheckAttributeExistence() received null actor reference. Aborting...")
		Return -1
	EndIf
	
	If !StorageUtil.HasIntValue(target_actor, attribute_string)
		If set_defaults_on_missing
			Int m_attribute_default_value = GetDefaultAttributeValue(attribute_string)
			Log("CheckAttributeExistence() attribute \"" + attribute_string + "\" not set for actor \"" + target_actor.GetBaseObject().GetName() + "\". Set to default values of " + m_attribute_default_value + "...")
			
			Faction m_attribute_faction = FactionByAttributeId(attribute_string)
			If m_attribute_faction == None
				Warning("CheckAttributeExistence() could not find corresponding faction for passed attribute. Aborting...")
				Return -1
			EndIf
			target_actor.SetFactionRank(m_attribute_faction, m_attribute_default_value)
			StorageUtil.SetIntValue(target_actor, attribute_string, m_attribute_default_value)
			
			; Attribute State
			Int m_new_state_value = GetAttributeStateOfValue(attribute_string, m_attribute_default_value)
			If m_new_state_value != StorageUtil.GetIntValue(target_actor, attribute_string + "_State")
				StorageUtil.SetIntValue(target_actor, attribute_string + "_State", m_new_state_value)
				NotifyOfChange(target_actor, attribute_string, m_new_state_value)
			EndIf
			
			RecalculateSubmissivenessIfNeededOnAttributeChange(target_actor, m_attribute_faction)
			Return 0
		Else
			Return -1
		EndIf
	Else
		Return 1
	EndIf
EndFunction
