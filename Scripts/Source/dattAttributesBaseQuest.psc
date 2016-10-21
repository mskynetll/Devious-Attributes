Scriptname dattAttributesBaseQuest Extends dattQuestBase Hidden
; This script contains some basic functions in order to handle attributes.

; TODO put them into skyui config
String Property BaseAttributeNameList = "datt_BaseAttributeList" Auto
String Property FetishAttributeNameList = "datt_FetishAttributeList" Auto
String Property StateAttributeNameList = "datt_StateAttributeList" Auto

; TODO add support for fetish attributes
Event datt_registerBaseAttribute(bool is_fetish_attribute, dattAttribute attribute)
	If attribute
		String m_name = attribute.AttributeName
		If m_name
			If StringListHas(none, "datt_BaseAttributeList", m_name)
				Warning("datt_registerBaseAttribute() attribute " + m_name + " already registered...")
			Else
				StringListAdd(none, "datt_BaseAttributeList", m_name, false)
			EndIf
			SetFormValue(none, "datt_" + m_name, attribute)
		Else
			Error("datt_registerBaseAttribute() attribute name is not defined...")
		EndIf
	Else
		Error("datt_registerBaseAttribute() attribute is none...")
	EndIf
EndEvent

; TODO
Event datt_registerStateAttribute(dattAttributeState attribute)
	If attribute
		int m_attribute_index = 0
		int m_attribute_count = StateAttributeList
		dattAttribute[] m_attribute_list = CreateFormArray(StateAttributeList.Length + 1)
		While m_attribute_index < m_attribute_count
			m_attribute_list[m_attribute_index] = StateAttributeList[m_attribute_index]
			m_attribute_index++
		EndWhile
		StateAttributeList = m_attribute_list
		StateAttributeList[StateAttributeList.Length - 1) = attribute
		
		
		m_attribute_index = 0
		String m_attribute_name_list = CreateStringArray(StateAttributeList.Length + 1)
		While m_attribute_index < m_attribute_count
			m_attribute_name_list[m_attribute_index] = StateAttributeNameList[m_attribute_index]
			m_attribute_index++
		EndWhile
		
		StateAttributeNameList = m_attribute_name_list
		StateAttributeNameList[StateAttributeNameList.Length - 1) = attribute.AttributeName
		Log("datt_registerBaseAttribute registered state attribute " + attribute.AttributeName + " as " + StateAttributeList.Length + "th attribute")
	Else
		Error("datt_registerBaseAttribute() attribute is none...")
	EndIf
EndEvent


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
; Legacy String Convertion
; ==============================

; Converts a legacy attribute string into a new one.
; If none was found, it returns the passed string
String Function ConvertFromLegacyAttribute(String attribute_string)
	; Nymphomania
	If attribute_string == Config.NymphomaniaLegacyAttributeId
		return Config.NymphomaniaAttributeId
	; Masochism
	ElseIf attribute_string == Config.MasochismLegacyAttributeId
		return Config.MasochismAttributeId
	; Sadism
	ElseIf attribute_string == Config.SadismLegacyAttributeId
		return Config.SadismAttributeId
	; Humiliation
	ElseIf attribute_string == Config.HumiliationLegacyAttributeId
		return Config.HumiliationAttributeId
	; Exhibitionism
	ElseIf attribute_string == Config.ExhibitionismLegacyAttributeId
		return Config.ExhibitionismAttributeId
	Else
		return attribute_string
	EndIf
EndFunction

; Converts a new attribute string into a legacy one.
; If none was found, it returns the passed string
String Function ConvertToLegacyAttribute(String attribute_string)
	; Nymphomania
	If attribute_string == Config.NymphomaniaAttributeId
		return Config.NymphomaniaLegacyAttributeId
	; Masochism
	ElseIf attribute_string == Config.MasochismAttributeId
		return Config.MasochismLegacyAttributeId
	; Sadism
	ElseIf attribute_string == Config.SadismAttributeId
		return Config.SadismLegacyAttributeId
	; Humiliation
	ElseIf attribute_string == Config.HumiliationAttributeId
		return Config.HumiliationLegacyAttributeId
	; Exhibitionism
	ElseIf attribute_string == Config.ExhibitionismAttributeId
		return Config.ExhibitionismLegacyAttributeId
	Else
		return attribute_string
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
	If attribute_string == Config.SoulStateAttributeId
	;|| attribute_string == Config.RapeTraumaAttributeID
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
	If attribute_faction == Config.SoulStateAttributeFaction
	;|| attribute_faction == Config.RapeTraumaAttributeFaction
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
		Warning("FactionByAttributeId() could not find attribute faction for attribute_string = " + attribute_string + ".")
		return None
	EndIf
