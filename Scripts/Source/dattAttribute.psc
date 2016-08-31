Scriptname dattAttribute Extends Faction

String Property AttributeName = "" AutoReadOnly
Int Property DefaultValue = 0 AutoReadOnly
Int Property AttributeType = 0 AutoReadOnly
Bool Property HasNegativeValues = true AutoReadOnly
String[] Property ProtectorAttributes Auto
dattConfigQuest Property Config Auto

dattAttributesAPIQuest Property ApiQuest Auto

Int Property TempValue Auto Hidden
Bool Property TempIsMod Auto Hidden
Actor Property TempActor Auto Hidden

; ==============================
; Events
; ==============================

Event OnInit()
	AttributeName = ""
	Config = Quest.GetQuest("dattConfigQuest") as dattConfigQuest
	PlayerActor = Game.GetPlayer()
	DefaultValue = 0
	AttributeType = 0
	HasNegativeValues = true
	ProtectorAttributes = None
EndEvent



; ==============================
; API Functions
; ==============================

; Only calculate the new faction rank and return the value. No changes to are being made to the current faction rank.
; This is mainly used if you modify multiple attributes at the same time, but do want all calculations use the same values.
Int Function CalculateActorDecision(Actor target_actor, Actor master_actor, Int response_type, String[] attribute_string, Int[] attribute_magnitude)
	Int m_new_attribute_value = 0
	
	return m_new_attribute_value
EndFunction

Int Function CalculateActorAffected(Actor target_actor, String[] attribute_string, Int[] attribute_magnitude)
	Int m_new_attribute_value = 0
	
	return m_new_attribute_value
EndFunction



; ==============================
; Core Functions
; ==============================
; These functions are the barebones of the script. Do not change these!


Function ActorDecision(Actor target_actor, Actor master_actor, Int response_type, String[] attribute_string, Int[] attribute_magnitude)
	If target_actor == None
		Warning("ActorDecision() attribute " + AttributeName + " received null actor reference. Aborting...")
		;Return on_error_value
	Else
		TempValue = CalculateActorDecision(target_actor, master_actor, response_type, attribute_string, attribute_magnitude)
		TempIsMod = true
		TempActor = target_actor
	EndIf
EndFunction

Function ActorAffected(Actor target_actor, String[] attribute_string, Int[] attribute_magnitude)
	If target_actor == None
		Warning("ActorAffected() attribute " + AttributeName + " received null actor reference. Aborting...")
		;Return on_error_value
	Else
		TempValue = CalculateActorAffected(target_actor, master_actor, response_type, attribute_string, attribute_magnitude)
		TempIsMod = true
		TempActor = target_actor
	EndIf
EndFunction



Function ModAttributeValue(Actor target_actor = None, Int attribute_value)
	If target_actor == None
		Warning("datt_ModAttributeValue() attribute " + AttributeName + " received null actor reference. Aborting...")
		;Return on_error_value
	Else
		TempValue = attribute_value
		TempIsMod = true
		TempActor = target_actor
	EndIf
EndFunction

Function SetAttributeValue(Actor target_actor = None, Int attribute_value)
	If target_actor == None
		Warning("datt_ModAttributeValue() attribute " + AttributeName + " received null actor reference. Aborting...")
		;Return on_error_value
	Else
		TempValue = attribute_value
		TempIsMod = false
		TempActor = target_actor
	EndIf
EndFunction

; Used to apply the newly calculated value.
Function ProcessAttributeChanges()
	If TempValue != 0
		ChangeAttributeValue(TempActor, TempValue, TempType)
		TempValue = 0
	EndIf
EndFunction






