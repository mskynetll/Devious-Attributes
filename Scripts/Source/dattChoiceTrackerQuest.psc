Scriptname dattChoiceTrackerQuest Extends dattQuestBase
dattAttributesAPIQuest Property AttributesAPI Auto
slaFrameworkScr Property SexLabAroused Auto
SexLabFramework Property SexLab Auto

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
	AttributesAPI.SetSoulState(Config.PlayerRef,soulState)
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
	int soulState = AttributesAPI.GetAttribute(Config.PlayerRef,Config.SoulStateAttributeId)
	Log("ProcessPlayerDecision(), player arousal=" + playerArousal + ", soul state="+soulState)
	
	int purity = 0
	;precaution, should never be true
	If SexLab != None
	 	purity = dattUtility.LimitValueInt(SexLab.GetPlayerPurityLevel(),-6,6)
	Else
		Warning("SexLab reference == None")
	EndIf
	prideExtraChange = LimitValueBetweenBoundaries(prideExtraChange,-100,100)
	selfEsteemExtraChange = LimitValueBetweenBoundaries(selfEsteemExtraChange,-100,100)
	int submissiveness = AttributesAPI.GetAttribute(Config.PlayerRef,Config.SubmissivenessAttributeId)

	int prideMod = 0
	int selfEsteemMod = 0
	int obedienceMod = 0
	int willpowerMod = 0

	;this would be either 1 or 2
	int absResponseType = Math.abs(playerResponseType) as int
	Log("ProcessPlayerDecision() -> Response type multiplier = " + absResponseType)
	If soulState == 0 || soulState == 2
		If(playerResponseType > 0) ;player agreed
			;player agreed, obedience increase, pride and self-esteem decrease
			prideMod -= (Config.PrideChangePerDecision * absResponseType)
			selfEsteemMod -= (Config.SelfEsteemChangePerDecision * absResponseType)
			obedienceMod += (Config.ObedienceChangePerDecision + (submissiveness / 10))
		ElseIf(playerResponseType < 0) ;player refused
			;player refused, obedience decrease, pride and self-esteem increase
			prideMod += (Config.PrideChangePerDecision * absResponseType)
			selfEsteemMod += (Config.SelfEsteemChangePerDecision * absResponseType)
			obedienceMod -= (Config.ObedienceChangePerDecision + ((100 - submissiveness) / 10))
			willpowerMod -= (Config.WillpowerBaseDecisionCost * absResponseType)

			If(soulState == 2)
				;more willpower cost if one is a slave
				;since in this situation it is much harder to say "no"
				willpowerMod -= Config.WillpowerBaseDecisionCost
			EndIf
		Else ;neutral reaction		
			;it takes lots willpower to hold the middle ground
			willpowerMod -= (Config.WillpowerBaseDecisionCost * 4)
		EndIf
	ElseIf soulState == 1 ;willing slave
		If(playerResponseType > 0) ;player agreed
			prideMod += (Config.PrideChangePerDecision * absResponseType)
			selfEsteemMod += (Config.SelfEsteemChangePerDecision * absResponseType)
			obedienceMod += (Config.ObedienceChangePerDecision + (submissiveness / 15))						
		ElseIf(playerResponseType < 0) ;player refused
			prideMod -= (Config.PrideChangePerDecision * absResponseType)
			obedienceMod -= (Config.ObedienceChangePerDecision + (submissiveness / 15))		
			willpowerMod -= Config.WillpowerBaseDecisionCost				
		Else ;neutral reaction
			willpowerMod -= (Config.WillpowerBaseDecisionCost * 2)
		EndIf				
	EndIf

	If (playerResponseType > 0)
		int humiliationLover = AttributesAPI.GetAttribute(Config.PlayerRef,Config.HumiliationLoverAttributeId)
		int masochist = AttributesAPI.GetAttribute(Config.PlayerRef,Config.MasochistAttributeId)
		int exhibitionist = AttributesAPI.GetAttribute(Config.PlayerRef,Config.ExhibitionistAttributeId)
		int nympho = AttributesAPI.GetAttribute(Config.PlayerRef,Config.NymphomaniacAttributeId)

		;for humiliating task, additional hit to pride and self-esteem
		If(decisionTypes.Find(1) >= 0) 
			if(humiliationLover < 100) ;for additional hit, even if player is not horny
				prideMod -= (Config.PrideChangePerDecision * absResponseType)
				selfEsteemMod -= (Config.SelfEsteemChangePerDecision * absResponseType * 2) ;humiliation -> additional hit
			Else
				prideMod += (Config.PrideChangePerDecision * absResponseType)
				selfEsteemMod += (absResponseType * 2) ;humiliation -> additional hit
			EndIf
		EndIf
		If(decisionTypes.Find(3) >= 0) 
			If(exhibitionist < 90)
				prideMod -= (Config.PrideChangePerDecision * absResponseType)
			Else
				selfEsteemMod += (Config.SelfEsteemChangePerDecision * absResponseType)
			EndIf
		EndIf
		If(decisionTypes.Find(4) >= 0)
			If(nympho < 90)
				;if player is not nympho enough, hit to pride and self-esteem
				prideMod -= (Config.PrideChangePerDecision * absResponseType)	

				;if purity is < 0, it will lessen the hit
				selfEsteemMod -= ((Config.SelfEsteemChangePerDecision * absResponseType) + purity)
			Else
				;if player reached max nympho - sex increases self-esteem
				selfEsteemMod += (Config.SelfEsteemChangePerDecision * absResponseType)
			EndIf
		EndIf

		If(playerArousal >= Config.ArousalThresholdToIncreaseFetish)
			If(decisionTypes.Find(1) >= 0 && humiliationLover < 100) ;there is humiliation in types
				AttributesAPI.ModAttribute(Config.PlayerRef,Config.HumiliationLoverAttributeId,Config.FetishIncrementPerDecision)
				prideMod -= absResponseType
				selfEsteemMod -= absResponseType
			EndIf
			If(decisionTypes.Find(2) >= 0 && masochist < 100) ;there is pain in types
				AttributesAPI.ModAttribute(Config.PlayerRef,Config.MasochistAttributeId,Config.FetishIncrementPerDecision)
				prideMod -= absResponseType
			EndIf
			If(decisionTypes.Find(3) >= 0 && exhibitionist < 100) ;there is exhibitionism in types
				AttributesAPI.ModAttribute(Config.PlayerRef,Config.ExhibitionistAttributeId,Config.FetishIncrementPerDecision)
				prideMod -= absResponseType
			EndIf	
			If(decisionTypes.Find(4) >= 0 && nympho < 100) ;there is sex related stuff in types
				AttributesAPI.ModAttribute(Config.PlayerRef,Config.NymphomaniacAttributeId,Config.FetishIncrementPerDecision)
				prideMod -= absResponseType
				selfEsteemMod += absResponseType ;no hit to self-esteem if horny enough
			EndIf			
		EndIf
	EndIf
	Log("Processing decision, willpowerMod=" + willpowerMod + ", obedienceMod=" + obedienceMod + ", selfEsteemMod=" + selfEsteemMod + ", prideMod="+prideMod)
	AttributesAPI.ModAttribute(Config.PlayerRef,Config.WillpowerAttributeId, willpowerMod)
	AttributesAPI.ModAttribute(Config.PlayerRef,Config.ObedienceAttributeId, obedienceMod)
	AttributesAPI.ModAttribute(Config.PlayerRef,Config.SelfEsteemAttributeId, selfEsteemMod)	
	AttributesAPI.ModAttribute(Config.PlayerRef,Config.PrideAttributeId, prideMod)	
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