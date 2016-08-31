Scriptname dattAttributesAPIQuest Extends dattAttributesBaseQuest

; Returns the current value for the given attribute.
; Returns either 0, or the passed in value if there is an error.
; If actor is not part of the faction, it either returns 0 or add him to the faction and return default values.
; It also automatically sets the value if it exceedes min/max limits.
Int Function GetAttribute(Actor target_actor, String attribute_string, bool set_defaults_on_missing = true, Int on_error_value = 0)
	If target_actor == None
		Warning("GetAttribute() received null actor reference. Return on_error_value of " + on_error_value + "...")
		Return on_error_value
	EndIf
	
	; I hate magic strings, so check validity
	If !VerifyAttributeId(attribute_string)
		Warning("GetAttribute() received invalid attribute_string \"" + attribute_string + "\". Return on_error_value of " + on_error_value + "...")
		Return on_error_value
	EndIf
	
	; Convert legacy as well as updated attribute strings
	String m_attribute_string_new = ConvertFromLegacyAttribute(attribute_string)
	String m_attribute_string_legacy = ConvertToLegacyAttribute(attribute_string)
	
	Faction m_attribute_faction = FactionByAttributeId(m_attribute_string_new)
	If m_attribute_faction == None
		Warning("GetAttribute() could not find corresponding faction for passed attribute. Return on_error_value of " + on_error_value + "...")
		Return on_error_value
	EndIf
	
	; Check if the attribute has already been set for the actor and eventually initialize it if needed
	If CheckAttributeExistence(target_actor, m_attribute_string_new, set_defaults_on_missing) == -1
		Warning("GetAttribute() attribute \"" + m_attribute_string_new + "\" not set for actor \"" + target_actor.GetBaseObject().GetName() + "\". Return on_error_value = " + on_error_value + "...")
		Return on_error_value
	EndIf
	
	; Change attribute value if it somehow does exceed the min/max limits and fire events for statchanges
	Int m_attribute_value = target_actor.GetFactionRank(m_attribute_faction)
	Int m_attribute_value_new = dattUtility.LimitValueInt(m_attribute_value, GetMinAttributeValue(m_attribute_string_new, target_actor), GetMaxBaseAttributeValue(m_attribute_string_new, target_actor))
	
	; check if value did exceed min/max limits... save and return the new value instead
	If m_attribute_value != m_attribute_value_new
		Log("GetAttribute() attribute \"" + m_attribute_string_new + "\" exceeding the limits for actor \"" + target_actor.GetBaseObject().GetName() + "\". Set value to " + m_attribute_value_new + "...")
		target_actor.SetFactionRank(m_attribute_faction, m_attribute_value_new)
		StorageUtil.SetIntValue(target_actor, m_attribute_string_new, m_attribute_value_new)
		; If a legacy attribute was found, save it's value as well
		; To ensure compability with older mods, also limit it's value to the old version
		If m_attribute_string_new != m_attribute_string_legacy
			StorageUtil.SetIntValue(target_actor, m_attribute_string_legacy, dattUtility.LimitValueInt(m_attribute_default_value, 0, 100))
		EndIf
		RecalculateSubmissivenessIfNeededOnAttributeChange(target_actor, m_attribute_faction)
		
		; Calculate and save attribute state if a misc attribute
		If !IsMiscAttribute(m_attribute_string_new)
			Int m_attribute_state_new = GetAttributeStateOfValue(m_attribute_string_new, m_attribute_value_new)
			If m_attribute_state_new != StorageUtil.GetIntValue(target_actor, m_attribute_string_new + "_State")
				StorageUtil.SetIntValue(target_actor, m_attribute_string_new + "_State", m_attribute_state_new)
				NotifyOfChange(target_actor, m_attribute_string_new, m_attribute_state_new)
			EndIf
			return m_attribute_value_new
		EndIf
	Else
		Return m_attribute_value
	EndIf
EndFunction

; Returns the state of the passed attribute
Int Function GetAttributeState(Actor target_actor, String attribute_string, bool set_defaults_on_missing = true, Int on_error_value = 0)
	return GetAttributeStateOfValue(attribute_string, GetAttribute(target_actor, attribute_string, set_defaults_on_missing, on_error_value))
EndFunction

; Set the specified attribute to the passed value.
Function SetAttribute(Actor target_actor, String attribute_string, Int attribute_value)
	ChangeAttribute(target_actor, attribute_string, attribute_value)
EndFunction

; Modifies the specified attribute by the passed value.
Function ModAttribute(Actor target_actor, String attribute_string, Int attribute_value)
	ChangeAttribute(target_actor, attribute_string, attribute_value, true)
EndFunction

; Set the Soul State to the passed value.
Function SetSoulState(Actor target_actor, Int soul_state_value)
	ChangeAttribute(target_actor, Config.SoulStateAttributeId, soul_state_value)
EndFunction

; Set all attributes to defaults.
Function SetDefaults(Actor target_actor)
	If target_actor == None
		Error("SetDefaults() was passed a form parameter, that was empty or not an actor. Aborting change...")
		Return
	EndIf
	
	SetAttribute(target_actor, Config.WillpowerAttributeId, Config.MaxBaseAttributeValue)
	SetAttribute(target_actor, Config.PrideAttributeId, Config.MaxBaseAttributeValue)
	SetAttribute(target_actor, Config.SelfEsteemAttributeId, Config.MaxBaseAttributeValue)
	SetAttribute(target_actor, Config.ObedienceAttributeId, 0)
	SetAttribute(target_actor, Config.SubmissivenessAttributeId, 0)

	SetAttribute(target_actor, Config.NymphomaniaAttributeId, Config.NymphomaniaAttributeDefault)
	SetAttribute(target_actor, Config.MasochismAttributeId, Config.MasochismAttributeDefault)
	SetAttribute(target_actor, Config.SadismAttributeId, Config.SadismAttributeDefault)
	SetAttribute(target_actor, Config.HumiliationAttributeId, Config.HumiliationAttributeDefault)
	SetAttribute(target_actor, Config.ExhibitionismAttributeId, Config.ExhibitionismAttributeDefault)
EndFunction
