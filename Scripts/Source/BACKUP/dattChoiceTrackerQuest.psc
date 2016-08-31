Scriptname dattChoiceTrackerQuest Extends dattQuestBase
dattAttributesAPIQuest Property AttributesAPI Auto
slaFrameworkScr Property SexLabAroused Auto
SexLabFramework Property SexLab Auto

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
	prideExtraChange = LimitValueBetweenBoundaries(prideExtraChange, -100, 100)
	selfEsteemExtraChange = LimitValueBetweenBoundaries(selfEsteemExtraChange, -100, 100)
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

Function TEST(Int player_response_type, Actor target_actor, Int action_magnitude, String[] fetish_types, Int[] fetish_magnitudes)
	Actor m_player = Config.PlayerRef
	If m_player == None
		Error("ProcessPlayerDecision() Player Reference not found. Aborting...")
		return
	EndIf
	
	; Limit all passed values to their min/max
	player_response_type = dattUtility.LimitValueInt(player_response_type, -2, 2)
	action_magnitude = dattUtility.LimitValueInt(action_magnitude, -5, 5)
	Int i_fetish = 0
	While (i_fetish < fetish_magnitudes.length)
		fetish_magnitudes[i_fetish] = dattUtility.LimitValueInt(fetish_magnitudes[i_fetish], 1, 5)
	EndWhile
	
	; Initialize member variables
	; arousal
	Int m_player_arousal = Config.ArousalThresholdToIncreaseFetish
	If SexLabAroused != None
		m_player_arousal = SexLabAroused.GetActorArousal(m_player)
	Else
		Warning("SexLabAroused reference == None. Proceed as if arousal has value of ArousalThresholdToIncreaseFetish (" + Config.ArousalThresholdToIncreaseFetish ").")
	EndIf
	
	; purity
	Int m_aroused_purity = 0
	If SexLab != None
		m_aroused_purity = dattUtility.LimitValueInt(SexLab.GetPlayerPurityLevel(), -6, 6)
	Else
		Warning("SexLab reference == None. Proceed as if purity level is 0.")
	EndIf
	
	; soul state
	Int m_player_soul_state = AttributesAPI.GetAttribute(m_player, Config.SoulStateAttributeId)
	Log("ProcessPlayerDecision(), player arousal = " + m_player_arousal + ", soul state = " + m_player_soul_state)
	
	; base attributes modify
	; Use floats for better calculation
	Float m_attribute_willpower_modify = 0
	Float m_attribute_pride_modify = 0
	Float m_attribute_selfesteem_modify = 0
	Float m_attribute_obedience_modify = 0
	Float m_attribute_submissiveness_value = AttributesAPI.GetAttribute(m_player, Config.SubmissivenessAttributeId)
	
	; this would be either 1 or 2
	Int m_player_response_type_abs = Math.abs(player_response_type) as Int
	Log("ProcessPlayerDecision() -> Response type multiplier = " + m_player_response_type_abs)
	If m_player_soul_state == 0 || m_player_soul_state == 2
		m_attribute_pride_modify += Config.PrideChangePerDecision * player_response_type * action_magnitude
		m_attribute_selfesteem_modify += Config.SelfEsteemChangePerDecision * player_response_type * action_magnitude
		
		
		If(player_response_type > 0)
			; player agreed
			
			m_attribute_obedience_modify -= (Config.m_player_response_type_abs + (m_attribute_submissiveness_value / 10))
		
		ElseIf(player_response_type < 0)
		; player refused
			; Leave Willpower as low as possible, it will then be modified by fetish attributes
			If (m_player_soul_state == 2)
				; Reduced willpower cost as it is easier to disobey as you are forced into it.
				m_attribute_willpower_modify += Config.WillpowerBaseDecisionCost * player_response_type
				m_attribute_obedience_modify = ObedienceChangePerDecision
			Else
				m_attribute_willpower_modify += Config.WillpowerBaseDecisionCost * player_response_type
				m_attribute_obedience_modify = ObedienceChangePerDecision
			EndIf
			
		If(player_response_type > 0)
			; obedience increase, pride and self-esteem decrease
			
		ElseIf(player_response_type < 0)
			; obedience decrease, pride and self-esteem increase
			m_attribute_pride_modify += (Config.PrideChangePerDecision * m_player_response_type_abs)
			m_attribute_selfesteem_modify += (Config.SelfEsteemChangePerDecision * m_player_response_type_abs)
			m_attribute_obedience_modify -= (Config.ObedienceChangePerDecision + ((100 - m_attribute_submissiveness_value) / 10))
			m_attribute_willpower_modify -= (Config.WillpowerBaseDecisionCost * m_player_response_type_abs)
			If(m_player_soul_state == 2)
				; more willpower cost if one is a slave
				; since in this situation it is much harder to say "no"
				m_attribute_willpower_modify -= Config.WillpowerBaseDecisionCost
			EndIf
		Else  ; neutral reaction
			; it takes lots willpower to hold the middle ground
			m_attribute_willpower_modify -= (Config.WillpowerBaseDecisionCost * 4)
		EndIf
	ElseIf m_player_soul_state == 1
		; willing slave
		If(player_response_type > 0)
			; player agreed
			m_attribute_pride_modify += (Config.PrideChangePerDecision * m_player_response_type_abs)
			m_attribute_selfesteem_modify += (Config.SelfEsteemChangePerDecision * m_player_response_type_abs)
			m_attribute_obedience_modify += (Config.ObedienceChangePerDecision + (m_attribute_submissiveness_value / 15))
		ElseIf(player_response_type < 0)
			; player refused
			m_attribute_pride_modify -= (Config.PrideChangePerDecision * m_player_response_type_abs)
			m_attribute_obedience_modify -= (Config.ObedienceChangePerDecision + (m_attribute_submissiveness_value / 15))
			m_attribute_willpower_modify -= Config.WillpowerBaseDecisionCost
		Else
			; neutral reaction
			m_attribute_willpower_modify -= (Config.WillpowerBaseDecisionCost * 2)
		EndIf
	EndIf
	
	
	Int m_player_attribute_nymphomania_value = AttributesAPI.GetAttribute(m_player, Config.NymphomaniaAttributeId)
	Int m_player_attribute_masochism_value = AttributesAPI.GetAttribute(m_player, Config.MasochismAttributeId)
	Int m_player_attribute_sadism_value = AttributesAPI.GetAttribute(m_player, Config.SadismAttributeId)
	Int m_player_attribute_humilation_value = AttributesAPI.GetAttribute(m_player, Config.HumiliationAttributeId)
	Int m_player_attribute_exhibitionism_value = AttributesAPI.GetAttribute(m_player, Config.ExhibitionismAttributeId)
	
	If(fetish_types.Find(Config.NymphomaniaAttributeId) >= 0)
		; Depending on current arousa, increase nympho fetish.
		; The higher the fetish attribute, the lesser the arousal value needs to be
		If m_player_arousal >= 100 - dattUtility.Min(m_player_attribute_nymphomania_value, 10)
			m_attribute_pride_modify -= (m_player_attribute_nymphomania_value * m_aroused_purity) / 100
		EndIf
	EndIf

	If (player_response_type > 0)
		
		
		; Nymphomania
		If(fetish_types.Find(Config.NymphomaniaAttributeId) >= 0)
			If(m_player_attribute_nymphomania_value < 90)
				; if player is not nympho enough, hit to pride and self-esteem
				m_attribute_pride_modify -= (Config.PrideChangePerDecision * m_player_response_type_abs)
				
				; if m_aroused_purity is < 0, it will lessen the hit
				m_attribute_selfesteem_modify -= ((Config.SelfEsteemChangePerDecision * m_player_response_type_abs) + m_aroused_purity)
			Else
				; if player reached max m_player_attribute_nymphomania_value - sex increases self-esteem
				m_attribute_selfesteem_modify += (Config.SelfEsteemChangePerDecision * m_player_response_type_abs)
			EndIf
		EndIf
		; Humiliation
		; for humiliating task, additional hit to pride and self-esteem
		If(fetish_types.Find(Config.HumiliationAttributeId) >= 0) 
			if(m_player_attribute_humilation_value < 100) ;for additional hit, even if player is not horny
				m_attribute_pride_modify -= (Config.PrideChangePerDecision * m_player_response_type_abs)
				m_attribute_selfesteem_modify -= (Config.SelfEsteemChangePerDecision * m_player_response_type_abs * 2) ;humiliation -> additional hit
			Else
				m_attribute_pride_modify += (Config.PrideChangePerDecision * m_player_response_type_abs)
				m_attribute_selfesteem_modify += (m_player_response_type_abs * 2) ;humiliation -> additional hit
			EndIf
		EndIf
		; Exhibitionism
		If(fetish_types.Find(Config.ExhibitionismAttributeId) >= 0) 
			If(m_player_attribute_exhibitionism_value < 90)
				m_attribute_pride_modify -= (Config.PrideChangePerDecision * m_player_response_type_abs)
			Else
				m_attribute_selfesteem_modify += (Config.SelfEsteemChangePerDecision * m_player_response_type_abs)
			EndIf
		EndIf

		If(m_player_arousal >= Config.ArousalThresholdToIncreaseFetish)
			; Nymphomania
			If(fetish_types.Find(Config.NymphomaniaAttributeId) >= 0 && m_player_attribute_nymphomania_value < 100)  ; there is sex related stuff in types
				AttributesAPI.ModAttribute(m_player, Config.NymphomaniaAttributeId, Config.FetishIncrementPerDecision)
				m_attribute_pride_modify -= m_player_response_type_abs
				m_attribute_selfesteem_modify += m_player_response_type_abs  ; no hit to self-esteem if horny enough
			EndIf
			; Masochism
			If(fetish_types.Find(Config.MasochismAttributeId) >= 0 && m_player_attribute_masochism_value < 100)  ; there is pain in types
				AttributesAPI.ModAttribute(m_player, Config.MasochismAttributeId, Config.FetishIncrementPerDecision)
				m_attribute_pride_modify -= m_player_response_type_abs
			EndIf
			; Sadism
			If(fetish_types.Find(Config.SadismAttributeId) >= 0 && m_player_attribute_sadism_value < 100)  ; there is pain in types
				AttributesAPI.ModAttribute(m_player, Config.SadismAttributeId, Config.FetishIncrementPerDecision)
				m_attribute_pride_modify += m_player_response_type_abs
				m_attribute_selfesteem_modify += m_player_response_type_abs
			EndIf
			; Humiliation
			If(fetish_types.Find(Config.HumiliationAttributeId) >= 0 && m_player_attribute_humilation_value < 100)  ; there is humiliation in types
				AttributesAPI.ModAttribute(m_player, Config.HumiliationAttributeId, Config.FetishIncrementPerDecision)
				m_attribute_pride_modify -= m_player_response_type_abs
				m_attribute_selfesteem_modify -= m_player_response_type_abs
			EndIf
			; Exhibitionism
			If(fetish_types.Find(Config.ExhibitionismAttributeId) >= 0 && m_player_attribute_exhibitionism_value < 100)  ; there is exhibitionism in types
				AttributesAPI.ModAttribute(m_player, Config.ExhibitionismAttributeId, Config.FetishIncrementPerDecision)
				m_attribute_pride_modify -= m_player_response_type_abs
			EndIf
		EndIf
	EndIf
	Log("Processing decision, m_attribute_willpower_modify = " + m_attribute_willpower_modify + ", m_attribute_obedience_modify = " + m_attribute_obedience_modify + ", m_attribute_selfesteem_modify = " + m_attribute_selfesteem_modify + ", m_attribute_pride_modify = " + m_attribute_pride_modify)
	AttributesAPI.ModAttribute(m_player, Config.WillpowerAttributeId, m_attribute_willpower_modify)
	AttributesAPI.ModAttribute(m_player, Config.ObedienceAttributeId, m_attribute_obedience_modify)
	AttributesAPI.ModAttribute(m_player, Config.SelfEsteemAttributeId, m_attribute_selfesteem_modify)
	AttributesAPI.ModAttribute(m_player, Config.PrideAttributeId, m_attribute_pride_modify)
EndFunction


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
	Test(player_response_type, target_actor, action_magnitude, fetish_types, fetish_magnitudes)
EndEvent

Event Test2WithActor(Int player_response_type, Actor target_actor, Int action_magnitude, String fetish1_type, Int fetish1_magnitude, String fetish2_type, Int fetish2_magnitude)
	Log("Test2WithActor()")
	String[] fetish_types = new String[2]
	fetish_types[0] = fetish1_type
	fetish_types[1] = fetish2_type
	
	Int[] fetish_magnitudes = new Int[1]
	fetish_magnitudes[0] = fetish1_magnitude
	fetish_magnitudes[1] = fetish2_magnitude
	Test(player_response_type, target_actor, action_magnitude, fetish_types, fetish_magnitudes)
EndEvent
; TODO



; ==============================
; OnTriggerChangesWithNPCs
; ==============================

; TODO