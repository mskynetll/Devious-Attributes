Scriptname dattPlayerStealingTrackerQuest extends Quest

;reference to the main monitoring quest
dattMonitorQuest Property MonitorQuest Auto 

Event OnStoryCrimeGold(ObjectReference akVictim, ObjectReference akCriminal, Form akFaction, int aiGoldAmount, int aiCrime)
	If aiCrime == 0 || aiCrime == 1  ;steal or pickpocket
    	MonitorQuest.OnPlayerStealOrPickpocket(aiGoldAmount)
	EndIf
EndEvent