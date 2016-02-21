Scriptname dattMonitorQuest Extends dattQuestBase

dattAttributeTrackerQuest Property AttributeTracker Auto
dattPeriodicEventsQuest Property PeriodicEvents Auto 
dattNPCScannerQuest Property NPCScanner Auto

Actor Property PlayerRef Auto

Bool Property OneTimeInitialize Auto Hidden
String Property ModVersion Auto Hidden

Event OnInit()
	Maintenance()
EndEvent

Function Maintenance()
	DoVersionUpgrade()

	AttributeTracker.Maintenance()
	PeriodicEvents.Maintenance()
	NPCScanner.Maintenance()

	Debug.Notification("Devious Attributes is active...")	
EndFunction

Function DoVersionUpgrade()
	If ModVersion == "" || ModVersion == "0.6.3"
		If !OneTimeInitialize
			int resetToDefaultsEventId = ModEvent.Create("Datt_SetDefaults")
		    If resetToDefaultsEventId
		       ModEvent.PushForm(resetToDefaultsEventId, PlayerRef as Form)
		        ModEvent.Send(resetToDefaultsEventId)
		    Else
		        ModEvent.Release(resetToDefaultsEventId)
		    EndIf	
		    OneTimeInitialize = true
		EndIf
		ModVersion = "0.7.0"	
	EndIf
	If ModVersion == "0.7.0"
		int resetToDefaultsEventId = ModEvent.Create("Datt_SetDefaults")
		If resetToDefaultsEventId
		    ModEvent.PushForm(resetToDefaultsEventId, PlayerRef as Form)
		    ModEvent.Send(resetToDefaultsEventId)
		Else
		    ModEvent.Release(resetToDefaultsEventId)
		EndIf	
		OneTimeInitialize = true
		Config.FrequentEventUpdateLatencySec = 30
		Config.PeriodicEventUpdateLatencyHours = 12
		ModVersion = "0.7.1"	
	EndIf
EndFunction

Function ForceNPCScan()
	SendParameterlessEvent("Datt_ForceNPCScan")
EndFunction