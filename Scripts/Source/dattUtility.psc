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

int Function MaxInt(int A, int B) global
	If (A > B)
		Return A
	Else
		Return B
	EndIf
EndFunction

int Function MinInt(int A, int B) global
	If (A < B)
		Return A
	Else
		Return B
	EndIf
EndFunction

int Function LimitValueInt(int value, int lowBorder, int highBorder) global
	If value < lowBorder
		return lowBorder
	ElseIf value > highBorder
		return highBorder
	Else
		return value
	EndIf
EndFunction

Function SendParameterlessEvent(string eventName) global
	int retries = 3
	While(retries > 0)
		int eventId = ModEvent.Create(eventName)
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

Function SendEventWithFormParam(string eventName,Form fParam) global
	int retries = 3
	While(retries > 0)
		int eventId = ModEvent.Create(eventName)
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

Function SendEventWithFormAndFloatParam(string eventName,Form fParam, float fNum) global
	int retries = 3
	While(retries > 0)
		int eventId = ModEvent.Create(eventName)
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

Function SendEventWithIntParam(string eventName,int iParam) global
	int retries = 3
	While(retries > 0)
		int eventId = ModEvent.Create(eventName)
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

Function SendEventWithFormAndIntParam(string eventName,Form fParam, int iParam) global
	int retries = 3
	While(retries > 0)
		int eventId = ModEvent.Create(eventName)
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