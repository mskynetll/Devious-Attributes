Scriptname dattDecisions extends Quest

dattConstants Property Constants Auto
dattConfigMenu Property Config Auto
dattLibraries Property Libs Auto
dattAttributes Property Attributes Auto

Function Initialize()
	RegisterForModEvent(Constants.PlayerDecisionEventName1, "OnPlayerDecision1")
	RegisterForModEvent(Constants.PlayerDecisionEventName2, "OnPlayerDecision2")
	RegisterForModEvent(Constants.PlayerDecisionEventName3, "OnPlayerDecision3")
	RegisterForModEvent(Constants.PlayerDecisionEventName4, "OnPlayerDecision4")

	RegisterForModEvent(Constants.PlayerDecisionWithExtraEventName1, "OnPlayerDecision1WithExtra")
	RegisterForModEvent(Constants.PlayerDecisionWithExtraEventName2, "OnPlayerDecision2WithExtra")
	RegisterForModEvent(Constants.PlayerDecisionWithExtraEventName3, "OnPlayerDecision3WithExtra")
	RegisterForModEvent(Constants.PlayerDecisionWithExtraEventName4, "OnPlayerDecision4WithExtra")

	RegisterForModEvent(Constants.PlayerSoulStateChangeEventName, "OnPlayerSoulStateChange")

	If(Libs.SexLabAroused == None)	
		Debug.MessageBox("Warning, I see 'None' reference for SexLabAroused. I guess the script reference wasn't filled-out by the game. This should not happen, and needs to be reported. Nothing bad will happen, except that fetish values won't be calculated, since they depend on calculating arousal threshold...")
	EndIf
EndFunction

Event OnPlayerSoulStateChange(int soulState)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnPlayerSoulStateChange")
	EndIf
	Attributes.SetPlayerSoulState(soulState)
EndEvent

Event OnPlayerDecision1(int playerResponseType, int decisionType)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnPlayerDecision1")
	EndIf
	int[] decisions = new int[1]
	decisions[0] = decisionType
	ProcessPlayerDecision(playerResponseType,decisions,0, 0)
EndEvent

Event OnPlayerDecision2(int playerResponseType, int decisionType1, int decisionType2)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnPlayerDecision2")
	EndIf
	int[] decisions = new int[2]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	ProcessPlayerDecision(playerResponseType,decisions,0, 0)
EndEvent

Event OnPlayerDecision3(int playerResponseType, int decisionType1, int decisionType2, int decisionType3)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnPlayerDecision3")
	EndIf
	int[] decisions = new int[3]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	decisions[2] = decisionType3
	ProcessPlayerDecision(playerResponseType,decisions,0, 0)
EndEvent

Event OnPlayerDecision4(int playerResponseType, int decisionType1, int decisionType2, int decisionType3, int decisionType4)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnPlayerDecision4")
	EndIf
	int[] decisions = new int[4]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	decisions[2] = decisionType3
	decisions[3] = decisionType4
	ProcessPlayerDecision(playerResponseType,decisions,0, 0)
EndEvent

Event OnPlayerDecision1WithExtra(int playerResponseType, int decisionType, int prideExtraChange = 0, int selfEsteemExtraChange = 0)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnPlayerDecision1")
	EndIf
	int[] decisions = new int[1]
	decisions[0] = decisionType
	ProcessPlayerDecision(playerResponseType,decisions,prideExtraChange, selfEsteemExtraChange)
EndEvent

Event OnPlayerDecision2WithExtra(int playerResponseType, int decisionType1, int decisionType2, int prideExtraChange = 0, int selfEsteemExtraChange = 0)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnPlayerDecision2")
	EndIf
	int[] decisions = new int[2]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	ProcessPlayerDecision(playerResponseType,decisions,prideExtraChange, selfEsteemExtraChange)
EndEvent

Event OnPlayerDecision3WithExtra(int playerResponseType, int decisionType1, int decisionType2, int decisionType3, int prideExtraChange = 0, int selfEsteemExtraChange = 0)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnPlayerDecision3")
	EndIf
	int[] decisions = new int[3]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	decisions[2] = decisionType3
	ProcessPlayerDecision(playerResponseType,decisions,prideExtraChange, selfEsteemExtraChange)
EndEvent

