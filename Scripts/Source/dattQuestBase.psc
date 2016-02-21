Scriptname dattQuestBase Extends Quest

dattConfigQuest Property Config Auto

;severity
;0 -> info
;1 -> warning
;2 -> error
Function Log(string asTextToPrint)
	If Config != None && Config.IsLogging
		Debug.Trace("[Datt]" + asTextToPrint)
	EndIf
EndFunction

Function Warning(string asTextToPrint)
	If Config != None && Config.IsLogging
		Debug.Trace("[Datt]" + asTextToPrint, 1)
	EndIf
EndFunction

Function Error(string asTextToPrint)
	If Config != None && Config.IsLogging
		Debug.Trace("[Datt]" + asTextToPrint, 2)
	EndIf
EndFunction

Function SendParameterlessEvent(string eventName)
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