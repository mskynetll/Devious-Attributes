Scriptname dattQuestBase Extends Quest

dattConfigQuest Property Config Auto

;severity
;0 -> info
;1 -> warning
;2 -> error
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