Event OnPlayerDecision4WithExtra(int playerResponseType, int decisionType1, int decisionType2, int decisionType3, int decisionType4, int prideExtraChange = 0, int selfEsteemExtraChange = 0)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnPlayerDecision4")
	EndIf
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
	int playerArousal = Libs.SexLabAroused.GetActorArousal(Libs.PlayerRef)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> ProcessPlayerDecision(), player arousal=" + playerArousal)
	EndIf

	prideExtraChange = LimitValueBetweenBoundaries(prideExtraChange,-100,100)
	selfEsteemExtraChange = LimitValueBetweenBoundaries(selfEsteemExtraChange,-100,100)

	float prideMultiplier = 1.0
	float selfEsteemMultiplier = 1.0
	float obedienceMultiplier = 1.0
	float willpowerSoulStateMultiplier = 1.0
	float responseTypeMultiplier = 1.0

	float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId)
	float selfEsteem = Attributes.GetPlayerAttribute(Constants.SelfEsteemAttributeId)
	float pride = Attributes.GetPlayerAttribute(Constants.PrideAttributeId)
	float obedience = Attributes.GetPlayerAttribute(Constants.ObedienceAttributeId)
			
	int soulState = Attributes.GetPlayerSoulState()
	If(soulState == Constants.State_FreeSpirit || soulState == Constants.State_ForcedSlave)
		If(playerResponseType > 0) ;player agreed
			;2.5% for somewhat agreeing, 5% for enthusiastically agreeing
			responseTypeMultiplier = (Math.abs(playerResponseType) * 0.05) / 2.0
			obedienceMultiplier += responseTypeMultiplier 	
			prideMultiplier -= responseTypeMultiplier
			selfEsteemMultiplier -= responseTypeMultiplier			
		ElseIf(playerResponseType < 0) ;player refused
			;-5% for meekly refusing, -10% for strongly refusing
			responseTypeMultiplier = (Math.abs(playerResponseType) * 0.05)
			obedienceMultiplier -= responseTypeMultiplier
			prideMultiplier += (responseTypeMultiplier)

			If(soulState == Constants.State_ForcedSlave)
				;20% more for willpower cost if one is a slave
				;since in this situation it is much harder to say "no"
				willpowerSoulStateMultiplier = 1.2 
			EndIf
			
			Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId,Max(Constants.MinStatValue, willpower - ((Math.abs(playerResponseType) * Libs.Config.WillpowerBaseDecisionCost * 1.5) * willpowerSoulStateMultiplier)))
		Else ;neutral reaction			
			Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId,Max(Constants.MinStatValue, willpower - (Libs.Config.WillpowerBaseDecisionCost * willpowerSoulStateMultiplier)))
		EndIf
	ElseIf(soulState == Constants.State_WillingSlave)
		If(playerResponseType > 0) ;player agreed
			;2.5% for somewhat agreeing, 5% for enthusiastically agreeing
			responseTypeMultiplier = (Math.abs(playerResponseType) * 0.05) / 2.0
			obedienceMultiplier += responseTypeMultiplier 	

			;you are serving your chosen master -> your self-esteem & pride grows
			prideMultiplier += responseTypeMultiplier
			selfEsteemMultiplier += responseTypeMultiplier 
		ElseIf(playerResponseType < 0) ;player refused
			;-5% for meekly refusing, -10% for strongly refusing
			responseTypeMultiplier = (Math.abs(playerResponseType) * 0.05)
			obedienceMultiplier -= responseTypeMultiplier
			
			;refusing command of your chosen master does not make you proud
			; -> less pride for failing your master
			prideMultiplier -= (responseTypeMultiplier) 				

			;there is still willpower cost to refusing your master command,
			; though it is less then in other soul states
			Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId,Max(Constants.MinStatValue, willpower - (Math.abs(playerResponseType) * Libs.Config.WillpowerBaseDecisionCost)))
		Else ;neutral reaction
			Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId,Max(Constants.MinStatValue, willpower - (Libs.Config.WillpowerBaseDecisionCost * 0.5)))
		EndIf		
	EndIf

	;calculate fetishes if player agreed to request, regardless of player status (free/slave etc.)
	If (playerResponseType > 0)
		If(playerArousal >= Libs.Config.ArousalThresholdToIncreaseFetish)
			If(decisionTypes.Find(1) >= 0) ;there is humiliation in types
				Attributes.IncrementPlayerFetish(Constants.HumiliationLoverAttributeId,Libs.Config.FetishIncrementPerDecision)
				prideMultiplier -= responseTypeMultiplier
				selfEsteemMultiplier -= responseTypeMultiplier ;humiliation -> additional hit
			EndIf
			If(decisionTypes.Find(2) >= 0) ;there is pain in types
				Attributes.IncrementPlayerFetish(Constants.MasochistAttributeId,Libs.Config.FetishIncrementPerDecision)
				prideMultiplier -= responseTypeMultiplier
			EndIf
			If(decisionTypes.Find(3) >= 0) ;there is exhibitionism in types
				Attributes.IncrementPlayerFetish(Constants.ExhibitionistAttributeId,Libs.Config.FetishIncrementPerDecision)
				prideMultiplier -= responseTypeMultiplier
			EndIf	
			If(decisionTypes.Find(4) >= 0) ;there is sex related stuff in types
				Attributes.IncrementPlayerFetish(Constants.NymphomaniacAttributeId,Libs.Config.FetishIncrementPerDecision)
				prideMultiplier -= responseTypeMultiplier
				selfEsteemMultiplier += responseTypeMultiplier ;no hit to self-esteem if horny enough
			EndIf			
		EndIf
	EndIf

	Attributes.SetPlayerAttribute(Constants.PrideAttributeId,pride * prideMultiplier)
	Attributes.SetPlayerAttribute(Constants.SelfEsteemAttributeId,selfEsteem * selfEsteemMultiplier)
	Attributes.SetPlayerAttribute(Constants.ObedienceAttributeId,obedience * obedienceMultiplier)
EndFunction

;helpers

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


Float Function Max(Float A, Float B)
	If (A > B)
		Return A
	Else
		Return B
	EndIf
EndFunction

Float Function Min(Float A, Float B)
	If (A < B)
		Return A
	Else
		Return B
	EndIf
EndFunction