; Change the current faction rank for the passed actor. Can work in both modify and set mode.
; It also checks if the stat has been set for the passed actor, and that the new rank does not exceed it's limits.
Function ChangeAttributeValue(Actor target_actor = None, Int attribute_value, bool is_modifying)
	;Log("ChangeAttributeValue() called...")
	If target_actor == None
		Warning("GetAttribute() attribute " + AttributeName + " received null actor reference. Return on_error_value of " + on_error_value + "...")
		;Return on_error_value
	EndIf
	
	; Check if the attribute has already been set for the actor and eventually initialize it if needed
	If !StorageUtil.HasIntValue(target_actor, AttributeName)
		AddActorToFaction(target_actor)
	EndIf
	
	
	; Change attribute value if it somehow does exceed the min/max limits and fire events for statchanges
	Int m_attribute_value_new
	Int m_attribute_value_current = target_actor.GetFactionRank(self)
	If is_modifying
		; Using modify mode. Get current value and add the value of the parameter.
		m_attribute_value_new = dattUtility.LimitValueInt(m_attribute_value_current + attribute_value, GetMinValue(target_actor), GetMaxValue(target_actor))
	Else
		; Using replace mode. Set the new value to the parameter.
		m_attribute_value_new = dattUtility.LimitValueInt(attribute_value, GetMinValue(target_actor), GetMaxValue(target_actor))
	EndIf
	
	; check if new value is different than the current one.
	If m_attribute_value_new != m_attribute_value_current
		Log("ChangeAttributeValue() new value (" + m_attribute_value_new + ") differs from current value (" + m_attribute_value_current + ")... Proceed with changes for \"" + AttributeName + "\".")
		target_actor.SetFactionRank(self, m_attribute_value_new)
		StorageUtil.SetIntValue(target_actor, AttributeName, m_attribute_value_new)
		
		Int m_attribute_state_new = GetAttributeState(m_attribute_value_new)
		If m_attribute_state_new != GetAttributeState(m_attribute_value_current)
			StorageUtil.SetIntValue(target_actor, AttributeName + "_State", m_attribute_state_new)
			;NotifyOfChange(target_actor, AttributeName, m_attribute_state_new)
		EndIf
	Else
		Log("ChangeAttributeValue() new value (" + m_attribute_value_new + ") is the same as current (" + m_attribute_value_current + ") one. No changes were made to attribute \"" + AttributeName + "\".")
	EndIf
EndFunction

; Returns the current attribute value.
; It also checks if the stat has been set for the passed actor, and that the current rank does not exceed it's limits.
Int Function GetAttributeValue(Actor target_actor = None, Int on_error_value = 0, bool set_defaults_on_missing = false)
	If target_actor == None
		Warning("GetAttribute() received null actor reference. Return on_error_value of " + on_error_value + "...")
		;Return on_error_value
	EndIf
	
	; Check if the attribute has already been set for the actor and eventually initialize it if needed
	If !StorageUtil.HasIntValue(target_actor, AttributeName)
		If set_defaults_on_missing
			AddActorToFaction(target_actor)
		Else
			Warning("GetAttribute() attribute \"" + AttributeName + "\" not set for actor \"" + target_actor.GetBaseObject().GetName() + "\". Return on_error_value = " + on_error_value + "...")
			Return on_error_value
		EndIf
	EndIf
	; Change attribute value if it somehow does exceed the min/max limits and fire events for statchanges
	Int m_attribute_value = target_actor.GetFactionRank(self)
	Int m_attribute_value_new = dattUtility.LimitValueInt(m_attribute_value, GetMinValue(target_actor), GetMaxValue(target_actor))
	
	; check if value did exceed min/max limits... save and return the new value instead
	If m_attribute_value != m_attribute_value_new
		Log("GetAttribute() attribute \"" + AttributeName + "\" exceeding the limits for actor \"" + target_actor.GetBaseObject().GetName() + "\". Set value to " + m_attribute_value_new + "...")
		target_actor.SetFactionRank(self, m_attribute_value_new)
		StorageUtil.SetIntValue(target_actor, AttributeName, m_attribute_value_new)
		
		Int m_attribute_state_new = GetAttributeState(m_attribute_value_new)
		If m_attribute_state_new != StorageUtil.GetIntValue(target_actor, AttributeName + "_State")
			StorageUtil.SetIntValue(target_actor, AttributeName + "_State", m_attribute_state_new)
			;NotifyOfChange(target_actor, AttributeName, m_attribute_state_new)
		EndIf
		return m_attribute_value_new
	Else
		Return m_attribute_value
	EndIf
EndFunction

; Adds the passed actor to the faction, and initialize the value with defaults
; If actor the attribute has already been set for the actor, it will do nothing.
; Note: This function is not thread safe as it could be called by GetAttributeValue(). Thought that shouldnt pose much of a problem...
Function AddActorToFaction(Actor target_actor)
	; Check if actor is valid...
	If target_actor == None
		Warning("AddActorToFaction() received null actor reference. Aborting...")
		Return
	EndIf
	
	; Only add the actor to the faction if he hasn't his values yet.
	If !StorageUtil.HasIntValue(target_actor, AttributeName)
		Log("AddActorToFaction() attribute \"" + AttributeName + "\" not set for actor \"" + target_actor.GetBaseObject().GetName() + "\". Set to default values of " + DefaultValue + "...")
		
		target_actor.SetFactionRank(self, DefaultValue)
		StorageUtil.SetIntValue(target_actor, AttributeName, DefaultValue)

		; Attribute State
		Int m_new_state_value = GetAttributeState(DefaultValue)
		If m_new_state_value != StorageUtil.GetIntValue(target_actor, AttributeName + "_State")
			StorageUtil.SetIntValue(target_actor, AttributeName + "_State", m_new_state_value)
			;NotifyOfChange(target_actor, AttributeName, m_new_state_value)
		EndIf
	EndIf
