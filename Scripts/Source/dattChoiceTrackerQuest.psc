Scriptname dattChoiceTrackerQuest Extends dattQuestBase
dattAttributesAPIQuest Property AttributesAPI Auto
slaFrameworkScr Property SexLabAroused Auto
SexLabFramework Property SexLab Auto

Int Property CurrentMutexId = 1 Auto
Int Property NewestMutexId = 0 Auto

Function Maintenance()
	; Legacy Events
	RegisterForModEvent(Config.PlayerDecisionEventName1, "OnPlayerDecision1")
	RegisterForModEvent(Config.PlayerDecisionEventName2, "OnPlayerDecision2")
	RegisterForModEvent(Config.PlayerDecisionEventName3, "OnPlayerDecision3")
	RegisterForModEvent(Config.PlayerDecisionEventName4, "OnPlayerDecision4")

	RegisterForModEvent(Config.PlayerDecisionWithExtraEventName1, "OnPlayerDecision1WithExtra")
	RegisterForModEvent(Config.PlayerDecisionWithExtraEventName2, "OnPlayerDecision2WithExtra")
	RegisterForModEvent(Config.PlayerDecisionWithExtraEventName3, "OnPlayerDecision3WithExtra")
	RegisterForModEvent(Config.PlayerDecisionWithExtraEventName4, "OnPlayerDecision4WithExtra")
	
	; New Events
	RegisterForModEvent(Config.ActorDecisionEventName1, "OnActorDecision1")
	RegisterForModEvent(Config.ActorDecisionEventName1, "OnActorDecision1")
	RegisterForModEvent(Config.ActorDecisionEventName1, "OnActorDecision1")
	RegisterForModEvent(Config.ActorDecisionEventName1, "OnActorDecision1")
	
	RegisterForModEvent(Config.ActorAffectedEventName1, "OnActorAffected1")
	RegisterForModEvent(Config.ActorAffectedEventName2, "OnActorAffected1")
	RegisterForModEvent(Config.ActorAffectedEventName3, "OnActorAffected1")
	RegisterForModEvent(Config.ActorAffectedEventName4, "OnActorAffected1")
	
	RegisterForModEvent(Config.ActorModAttributeEventName, "OnActorModAttribute")
	RegisterForModEvent(Config.ActorSetAttributeEventName, "OnActorSetAttribute")
	RegisterForModEvent(Config.ActorSetAttributeDefaultsEventName, "OnActorSetAttributeDefaults")
	
	; OnTriggerChanges Events
	; TODO
	
	; OnTriggerChangesWithNpc Events
	; TODO
	
	; Misc Events
	RegisterForModEvent(Config.PlayerSoulStateChangeEventName, "OnPlayerSoulStateChange")
	
	If(SexLabAroused == None)
		Warning("I see 'None' reference for SexLabAroused. I guess the script reference wasn't filled-out by the game. This should not happen, and needs to be reported. Nothing bad will happen, except that fetish values won't be calculated, since they depend on calculating arousal threshold...")
	EndIf
EndFunction





Event onActorDecision(Actor target_actor, Actor master_actor, Int response_type, String[] attribute_string, Int[] attribute_magnitude)
	; Add this call to the current cue and increment the counter.
	NewestMutexId++
	Int m_mutex_ID = NewestMutexId
	
	; Keep waiting for a second as long as a different function is still running.
	While CurrentMutexId != m_mutex_ID
		wait(1.0)
	EndWhile
	
	; Only run this function if a target_actor was defined... otherwise print an error message.
	If !target_actor
		Error("onActorDecision() target_actor is null... aborting.")
	Else
		; Make sure that response_type is not exceeding its limits.
		If response_type < -3
			response_type = -3
		ElseIf response_type > 3
			response_type = 3
		EndIf
		
		
		int m_attribute_index = 0
		
		; Execute onActorDecision event on every Base attribute
		int m_attribute_count = Config.BaseAttributeLust.GetSize()
		While m_attribute_index < m_attribute_count
			(Config.BaseAttributeLust.GetAt(m_attribute_index) as dattAttribute).onActorDecision(target_actor, master_actor, response_type, attribute_string, attribute_magnitude)
		EndWhile
		
		
		
		If attribute_string.length
			m_attribute_index = 0
			m_attribute_count = BaseAttributeList.length
			int[m_attribute_count] FetishAttributeValues
			int m_attribute_find_index
			While m_attribute_index < m_attribute_count
				m_attribute_find_index = BaseAttributeList.Find()
			EndWhile
		EndIf
	EndIf
	
	; Function finished executing... increment the current mutex ID so the next one can proceed.
	CurrentMutexId++
