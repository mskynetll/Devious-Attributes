Scriptname dattQuestAttributesBase Extends dattQuestBase Hidden
; This script contains some basic functions in order to handle attributes.
Actor Property HasChangesQueued Auto Hidden

Function NotifyOfChange()
;/
	If HasChangesQueued
		Int handle = ModEvent.Create("Datt_OnAttributeChange")
		If (handle)
			ModEvent.PushForm(handle, HasChangesQueued as Form)
			ModEvent.Send(handle)
		EndIf
		HasChangesQueued = None
	EndIf
/;
EndFunction

Function NotifyOfChangeManual(Actor target_actor)
;/
	If target_actor != None
		Int handle = ModEvent.Create("Datt_OnAttributeChange")
		If (handle)
			ModEvent.PushForm(handle, target_actor as Form)
			ModEvent.Send(handle)
		EndIf
	EndIf
/;
EndFunction

; ==============================
; Attribute Conversion
; ==============================

; Returns the corresponding faction for the attribute name
Faction Function GetFactionByName(String attribute_name)
	; ===== Base Attributes ===== ;
	If attribute_name == Config.WillpowerAttributeName
		Return Config.WillpowerAttributeFaction
	; ===== Fetish Attributes ===== ;
	ElseIf attribute_name == Config.NymphomaniaAttributeName
		Return Config.NymphomaniaAttributeFaction
	; ===== Calculated Attributes ===== ;
	ElseIf attribute_name == Config.SubmissivenessAttributeName
		Return Config.SubmissivenessAttributeFaction
	; ===== Misc Attributes ===== ;
	ElseIf attribute_name == Config.SlaveAbusivenessStateAttributeName
		Return Config.SlaveAbusivenessStateAttributeFaction
	Else
		Warning("GetFactionByName() could not find attribute faction for " + attribute_name + ".")
		Return None
	EndIf
EndFunction

; Returns the corresponding name for the attribute faction
String Function GetNameByFaction(Faction attribute_faction)
	; ===== Base Attributes ===== ;
	If attribute_faction == Config.WillpowerAttributeFaction
		Return Config.WillpowerAttributeName
	; ===== Fetish Attributes ===== ;
	ElseIf attribute_faction == Config.NymphomaniaAttributeFaction
		Return Config.NymphomaniaAttributeName
	; ===== Calculated Attributes ===== ;
	ElseIf attribute_faction == Config.SubmissivenessAttributeFaction
		Return Config.SubmissivenessAttributeName
	; ===== Misc Attributes ===== ;
	ElseIf attribute_faction == Config.SlaveAbusivenessStateAttributeFaction
		Return Config.SlaveAbusivenessStateAttributeName
	Else
		;Warning("GetNameByFaction() could not find attribute faction for attribute_faction = " + attribute_faction + ".")
		Return None
	EndIf
EndFunction

; A simple check if the faction and attribute name are matching.
Bool Function CheckAttributeMatch(Faction attribute_faction, String attribute_name)
	; ===== Base Attributes ===== ;
	If (attribute_faction == Config.WillpowerAttributeFaction && attribute_name == Config.WillpowerAttributeName)
		Return True
	; ===== Fetish Attributes ===== ;
	ElseIf (attribute_faction == Config.NymphomaniaAttributeFaction && attribute_name == Config.NymphomaniaAttributeName)
		Return True
	; ===== Fetish Attributes ===== ;
	ElseIf (attribute_faction == Config.SubmissivenessAttributeFaction && attribute_name == Config.SubmissivenessAttributeName)
		Return True
	; ===== Misc Attributes ===== ;
	ElseIf (attribute_faction == Config.SlaveAbusivenessStateAttributeFaction && attribute_name == Config.SlaveAbusivenessStateAttributeName)
		Return True
	Else
		Return False
	EndIf
Endfunction



; ==============================
; Attribute Type Checks
; ==============================

; Returns true, if the passed in attribute faction is a base attribute
Bool Function IsBaseAttributeByFaction(Faction attribute_faction)
	If attribute_faction == Config.WillpowerAttributeFaction
		Return True
	Else
		Return False
	EndIf
EndFunction

Bool Function IsBaseAttributeByName(String attribute_name)
	If attribute_name == Config.WillpowerAttributeName
		Return True
	Else
		Return False
	EndIf
EndFunction

; Returns true, if the passed in attribute faction is a fetish attribute
Bool Function IsFetishAttributeByFaction(Faction attribute_faction)
	If attribute_faction == Config.NymphomaniaAttributeFaction
		Return True
	Else
		Return False
	EndIf
EndFunction

Bool Function IsFetishAttributeByName(String attribute_name)
	If attribute_name == Config.NymphomaniaAttributeFaction
		Return True
	Else
		Return False
	EndIf
EndFunction

