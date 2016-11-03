Scriptname dattPlayerCastMagicTrackerQuest extends Quest

;reference to the main monitoring quest
dattMonitorQuest Property MonitorQuest Auto 

Event OnStoryCastMagic(ObjectReference akCastingActor, ObjectReference akSpellTarget, Location akLocation, Form akSpell)
	MonitorQuest.OnPlayerCastMagic(akSpell)
	Stop()
endEvent