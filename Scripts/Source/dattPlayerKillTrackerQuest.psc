Scriptname dattPlayerKillTrackerQuest extends Quest

;reference to the main monitoring quest
dattMonitorQuest Property MonitorQuest Auto 

Event OnStoryKillActor(ObjectReference akVictim, ObjectReference akKiller, Location akLocation, int aiCrimeStatus, int aiRelationshipRank)
	Actor victimActor = akVictim as Actor	 
    MonitorQuest.OnPlayerKill(victimActor,aiRelationshipRank)
    Stop()
EndEvent