EndEvent















; ==============================
; Functions
; ==============================

; ==============================
; Legacy
; ==============================

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
Function ProcessPlayerDecision(Int playerResponseType, Int[] decisionTypes, Int prideExtraChange = 0, Int selfEsteemExtraChange = 0)
	Int playerArousal = SexLabAroused.GetActorArousal(Config.PlayerRef)
	Int soulState = AttributesAPI.GetAttribute(Config.PlayerRef, Config.SoulStateAttributeId)
	Log("ProcessPlayerDecision(), player arousal=" + playerArousal + ", soul state=" + soulState)
	
	Int purity = 0
	;precaution, should never be true
	If SexLab != None
		purity = dattUtility.LimitValueInt(SexLab.GetPlayerPurityLevel(), -6, 6)
	Else
		Warning("SexLab reference == None")
	EndIf
	;prideExtraChange = LimitValueBetweenBoundaries(prideExtraChange, -100, 100)
	;selfEsteemExtraChange = LimitValueBetweenBoundaries(selfEsteemExtraChange, -100, 100)
	Int submissiveness = AttributesAPI.GetAttribute(Config.PlayerRef, Config.SubmissivenessAttributeId)

	Int prideMod = 0
	Int selfEsteemMod = 0
	Int obedienceMod = 0
	Int willpowerMod = 0

	;this would be either 1 or 2
	Int absResponseType = Math.abs(playerResponseType) as Int
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
		Int humiliationLover = AttributesAPI.GetAttribute(Config.PlayerRef, Config.HumiliationAttributeId)
		Int masochist = AttributesAPI.GetAttribute(Config.PlayerRef, Config.MasochismAttributeId)
		Int exhibitionist = AttributesAPI.GetAttribute(Config.PlayerRef, Config.ExhibitionismAttributeId)
		Int nympho = AttributesAPI.GetAttribute(Config.PlayerRef, Config.NymphomaniaAttributeId)

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
				AttributesAPI.ModAttribute(Config.PlayerRef, Config.HumiliationAttributeId, Config.FetishIncrementPerDecision)
				prideMod -= absResponseType
				selfEsteemMod -= absResponseType
			EndIf
			If(decisionTypes.Find(2) >= 0 && masochist < 100) ;there is pain in types
				AttributesAPI.ModAttribute(Config.PlayerRef, Config.MasochismAttributeId, Config.FetishIncrementPerDecision)
				prideMod -= absResponseType
			EndIf
			If(decisionTypes.Find(3) >= 0 && exhibitionist < 100) ;there is exhibitionism in types
				AttributesAPI.ModAttribute(Config.PlayerRef, Config.ExhibitionismAttributeId, Config.FetishIncrementPerDecision)
				prideMod -= absResponseType
			EndIf
			If(decisionTypes.Find(4) >= 0 && nympho < 100) ;there is sex related stuff in types
				AttributesAPI.ModAttribute(Config.PlayerRef, Config.NymphomaniaAttributeId, Config.FetishIncrementPerDecision)
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



; ==============================
; New
; ==============================



; ==============================
; Events
; ==============================

Event OnPlayerSoulStateChange(Int soulState)
	Log("OnPlayerSoulStateChange")
	AttributesAPI.SetSoulState(Config.PlayerRef, soulState)
EndEvent



; ==============================
; OnPlayerDecision
; ==============================

Event OnPlayerDecision1(Int playerResponseType, Int decisionType)
	Log("OnPlayerDecision1")
	Int[] decisions = new Int[1]
	decisions[0] = decisionType
	ProcessPlayerDecision(playerResponseType, decisions,0, 0)
EndEvent

