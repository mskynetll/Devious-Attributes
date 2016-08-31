Scriptname dattAttributesAPIQuest Extends dattAttributesBaseQuest

dattConfigQuest Property Config Auto
Int Property CurrentMutexId = 1 Auto
Int Property NewestMutexId = 0 Auto

Function OnInit()
	; New Events
	RegisterForModEvent(Config.ActorDecisionEventName1, "OnActorDecision1")
	RegisterForModEvent(Config.ActorDecisionEventName1, "OnActorDecision1")
	RegisterForModEvent(Config.ActorDecisionEventName1, "OnActorDecision1")
	RegisterForModEvent(Config.ActorDecisionEventName1, "OnActorDecision1")
	
	RegisterForModEvent(Config.ActorAffectedEventName1, "OnActorAffected1")
	RegisterForModEvent(Config.ActorAffectedEventName2, "OnActorAffected1")
	RegisterForModEvent(Config.ActorAffectedEventName3, "OnActorAffected1")
	RegisterForModEvent(Config.ActorAffectedEventName4, "OnActorAffected1")
	
	RegisterForModEvent(Config.ActorModAttributeEventName, "OnActorModAttribute")
	RegisterForModEvent(Config.ActorSetAttributeEventName, "OnActorSetAttribute")
	RegisterForModEvent(Config.ActorSetAttributeDefaultsEventName, "OnActorSetAttributeDefaults")
	
	RegisterForModEvent(Config.ActorModAttributeEventName, "OnActorSetState")
	RegisterForModEvent(Config.ActorModAttributeEventName, "OnActorModState")
	
	RegisterForModEvent(Config.RegisterAttributeEventName, "OnAttributeRegister")
EndFunction

Int Function CreateNewMutexId()
	NewestMutexId++
	return NewestMutexId
EndFunction

Function IncrementMutex(Int mutex_Id)
	If CurrentMutexId == mutex_ID
		CurrentMutexId++
	Else
		Error("IncrementMutex(): mutex_ID (" + mutex_ID + ") is different than CurrentMutexId (" + CurrentMutexId + "). Could not increment Increment CurrentMutexId!!!")
	EndIf
EndFunction

Function OnAttributeRegister(dattAttribute attribute_faction)
	If attribute_faction
		If !attribute_faction.AttributeName
			Error("OnAttributeRegister() passed in faction name is none... Couldn't register attribute.")
		Else
			; It's a Base Attribute
			If attribute_faction.AttributeType = 0
				Config.BaseAttributeList.AddForm(attribute_faction)
				;StorageUtil.SetStringValue(none, attribute_faction.AttributeName)
				Log("OnAttributeRegister() successfully registered the attribute \"" + attribute_faction.AttributeName + "\" as base attribute.")
			; It's a Fetish Attribute
			ElseIf attribute_faction.AttributeType = 0
				Config.FetishAttributeList.AddForm(attribute_faction)
				;StorageUtil.SetStringValue(none, attribute_faction.AttributeName)
				Log("OnAttributeRegister() successfully registered the attribute \"" + attribute_faction.AttributeName + "\" as fetish attribute.")
			; It's a State Attribute
			ElseIf attribute_faction.AttributeType = 0
				Config.StateAttributeList.AddForm(attribute_faction)
				;StorageUtil.SetStringValue(none, attribute_faction.AttributeName)
				Log("OnAttributeRegister() successfully registered the attribute \"" + attribute_faction.AttributeName + "\" as state attribute.")
			EndIf
			; TODO Calculated Stats
		EndIf
	Else
		Error("OnAttributeRegister() passed in faction is none... Couldn't register attribute.")
	EndIf
EndFunction

Event onActorDecision(Actor target_actor, Actor master_actor, Int response_type, String[] attribute_string, Int[] attribute_magnitude)
	; Add this call to the current cue and increment the counter.
	Int m_mutex_ID = CreateNewMutexId()
	
	; Only run this function if a target_actor was defined... otherwise print an error message.
	If !target_actor
		Error("onActorDecision() target_actor is null... aborting.")
	Else
		; Make sure that response_type is not exceeding its limits.
		If response_type < -3
			response_type = -3
		ElseIf response_type > 3
			response_type = 3
		EndIf
		
		int m_attribute_index = 0
		int m_attribute_count = attribute_magnitude.length
		
		; Make sure that attribute_magnitude is not exceeding their limits.
		While m_attribute_index < m_attribute_count
			If attribute_magnitude[m_attribute_index] < -3
				attribute_magnitude[m_attribute_index] = -3
			ElseIf attribute_magnitude[m_attribute_index] > 3
				attribute_magnitude[m_attribute_index] = 3
			EndIf
		EndWhile
		
		; Execute onActorDecision() function on every Base attribute
		m_attribute_index = 0
		m_attribute_count = Config.BaseAttributeList.GetSize()
		While m_attribute_index < m_attribute_count
			(Config.BaseAttributeList.GetAt(m_attribute_index) as dattAttribute).onActorDecision(target_actor, master_actor, response_type, attribute_string, attribute_magnitude)
		EndWhile
		
		; Execute onActorDecision() function on every Fetish attribute
		m_attribute_index = 0
		m_attribute_count = Config.FetishAttributeLust.GetSize()
		While m_attribute_index < m_attribute_count
			(Config.FetishAttributeList.GetAt(m_attribute_index) as dattAttribute).onActorDecision(target_actor, master_actor, response_type, attribute_string, attribute_magnitude)
		EndWhile
		
		; Process value changes on every Base attribute
		m_attribute_index = 0
		m_attribute_count = Config.BaseAttributeList.GetSize()
		While m_attribute_index < m_attribute_count
			(Config.BaseAttributeList.GetAt(m_attribute_index) as dattAttribute).ProcessAttributeChanges()
		EndWhile
		
		; Process value changes on every Fetish attribute
		m_attribute_index = 0
		m_attribute_count = Config.FetishAttributeList.GetSize()
		While m_attribute_index < m_attribute_count
			(Config.FetishAttributeList.GetAt(m_attribute_index) as dattAttribute).ProcessAttributeChanges()
		EndWhile
		
		
		; TODO
		; Process stored mod values
		
		; TODO
		; Process new attribute types (automatic calculated ones such as submissiveness
		
		; TODO
		; Process states
	EndIf
	; Function finished executing... increment the current mutex ID so the next one can proceed.
	IncrementMutex(m_mutex_ID)
EndEvent
