Scriptname dattMonitorPlayerEvents extends ReferenceAlias

dattMonitorQuest Property MonitorQuest Auto 

Event OnPlayerLoadGame()
	Debug.Notification("Devious Attributes is tracking stats...")
	MonitorQuest.Maintenance()
	MonitorQuest.RegisterForEvents()
EndEvent