Scriptname dattChoiceTrackerQuest Extends dattQuestBase
dattAttributesAPIQuest Property AttribtesAPI Auto
slaFrameworkScr Property SexLabAroused Auto

Function Maintenance()
	RegisterForModEvent(Config.PlayerDecisionEventName1, "OnPlayerDecision1")
	RegisterForModEvent(Config.PlayerDecisionEventName2, "OnPlayerDecision2")
	RegisterForModEvent(Config.PlayerDecisionEventName3, "OnPlayerDecision3")
	RegisterForModEvent(Config.PlayerDecisionEventName4, "OnPlayerDecision4")

	RegisterForModEvent(Config.PlayerDecisionWithExtraEventName1, "OnPlayerDecision1WithExtra")
	RegisterForModEvent(Config.PlayerDecisionWithExtraEventName2, "OnPlayerDecision2WithExtra")
	RegisterForModEvent(Config.PlayerDecisionWithExtraEventName3, "OnPlayerDecision3WithExtra")
	RegisterForModEvent(Config.PlayerDecisionWithExtraEventName4, "OnPlayerDecision4WithExtra")

	RegisterForModEvent(Config.PlayerSoulStateChangeEventName, "OnPlayerSoulStateChange")

	If(SexLabAroused == None)	
		Warning("I see 'None' reference for SexLabAroused. I guess the script reference wasn't filled-out by the game. This should not happen, and needs to be reported. Nothing bad will happen, except that fetish values won't be calculated, since they depend on calculating arousal threshold...")
	EndIf	
EndFunction