Event OnPlayerDecision2(Int playerResponseType, Int decisionType1, Int decisionType2)
	Log("OnPlayerDecision2")
	Int[] decisions = new Int[2]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	ProcessPlayerDecision(playerResponseType, decisions,0, 0)
EndEvent

Event OnPlayerDecision3(Int playerResponseType, Int decisionType1, Int decisionType2, Int decisionType3)
	Log("OnPlayerDecision3")
	Int[] decisions = new Int[3]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	decisions[2] = decisionType3
	ProcessPlayerDecision(playerResponseType,decisions,0, 0)
EndEvent

Event OnPlayerDecision4(Int playerResponseType, Int decisionType1, Int decisionType2, Int decisionType3, Int decisionType4)
	Log("OnPlayerDecision4")
	Int[] decisions = new Int[4]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	decisions[2] = decisionType3
	decisions[3] = decisionType4
	ProcessPlayerDecision(playerResponseType, decisions,0, 0)
EndEvent

Event OnPlayerDecision1WithExtra(Int playerResponseType, Int decisionType, Int prideExtraChange = 0, Int selfEsteemExtraChange = 0)
	Log("OnPlayerDecision1Extra")
	Int[] decisions = new Int[1]
	decisions[0] = decisionType
	ProcessPlayerDecision(playerResponseType, decisions, prideExtraChange, selfEsteemExtraChange)
EndEvent

Event OnPlayerDecision2WithExtra(Int playerResponseType, Int decisionType1, Int decisionType2, Int prideExtraChange = 0, Int selfEsteemExtraChange = 0)
	Log("OnPlayerDecision2Extra")
	Int[] decisions = new Int[2]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	ProcessPlayerDecision(playerResponseType, decisions, prideExtraChange, selfEsteemExtraChange)
EndEvent

Event OnPlayerDecision3WithExtra(Int playerResponseType, Int decisionType1, Int decisionType2, Int decisionType3, Int prideExtraChange = 0, Int selfEsteemExtraChange = 0)
	Log("OnPlayerDecision3Extra")
	Int[] decisions = new Int[3]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	decisions[2] = decisionType3
	ProcessPlayerDecision(playerResponseType, decisions, prideExtraChange, selfEsteemExtraChange)
EndEvent

Event OnPlayerDecision4WithExtra(Int playerResponseType, Int decisionType1, Int decisionType2, Int decisionType3, Int decisionType4, Int prideExtraChange = 0, Int selfEsteemExtraChange = 0)
	Log("OnPlayerDecision4Extra")
	Int[] decisions = new Int[4]
	decisions[0] = decisionType1
	decisions[1] = decisionType2
	decisions[2] = decisionType3
	decisions[3] = decisionType4
	ProcessPlayerDecision(playerResponseType, decisions, prideExtraChange, selfEsteemExtraChange)
EndEvent



; ==============================
; OnTriggerChanges
; ==============================
Event Test1WithActor(Int player_response_type, Actor target_actor, Int action_magnitude, String fetish_type, Int fetish_magnitude)
	Log("Test1WithActor()")
	String[] fetish_types = new String[1]
	fetish_types[0] = fetish_type
	
	Int[] fetish_magnitudes = new Int[1]
	fetish_magnitudes[0] = fetish_magnitude
	;Test(player_response_type, target_actor, action_magnitude, fetish_types, fetish_magnitudes)
EndEvent

Event Test2WithActor(Int player_response_type, Actor target_actor, Int action_magnitude, String fetish1_type, Int fetish1_magnitude, String fetish2_type, Int fetish2_magnitude)
	Log("Test2WithActor()")
	String[] fetish_types = new String[2]
	fetish_types[0] = fetish1_type
	fetish_types[1] = fetish2_type
	
	Int[] fetish_magnitudes = new Int[1]
	fetish_magnitudes[0] = fetish1_magnitude
	fetish_magnitudes[1] = fetish2_magnitude
	;Test(player_response_type, target_actor, action_magnitude, fetish_types, fetish_magnitudes)
EndEvent
; TODO



; ==============================
; OnTriggerChangesWithNPCs
; ==============================

; TODO