Scriptname dattUtility Extends Form Hidden

Float Function Max(Float A, Float B) global
	If (A > B)
		Return A
	Else
		Return B
	EndIf
EndFunction

Float Function Min(Float A, Float B) global
	If (A < B)
		Return A
	Else
		Return B
	EndIf
EndFunction

Int Function MaxInt(Int A, Int B) global
	If (A > B)
		Return A
	Else
		Return B
	EndIf
EndFunction

Int Function MinInt(Int A, Int B) global
	If (A < B)
		Return A
	Else
		Return B
	EndIf
EndFunction

; Checks if one value is between two others. If it exceed it's limit, returns the limit
Int Function LimitValueInt(Int value, Int lowBorder, Int highBorder) global
	If value < lowBorder
		return lowBorder
	ElseIf value > highBorder
		return highBorder
	Else
		return value
	EndIf
EndFunction

; Checks if one value is between two values.
Bool Function IsValueInLimitInt(Int value, Int lowBorder, Int highBorder) global
	If value < lowBorder
		return false
	ElseIf value > highBorder
		return false
	Else
		return true
	EndIf
EndFunction

Function SendParameterlessEvent(String eventName) global
	Int retries = 3
	While(retries > 0)
		Int eventId = ModEvent.Create(eventName)
		If eventId
			If(ModEvent.Send(eventId) == true)
				retries = 0
			Else
				Utility.WaitMenuMode(0.05)
				retries -= 1
			EndIf
		Else
			Utility.WaitMenuMode(0.05)
			retries -= 1
		EndIf
	EndWhile
EndFunction

Function SendEventWithFormParam(String eventName,Form fParam) global
	Int retries = 3
	While(retries > 0)
		Int eventId = ModEvent.Create(eventName)
		If eventId
			ModEvent.PushForm(eventId, fParam)
			If(ModEvent.Send(eventId) == true)
				retries = 0
			Else
				Utility.WaitMenuMode(0.05)
				retries -= 1
			EndIf
		Else
			Utility.WaitMenuMode(0.05)
			retries -= 1
		EndIf
	EndWhile
EndFunction

Function SendEventWithFormAndFloatParam(String eventName,Form fParam, float fNum) global
	Int retries = 3
	While(retries > 0)
		Int eventId = ModEvent.Create(eventName)
		If eventId
			ModEvent.PushForm(eventId, fParam)
			ModEvent.PushFloat(eventId, fNum)
			If(ModEvent.Send(eventId) == true)
				retries = 0
			Else
				Utility.WaitMenuMode(0.05)
				retries -= 1
			EndIf
		Else
			Utility.WaitMenuMode(0.05)
			retries -= 1
		EndIf
	EndWhile
EndFunction

Function SendIncreaseArousal(Actor akActor,float fAmount) global
	SendEventWithFormAndFloatParam("slaUpdateExposure",akActor as Form, fAmount)
EndFunction

Function SendEventWithIntParam(String eventName,Int iParam) global
	Int retries = 3
	While(retries > 0)
		Int eventId = ModEvent.Create(eventName)
		If eventId
			ModEvent.PushInt(eventId, iParam)
			If(ModEvent.Send(eventId) == true)
				retries = 0
			Else
				Utility.WaitMenuMode(0.05)
				retries -= 1
			EndIf
		Else
			Utility.WaitMenuMode(0.05)
			retries -= 1
		EndIf
	EndWhile
EndFunction

Function SendEventWithFormAndIntParam(String eventName,Form fParam, Int iParam) global
	Int retries = 3
	While(retries > 0)
		Int eventId = ModEvent.Create(eventName)
		If eventId
			ModEvent.PushForm(eventId, fParam)
			ModEvent.PushInt(eventId, iParam)
			If(ModEvent.Send(eventId) == true)
				retries = 0
			Else
				Utility.WaitMenuMode(0.05)
				retries -= 1
			EndIf
		Else
			Utility.WaitMenuMode(0.05)
			retries -= 1
		EndIf
	EndWhile
EndFunction