; Returns true, if the passed in attribute faction is a calculated attribute
Bool Function IsCalculatedAttributeByFaction(Faction attribute_faction)
	If attribute_faction == Config.SubmissivenessAttributeFaction
		Return True
	Else
		Return False
	EndIf
EndFunction

Bool Function IsCalculatedAttributeByName(String attribute_name)
	If attribute_name == Config.SubmissivenessAttributeName
		Return True
	Else
		Return False
	EndIf
EndFunction

; Returns true, if the passed in attribute faction is a misc attribute
Bool Function IsMiscAttributeByFaction(Faction attribute_faction)
	If attribute_faction == Config.SlaveAbusivenessStateAttributeFaction
		Return True
	Else
		Return False
	EndIf
EndFunction

Bool Function IsMiscAttributeByName(String attribute_name)
	If attribute_name == Config.SlaveAbusivenessStateAttributeName
		Return True
	Else
		Return False
	EndIf
EndFunction



; ==============================
; Get Min/Max Values
; ==============================

Int Function GetMaxAttributeValueByName(String attribute_name, Actor target_actor = None)
	Int attribute_value_max = 0
	; ===== Base Attributes ===== ;
	If attribute_name == Config.WillpowerAttributeName
		attribute_value_max = Config.MaxBaseAttributeValue
	; ===== Fetish Attributes ===== ;
	ElseIf attribute_name == Config.NymphomaniaAttributeName
		attribute_value_max = Config.MaxFetishAttributeValue
	; ===== Misc Attributes ===== ;
	ElseIf attribute_name == Config.SlaveAbusivenessStateAttributeName
		attribute_value_max = 2
	Else
		Return attribute_value_max
	EndIf
EndFunction

Int Function GetMaxAttributeValueByFaction(Faction attribute_faction, Actor target_actor = None)
	Int attribute_value_max = 0
	; ===== Base Attributes ===== ;
	If attribute_faction == Config.WillpowerAttributeFaction
		attribute_value_max = Config.MaxBaseAttributeValue
	; ===== Fetish Attributes ===== ;
	ElseIf attribute_faction == Config.NymphomaniaAttributeFaction
		attribute_value_max = Config.MaxFetishAttributeValue
	; ===== Misc Attributes ===== ;
	ElseIf attribute_faction == Config.SlaveAbusivenessStateAttributeFaction
		attribute_value_max = 2
	Else
		Return attribute_value_max
	EndIf
EndFunction

Int Function GetMinAttributeValueByName(String attribute_name, Actor target_actor = None)
	Int attribute_value_max = 0
	; ===== Base Attributes ===== ;
	If attribute_name == Config.WillpowerAttributeName
		attribute_value_max = Config.MinBaseAttributeValue
	; ===== Fetish Attributes ===== ;
	ElseIf attribute_name == Config.NymphomaniaAttributeName
		attribute_value_max = Config.MinFetishAttributeValue
	; ===== Misc Attributes ===== ;
	ElseIf attribute_name == Config.SlaveAbusivenessStateAttributeName
		attribute_value_max = -2
	Else
		Return attribute_value_max
	EndIf
EndFunction

Int Function GetMinAttributeValueByFaction(Faction attribute_faction, Actor target_actor = None)
	Int attribute_value_max = 0
	; ===== Base Attributes ===== ;
	If attribute_faction == Config.WillpowerAttributeFaction
		attribute_value_max = Config.MinBaseAttributeValue
	; ===== Fetish Attributes ===== ;
	ElseIf attribute_faction == Config.NymphomaniaAttributeFaction
		attribute_value_max = Config.MinFetishAttributeValue
	; ===== Misc Attributes ===== ;
	ElseIf attribute_faction == Config.SlaveAbusivenessStateAttributeFaction
		attribute_value_max = -2
	Else
		Return attribute_value_max
	EndIf
EndFunction



; ==============================
; Other
; ==============================

Int Function GetAttributeState(Int attribute_value)
	If attribute_value <= Config.HateAttributeValue.GetValue() as Int				; -100 to  -80
		Return -3
	ElseIf attribute_value <= Config.StrongDislikeAttributeValue.GetValue() as Int	;  -80 to  -50
		Return -2
	ElseIf attribute_value <= Config.DislikeAttributeValue.GetValue() as Int			;  -50 to  -20
		Return -1
	ElseIf attribute_value <= Config.LikeAttributeValue.GetValue() as Int				;  -20 to  +20
		Return 0
	ElseIf attribute_value <= Config.StrongLikeAttributeValue.GetValue() as Int		;  +20 to  +50
		Return 1
	ElseIf attribute_value <= Config.LoveAttributeValue.GetValue() as Int				;  +50 to  +80
		Return 2
	Else															;  +80 to +100
		Return 3
	Endif
EndFunction
