Scriptname dattAttributesAPIQuest Extends dattQuestBase

Int Function GetAttribute(Actor akActor, string attributeId)
	If akActor == None
		Warning("[Datt] GetAttribute() received null actor reference... this is something that shouldn't happen")
		return -1
	EndIf
	
	;I hate magic strings, so check validity
	If !VerifyAttributeId(attributeId)
		Warning("[Datt] GetAttribute() received null invalid attribute Id (" + attributeId + ")... this is something that shouldn't happen")
		return -1
	EndIf

	return StorageUtil.GetIntValue(akActor as Form, attributeId)
EndFunction


Function SetAttribute(Actor akActor, string attributeId, int value)
	If akActor == None
		Warning("[Datt] SetAttribute() received null actor reference... this is something that shouldn't happen")
		return
	EndIf
	
	;I hate magic strings, so check validity
	If !VerifyAttributeId(attributeId)
		Warning("[Datt] SetAttribute() received null invalid attribute Id (" + attributeId + ")... this is something that shouldn't happen")
		return
	EndIf

	SendAttributeChangeEvent("Datt_SetAttribute", akActor, attributeId, value)
EndFunction

Function ModAttribute(Actor akActor, string attributeId, int value)
	If akActor == None
		Warning("[Datt] SetAttribute() received null actor reference... this is something that shouldn't happen")
		return
	EndIf
	
	;I hate magic strings, so check validity
	If !VerifyAttributeId(attributeId)
		Warning("[Datt] SetAttribute() received null invalid attribute Id (" + attributeId + ")... this is something that shouldn't happen")
		return
	EndIf

	SendAttributeChangeEvent("Datt_ModAttribute", akActor, attributeId, value)
EndFunction

Function SetSoulState(Actor akActor, int value)
	If akActor == None
		Warning("[Datt] SetAttribute() received null actor reference... this is something that shouldn't happen")
		return
	EndIf
	
	SendAttributeChangeEvent("Datt_SetAttribute", akActor, "_Datt_Soul_State", value)
EndFunction

Function SendAttributeChangeEvent(string eventName, Actor akActor, string attributeId, int value)
	int eventId = ModEvent.Create(eventName)
	If eventId
		ModEvent.PushForm(eventId, akActor as Form)
		ModEvent.PushString(eventId, attributeId)
		ModEvent.PushInt(eventId,value)
		If ModEvent.Send(eventId) == false
			Warning("[Datt] SendAttributeChangeEvent() with event (" + eventName + ") failed to send event.. will retry sending the event (too much script lag?)")
			Utility.WaitMenuMode(0.5)
			int retryCount = 3
			While retryCount > 0
				int retryEventId = ModEvent.Create(eventName)
				If retryEventId
					ModEvent.PushForm(retryEventId, akActor as Form)
					ModEvent.PushString(retryEventId, attributeId)
					ModEvent.PushInt(retryEventId,value)
					If ModEvent.Send(retryEventId) == true
						retryCount = 0
						Utility.WaitMenuMode(0.1)
					EndIf
				Else
					retryCount -= 1
				EndIf
			EndWhile
		EndIf
	EndIf
EndFunction

bool Function VerifyAttributeId(string attributeId)
	If(attributeId == Config.PrideAttributeId)
		return true
	ElseIf(attributeId == Config.SelfEsteemAttributeId)
		return true
	ElseIf(attributeId == Config.WillpowerAttributeId)
		return true
	ElseIf(attributeId == Config.ObedienceAttributeId)
		return true
	ElseIf(attributeId == Config.HumiliationLoverAttributeId)
		return true
	ElseIf(attributeId == Config.ExhibitionistAttributeId)
		return true
	ElseIf(attributeId == Config.MasochistAttributeId)
		return true
	ElseIf(attributeId == Config.NymphomaniacAttributeId)
		return true
	ElseIf(attributeId == Config.SadistAttributeId)
		return true
	Else
		return false
	EndIf
EndFunction