EndFunction

; LEGACY
Int Function GetOtherAttributeValue(Actor target_actor, String attribute_name, Int on_error_value = 0)
	If attribute_name
		If target_actor
			; TODO
			If StorageUtil.HasFormValue(AttributeName)
				return (StorageUtil.GetFormValue(AttributeName) as dattAttribute).GetAttributeValue(target_actor)
			Else
				Log("GetOtherAttributeValue() no value for target_actor. Aborting...")
				Return on_error_value
			EndIf
		Else
			Warning("GetOtherAttributeValue() no value for target_actor. Aborting...")
			Return on_error_value
		EndIf
	Else
		Warning("GetOtherAttributeValue() no value for attribute_name. Aborting...")
		Return on_error_value
	EndIf
EndFunction


; Returns the maximum value for this attribute for that specified actor. The maximum value could be different depending on the selected perks.
Int Function GetMaxValue(Actor target_actor = None)
	Return 100
EndFunction

; Returns the minimum value of this attribute for the passed actor. The minimum value could be different depending on the selected perks.
; The minimum value is always either 0 or the maximum as negative value.
Int Function GetMinValue(Actor target_actor = None)
	If HasNegativeValues
		Return GetMaxValue(target_actor) * -1
	Else
		Return 0
	EndIf
EndFunction

; Returns the default value of this attribute.
Int Function GetDefaultAttributeValue()
	return DefaultValue
EndFunction

; Resets this attributes value for the given actor.
; It currently does not call ChangeAttributeValue() as it can simply modify the values directly.
; This might change in the future.
Function ResetAttributeValue(Actor target_actor)
	If target_actor
		target_actor.SetFactionRank(self, DefaultValue)
		StorageUtil.SetIntValue(target_actor, AttributeName, DefaultValue)
		StorageUtil.SetIntValue(target_actor, AttributeName + "_State", GetAttributeState(DefaultValue))
	EndIf
EndFunction

; Returns the state of attribute depending on it's current value.
; Currently, the values are hardcoded.
; This might change in the future.
Int Function GetAttributeState(Int attribute_value)
	If attribute_value >= 80		;100 to 80
		return 3
	ElseIf attribute_value >= 50	; 79 to 50
		return 2
	ElseIf attribute_value >= 20	; 49 to 20
		return 1
	ElseIf attribute_value > -20	; 19 to -19
		return 0
	ElseIf attribute_value > -50	;-20 to -49
		return -1
	ElseIf attribute_value > -80	;-50 to -79
		return -2
	Else							;-80 to -100
		return -3
	EndIf
EndFunction


Function Log(string asTextToPrint)
	If Config != None && Config.IsLogging
		Debug.Trace("[Datt]" + asTextToPrint)
		MiscUtil.PrintConsole("[Datt - Info]" + asTextToPrint)
	EndIf
EndFunction

Function Warning(string asTextToPrint)
	If Config != None && Config.IsLogging
		Debug.Trace("[Datt]" + asTextToPrint, 1)
		MiscUtil.PrintConsole("[Datt - Warning]" + asTextToPrint)
	EndIf
EndFunction

Function Error(string asTextToPrint)
	If Config != None && Config.IsLogging
		Debug.Trace("[Datt]" + asTextToPrint, 2)
		MiscUtil.PrintConsole("[Datt - Error]" + asTextToPrint)
	EndIf
EndFunction


Bool Function MutexLoop(Int mutex_Id)
	While ApiQuest.CurrentMutexId != mutex_ID
		If mutex_ID > ApiQuest.NewestMutexId
			Error("MutexLoop(): mutex_ID (" + mutex_ID + ") is higher than NewestMutexId (" + ApiQuest.NewestMutexId + ")! Return false.")
			return false
		EndIf
		wait(1.0)
	EndWhile
	return true
EndFunction