EndFunction



; ==============================
; Sanity Checks
; ==============================

; Verifies if the inputted attribute string is registered as an attribute
bool Function VerifyAttributeId(String attribute_string)
	; Misc Attributes
	;If attribute_string == Config.SoulStateAttributeId
	If attribute_string == Config.SoulStateAttributeId
		return true
	;ElseIf attribute_string == Config.RapeTraumaAttributeId
	;	return true
	
	; Base Attributes
	ElseIf attribute_string == Config.WillpowerAttributeId
		return true
	ElseIf attribute_string == Config.PrideAttributeId
		return true
	ElseIf attribute_string == Config.SelfEsteemAttributeId
		return true
	ElseIf attribute_string == Config.ObedienceAttributeId
		return true
	ElseIf attribute_string == Config.SubmissivenessAttributeId
		return true
	
	; Fetish Attributes
	ElseIf attribute_string == Config.NymphomaniaAttributeId || attribute_string == Config.NymphomaniaLegacyAttributeId
		return true
	ElseIf attribute_string == Config.MasochismAttributeId || attribute_string == Config.MasochismLegacyAttributeId
		return true
	ElseIf attribute_string == Config.SadismAttributeId || attribute_string == Config.SadismLegacyAttributeId
		return true
	ElseIf attribute_string == Config.HumiliationAttributeId || attribute_string == Config.HumiliationLegacyAttributeId
		return true
	ElseIf attribute_string == Config.ExhibitionismAttributeId || attribute_string == Config.ExhibitionismLegacyAttributeId
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
	
	; Convert legacy as well as updated attribute strings
	String m_attribute_string_new = ConvertFromLegacyAttribute(attribute_string)
	String m_attribute_string_legacy = ConvertToLegacyAttribute(attribute_string)
	
	If !StorageUtil.HasIntValue(target_actor, m_attribute_string_new) && !StorageUtil.HasIntValue(target_actor, m_attribute_string_legacy)
		If set_defaults_on_missing
			Int m_attribute_default_value = GetDefaultAttributeValue(m_attribute_string_new)
			Log("CheckAttributeExistence() attribute \"" + m_attribute_string_new + "\" not set for actor \"" + target_actor.GetBaseObject().GetName() + "\". Set to default values of " + m_attribute_default_value + "...")
			
			Faction m_attribute_faction = FactionByAttributeId(m_attribute_string_new)
			If m_attribute_faction == None
				Warning("CheckAttributeExistence() could not find corresponding faction for passed attribute. Aborting...")
				Return -1
			EndIf
			target_actor.SetFactionRank(m_attribute_faction, m_attribute_default_value)
			StorageUtil.SetIntValue(target_actor, m_attribute_string_new, m_attribute_default_value)
			; If a legacy attribute was found, save it's value as well
			; To ensure compability with older mods, also limit it's value to the old version
			If m_attribute_string_new != m_attribute_string_legacy
				StorageUtil.SetIntValue(target_actor, m_attribute_string_legacy, dattUtility.LimitValueInt(m_attribute_default_value, 0, 100))
			EndIf
			
			; Attribute State
			Int m_new_state_value = GetAttributeStateOfValue(m_attribute_string_new, m_attribute_default_value)
			If m_new_state_value != StorageUtil.GetIntValue(target_actor, m_attribute_string_new + "_State")
				StorageUtil.SetIntValue(target_actor, m_attribute_string_new + "_State", m_new_state_value)
				NotifyOfChange(target_actor, m_attribute_string_new, m_new_state_value)
			EndIf
			
			;RecalculateSubmissivenessIfNeededOnAttributeChange(target_actor, m_attribute_faction)
			Return 0
		Else
			Return -1
		EndIf
	Else
		Return 1
	EndIf
EndFunction
