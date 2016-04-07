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

Event OnPlayerSoulStateChange(int soulState)
	Log("OnPlayerSoulStateChange")
	AttribtesAPI.SetSoulState(Config.PlayerRef,soulState)
EndEvent

Event OnPlayerDecision1(int playerResponseType, int decisionType)
	Log("OnPlayerDecision1")
	int[] decisions = new int[1]
	decisions[0] = decisionType
	ProcessPlayerDecision(playerResponseType,decisions,0, 0)
EndEvent

Event OnPlayerDecision2(int playerResponseType, int decisionType1, int decisionType2)
	Log("OnPlayerDecision2")
	int[] decisions = new int[2]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	ProcessPlayerDecision(playerResponseType,decisions,0, 0)
EndEvent

Event OnPlayerDecision3(int playerResponseType, int decisionType1, int decisionType2, int decisionType3)
	Log("OnPlayerDecision3")
	int[] decisions = new int[3]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	decisions[2] = decisionType3
	ProcessPlayerDecision(playerResponseType,decisions,0, 0)
EndEvent

Event OnPlayerDecision4(int playerResponseType, int decisionType1, int decisionType2, int decisionType3, int decisionType4)
	Log("OnPlayerDecision4")
	int[] decisions = new int[4]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	decisions[2] = decisionType3
	decisions[3] = decisionType4
	ProcessPlayerDecision(playerResponseType,decisions,0, 0)
EndEvent

Event OnPlayerDecision1WithExtra(int playerResponseType, int decisionType, int prideExtraChange = 0, int selfEsteemExtraChange = 0)
	Log("OnPlayerDecision1Extra")
	int[] decisions = new int[1]
	decisions[0] = decisionType
	ProcessPlayerDecision(playerResponseType,decisions,prideExtraChange, selfEsteemExtraChange)
EndEvent

Event OnPlayerDecision2WithExtra(int playerResponseType, int decisionType1, int decisionType2, int prideExtraChange = 0, int selfEsteemExtraChange = 0)
	Log("OnPlayerDecision2Extra")
	int[] decisions = new int[2]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	ProcessPlayerDecision(playerResponseType,decisions,prideExtraChange, selfEsteemExtraChange)
EndEvent

Event OnPlayerDecision3WithExtra(int playerResponseType, int decisionType1, int decisionType2, int decisionType3, int prideExtraChange = 0, int selfEsteemExtraChange = 0)
	Log("OnPlayerDecision3Extra")
	int[] decisions = new int[3]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	decisions[2] = decisionType3
	ProcessPlayerDecision(playerResponseType,decisions,prideExtraChange, selfEsteemExtraChange)
EndEvent

Event OnPlayerDecision4WithExtra(int playerResponseType, int decisionType1, int decisionType2, int decisionType3, int decisionType4, int prideExtraChange = 0, int selfEsteemExtraChange = 0)
	Log("OnPlayerDecision4Extra")
	int[] decisions = new int[4]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	decisions[2] = decisionType3
	decisions[3] = decisionType4
	ProcessPlayerDecision(playerResponseType,decisions,prideExtraChange, selfEsteemExtraChange)
EndEvent

;player response types
; -2 -> Strongly refuse
; -1 -> Meekly refuse
; 0  -> Neutral
; 1  -> Agreed, but not eagerly
; 2  -> Enthusiastic

;decision types
; 0 -> regular master command (i.e "fetch me some food!")
; 1 -> humiliating
; 2 -> painful
; 3 -> exhibitionist
; 4 -> sex
Function ProcessPlayerDecision(int playerResponseType, int[] decisionTypes, int prideExtraChange = 0, int selfEsteemExtraChange = 0)
	int playerArousal = SexLabAroused.GetActorArousal(Config.PlayerRef)
	Log("ProcessPlayerDecision(), player arousal=" + playerArousal)

	prideExtraChange = LimitValueBetweenBoundaries(prideExtraChange,-100,100)
	selfEsteemExtraChange = LimitValueBetweenBoundaries(selfEsteemExtraChange,-100,100)

EndFunction

Int Function LimitValueBetweenBoundaries(int value, int lowerBoundry, int higherBoundry)
	int result = value
	If(result < lowerBoundry)
		result = lowerBoundry
	EndIf
	If(result > higherBoundry)
		result = higherBoundry
	EndIf
	return result
EndFunction