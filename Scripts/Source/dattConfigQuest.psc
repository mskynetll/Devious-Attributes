Scriptname dattConfigQuest Extends Quest ;SKI_ConfigBase

Actor Property PlayerRef Auto
<<<<<<< HEAD
Int Property LogLevel Auto Hidden
=======

String Property SettingsPageName = "Settings" AutoReadonly Hidden
String Property AttributesPageName = "Attributes" AutoReadonly Hidden
String Property TrackedNPCsPageName = "Tracked NPCs" AutoReadonly Hidden
String Property DebugPageName = "Debug" AutoReadonly Hidden
String Property AdvancedPageName = "Advanced Options" AutoReadonly Hidden

FormList Property BaseAttributeList Auto
FormList Property FetishAttributeList Auto
FormList Property StateAttributeList Auto

GlobalVariable Property dattEnableAttributeEffects Auto
dattAttributesAPIQuest Property AttributesAPI Auto
Bool Property IsLogging Auto Hidden

dattMutex Property NpcScannerMutex Auto

Event OnConfigInit()
	Pages = new String[5]
	Pages[0] = SettingsPageName
	Pages[1] = AttributesPageName
	Pages[2] = TrackedNPCsPageName
	Pages[3] = DebugPageName
	Pages[4] = AdvancedPageName
EndEvent

Event OnPageReset(String page)
{Called when a new page is selected, including the initial empty page}
	SetCursorFillMode(TOP_TO_BOTTOM) 
	If (page == SettingsPageName)
		SetCursorPosition(0)
		AddHeaderOption("General")
		AddToggleOptionST("General_EnableAttributeEffects_ToggleId", "Enable Attribute Effects", EnableAttributeEffects)
		AddSliderOptionST("General_FrequentEventUpdateLatency_SliderId", "Frequent Attr. Changes", FrequentEventUpdateLatency as Float, "Each {0} hours")
		AddSliderOptionST("General_PeriodicEventUpdateLatency_SliderId", "Periodic Attr. Changes", PeriodicEventUpdateLatencyHours as Float, "Each {0} hours")
		AddSliderOptionST("General_NpcScannerTick_SliderId", "NPC Scanning Tick", NPCScannerTickSec, "Each {0} sec.")
		AddSliderOptionST("General_TraumaStageDecreaseTime_SliderId", "Trauma Stage Decrease", TraumaStageDecreaseTime, "Each {1} hours")
		AddSliderOptionST("General_WillpowerBaseChange_SliderId", "Willpower/tick", WillpowerBaseChange, "{0}")
		AddSliderOptionST("General_WillpowerChangePerOrgasm_SliderId", "Willpower/orgasm", WillpowerChangePerOrgasm, "{0} per orgasm")
		AddSliderOptionST("General_WillpowerChangePerRape_SliderId", "Willpower/rape", WillpowerChangePerRape, "{0} per rape")
		AddSliderOptionST("General_PrideChangePerRape_SliderId", "Pride/rape", PrideChangePerRape, "{0} per rape")
		AddSliderOptionST("General_SelfEsteemChangePerRape_SliderId", "Self-Esteem/rape", SelfEsteemChangePerRape, "{0} per rape") 
		AddSliderOptionST("General_IntervalBetweenSexToIncreaseNymphoHours_SliderId", "Interval/increase nympho", IntervalBetweenSexToIncreaseNymphoHours, "Less than {0} hours")
		AddSliderOptionST("General_NymphomaniaIncreasePerConsensual_SliderId" ,"Nympho incr/consensual", NymphoIncreasePerConsensual, "{0}")
		AddSliderOptionST("General_PrideChangePerPlayerKill_SliderId", "Pride/kill", PrideChangePerPlayerKill, "{0} per kill")
		AddSliderOptionST("General_AttributeChangePerStealOrPickpocket_SliderId", "Pride,Self-Esteem/theft", AttributeChangePerStealOrPickpocket, "{0} per pickpocket")
		AddSliderOptionST("General_PeriodicSelfEsteemIncrease_SliderId", "Self-esteem/periodic", PeriodicSelfEsteemIncrease, "Increase by {0}")
		
		SetCursorPosition(1)
		AddHeaderOption("Decisions")
		AddSliderOptionST("Decisions_WillpowerBaseDecisionCost_SliderId", "Willpower base cost", WillpowerBaseDecisionCost, "{0}")
		AddSliderOptionST("Decisions_PrideChangePerDecision_SliderId", "Pride change", PrideChangePerDecision,"{0}")
		AddSliderOptionST("Decisions_SelfEsteemChangePerDecision_SliderId", "Self-Esteem change", SelfEsteemChangePerDecision,"{0}")
		AddSliderOptionST("Decisions_ObedienceChangePerDecision_SliderId", "Obedience change", ObedienceChangePerDecision,"{0}")
		AddSliderOptionST("Decisions_FetishIncrementPerDecision_SliderId", "Fetish increment", FetishIncrementPerDecision, "{0}")
		AddSliderOptionST("Decisions_ArousalThresholdToIncreaseFetish_SliderId", "Arousal threshold - fetishes", ArousalThresholdToIncreaseFetish) 
		
	ElseIf (page == TrackedNPCsPageName)
		PrintTrackedNPCs()
	ElseIf (page == AttributesPageName)
		SetCursorPosition(0)
		AddHeaderOption("Player Base Attributes")
		
		AddTextOptionST("PlayerBaseAttributes_Willpower_TextID", "Willpower", AttributesAPI.GetAttribute(PlayerRef, WillpowerAttributeId), 1)
		AddTextOptionST("PlayerBaseAttributes_Pride_TextID", "Pride", AttributesAPI.GetAttribute(PlayerRef, PrideAttributeId), 1)
		AddTextOptionST("PlayerBaseAttributes_SelfEsteem_TextID", "Self-Esteem", AttributesAPI.GetAttribute(PlayerRef, SelfEsteemAttributeId), 1)
		AddTextOptionST("PlayerBaseAttributes_Obedience_TextID", "Obedience", AttributesAPI.GetAttribute(PlayerRef, ObedienceAttributeId), 1)
		AddTextOptionST("PlayerBaseAttributes_Submissiveness_TextID", "Submissiveness", AttributesAPI.GetAttribute(PlayerRef, SubmissivenessAttributeId), 1)
		
		AddHeaderOption("Player Misc Attributes")
		Int soulState = AttributesAPI.GetAttribute(PlayerRef, SoulStateAttributeId)
		String soulStateString
		If(soulState == 0)
			soulStateString = "Free(0)"
		ElseIf(soulState == 1)
			soulStateString = "Willing(1)"
		ElseIf(soulState == 2)
			soulStateString = "Forced Slave(2)"
		EndIf
		AddTextOptionST("PlayerMiscAttributes_SoulState_TextID", "Soul State", soulStateString, 1)
		
		SetCursorPosition(1)
		AddHeaderOption("Player Fetish Attributes")
		AddTextOptionST("PlayerFetishAttributes_Nymphomania_TextId", "Nymphomania", AttributesAPI.GetAttribute(PlayerRef, NymphomaniaAttributeId), 1)
		AddTextOptionST("PlayerFetishAttributes_Masochism_TextId", "Masochism", AttributesAPI.GetAttribute(PlayerRef, MasochismAttributeId), 1)
		AddTextOptionST("PlayerFetishAttributes_Sadism_TextId", "Sadism", AttributesAPI.GetAttribute(PlayerRef, SadismAttributeId), 1)
		AddTextOptionST("PlayerFetishAttributes_Humiliation_TextId", "Humiliation", AttributesAPI.GetAttribute(PlayerRef, HumiliationAttributeId), 1)
		AddTextOptionST("PlayerFetishAttributes_Exhibitionism_TextId", "Exhibitionism", AttributesAPI.GetAttribute(PlayerRef, ExhibitionismAttributeId), 1)
		
		AddEmptyOption()
		; TODO
		AddTextOptionST("Rape Trauma Level", "Rape Trauma Level", PlayerRef.GetFactionRank(RapeTraumaAttributeFaction) / 10, 1)
	ElseIf (page == DebugPageName)
		SetCursorPosition(0)
		AddHeaderOption("Misc")
		AddToggleOptionST("Misc_ShowDebugMessages_ToggleId", "Turn on/off logging", IsLogging)
		AddToggleOptionST("Misc_ResetPlayerAttribtes_ToggleId", "Reset player attributes", false)
		AddToggleOptionST("Misc_SimulateRape_ToggleId", "Simulate Rape (2 actors)", false)
		AddSliderOptionST("Misc_ManualSoulState_SliderId", "Soul State", AttributesAPI.GetAttribute(PlayerRef, SoulStateAttributeId), "{0}")
		
		AddHeaderOption("Player Decisions")
		AddSliderOptionST("PlayerDecisions_DebugPlayerResponseType_SliderId", "Response type", DebugPlayerResponseType, "{0}")
		AddSliderOptionST("PlayerDecisions_DebugPlayerDecisionType_SliderId", "Decision type", DebugPlayerDecisionType, "{0}")
		AddSliderOptionST("PlayerDecisions_DebugExtraPrideChange_SliderId", "Extra pride change", DebugExtraPrideChange, "{0}")
		AddSliderOptionST("PlayerDecisions_DebugExtraSelfEsteemChange_SliderId", "Extra self-esteem change", DebugExtraSelfEsteemChange, "{0}")
		AddToggleOptionST("PlayerDecisions_DebugPlayerDecision_ToggleId", "Simulate player decision", false)
		AddToggleOptionST("PlayerDecisions_DebugPlayerDecisionWithExtraChanges_ToggleId", "Simulate player decision(extra changes)", false)
		
		;AddHeaderOption("Internal Stuff")
		;Int queuedChangeCount = StorageUtil.FormListCount(None, "_datt_queued_actors")
		;AddTextOptionST("queuedAttributeChangesTextId", "Queued Attribute Changes", queuedChangeCount, 1)
		;AddToggleOptionST("clearChangeQueueToggleId", "Clean Attribute Change Queue", false)
		
		SetCursorPosition(1)
		AddHeaderOption("Tracked NPCs")
		AddToggleOptionST("TrackedNPCs_ResetTrackedNPCStats_ToggleId", "Reset tracked NPC stats", false)
		AddToggleOptionST("TrackedNPCs_ForceNPCScan_ToggleId", "Refresh Tracked NPCs", false)
		
		AddHeaderOption("Change Attribute")
		String AttributeString
		If DebugAttributeTypeIsFetish
			AttributeString = (FetishAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName
		Else
			AttributeString = (BaseAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName
		EndIf
		AddToggleOptionST("ChangeAttribute_DebugChangeAttribute_ToggleID", "Simulate attribute change", false)
		AddToggleOptionST("ChangeAttribute_DebugAttributeType_ToggleID", "Fetish attribute", DebugAttributeTypeIsFetish)
		AddTextOptionST("ChangeAttribute_DebugAttributeString_TextID", "Attribute", AttributeString)
		AddSliderOptionST("ChangeAttribute_DebugAttributeValue_SliderID", "Value", DebugAttributeValue, "{0}")
		AddToggleOptionST("ChangeAttribute_DebugAttributeMod_ToggleID", "Modify value", DebugAttributeIsMod)
	ElseIf (page == AdvancedPageName)
		SetCursorPosition(0)
		AddHeaderOption("Default Base Attributes Values")
		AddSliderOptionST("DefaultBase_WillpowerDefault_SliderId", "Willpower default value", WillpowerAttributeDefault, "{0}")
		AddSliderOptionST("DefaultBase_PrideDefault_SliderId", "Pride default value", PrideAttributeDefault, "{0}")
		AddSliderOptionST("DefaultBase_SelfEsteemDefault_SliderId", "Self Esteem default value", SelfEsteemAttributeDefault, "{0}")
		AddSliderOptionST("DefaultBase_ObedienceDefault_SliderId", "Obedience default value", ObedienceAttributeDefault, "{0}")
		AddSliderOptionST("DefaultBase_SubmissivenessDefault_SliderId", "Submissiveness default value", SubmissivenessAttributeDefault, "{0}")
		
		SetCursorPosition(1)
		AddHeaderOption("Default Fetish Attributes Values")
		AddSliderOptionST("DefaultFetish_HumiliationAttributeDefault_SliderId", "Humiliation default value", HumiliationAttributeDefault, "{0}")
		AddSliderOptionST("DefaultFetish_ExhibitionismAttributeDefault_SliderId", "Exhibitionism default value", ExhibitionismAttributeDefault, "{0}")
		AddSliderOptionST("DefaultFetish_MasochismAttributeDefault_SliderId", "Masochism default value", SadismAttributeDefault, "{0}")
		AddSliderOptionST("DefaultFetish_SadismAttributeDefault_SliderId", "Sadism default value", MasochismAttributeDefault, "{0}")
		AddSliderOptionST("DefaultFetish_NymphomaniaDefault_SliderId", "Nymphomania default value", NymphomaniaAttributeDefault, "{0}")
	EndIf
EndEvent

; ==============================
; General
; ==============================
State General_EnableAttributeEffects_ToggleId
	Event OnSelectST()
		EnableAttributeEffects = !EnableAttributeEffects
		SetToggleOptionValueST(EnableAttributeEffects)
	EndEvent
	
	Event OnDefaultST()
		EnableAttributeEffects = true
		SetToggleOptionValueST(EnableAttributeEffects)
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_FrequentEventUpdateLatency_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(FrequentEventUpdateLatency)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(1, 360) 
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		FrequentEventUpdateLatency = a_value as Int
		SetSliderOptionValueST(FrequentEventUpdateLatency, "Each {0} hours")
	EndEvent
	
	Event OnDefaultST()
		FrequentEventUpdateLatency = 30
		SetSliderOptionValueST(FrequentEventUpdateLatency, "Each {0} hours")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_PeriodicEventUpdateLatency_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(PeriodicEventUpdateLatencyHours)
		SetSliderDialogDefaultValue(12)
		SetSliderDialogRange(1, 360) 
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		PeriodicEventUpdateLatencyHours = a_value as Int
		SetSliderOptionValueST(PeriodicEventUpdateLatencyHours, "Each {0} hours")
	EndEvent
	
	Event OnDefaultST()
		PeriodicEventUpdateLatencyHours = 12
		SetSliderOptionValueST(PeriodicEventUpdateLatencyHours, "Each {0} hours")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_NpcScannerTick_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(NPCScannerTickSec)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(1, 30) 
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		NPCScannerTickSec = a_value as Int
		SetSliderOptionValueST(NPCScannerTickSec, "Each {0} sec.")
	EndEvent
	
	Event OnDefaultST()
		NPCScannerTickSec = 10
		SetSliderOptionValueST(NPCScannerTickSec, "Each {0} sec.")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_TraumaStageDecreaseTime_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(TraumaStageDecreaseTime)
		SetSliderDialogDefaultValue(12.0)
		SetSliderDialogRange(1.0, 24.0)
		SetSliderDialogInterval(0.5)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		TraumaStageDecreaseTime = a_value
		SetSliderOptionValueST(TraumaStageDecreaseTime, "Each {1} hours")
	EndEvent
	
	Event OnDefaultST()
		TraumaStageDecreaseTime = 12.0
		SetSliderOptionValueST(TraumaStageDecreaseTime, "Each {1} hours")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_WillpowerBaseChange_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WillpowerBaseChange)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(2, 50)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		WillpowerBaseChange = a_value as Int
		SetSliderOptionValueST(WillpowerBaseChange, "{0}")
	EndEvent
	
	Event OnDefaultST()
		WillpowerBaseChange = 10
		SetSliderOptionValueST(WillpowerBaseChange, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_WillpowerChangePerOrgasm_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WillpowerChangePerOrgasm)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(7, 100) 
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		WillpowerChangePerOrgasm = a_value as Int
		SetSliderOptionValueST(WillpowerChangePerOrgasm, "{0} per orgasm")
	EndEvent
	
	Event OnDefaultST()
		WillpowerChangePerOrgasm = 10
		SetSliderOptionValueST(WillpowerChangePerOrgasm, "{0} per orgasm")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_WillpowerChangePerRape_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WillpowerChangePerRape)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(0, 100) 
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		WillpowerChangePerRape = a_value as Int
		SetSliderOptionValueST(WillpowerChangePerRape, "{0} per rape")
	EndEvent
	
	Event OnDefaultST()
		WillpowerChangePerRape = 10
		SetSliderOptionValueST(WillpowerChangePerRape, "{0} per rape")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_PrideChangePerRape_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(PrideChangePerRape)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		PrideChangePerRape = a_value as Int
		SetSliderOptionValueST(PrideChangePerRape, "{0} per rape")
	EndEvent
	
	Event OnDefaultST()
		PrideChangePerRape = 2
		SetSliderOptionValueST(PrideChangePerRape, "{0} per rape")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_SelfEsteemChangePerRape_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(SelfEsteemChangePerRape)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		SelfEsteemChangePerRape = a_value as Int
		SetSliderOptionValueST(SelfEsteemChangePerRape, "{0} per rape")
	EndEvent
	
	Event OnDefaultST()
		SelfEsteemChangePerRape = 1
		SetSliderOptionValueST(SelfEsteemChangePerRape, "{0} per rape")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_IntervalBetweenSexToIncreaseNymphoHours_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(IntervalBetweenSexToIncreaseNymphoHours)
		SetSliderDialogDefaultValue(6)
		SetSliderDialogRange(1, 24)
		SetSliderDialogInterval(1.0)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		IntervalBetweenSexToIncreaseNymphoHours = a_value
		SetSliderOptionValueST(IntervalBetweenSexToIncreaseNymphoHours, "Less than {0} hours")
	EndEvent
	
	Event OnDefaultST()
		IntervalBetweenSexToIncreaseNymphoHours = 6
		SetSliderOptionValueST(IntervalBetweenSexToIncreaseNymphoHours, "Less than {0} hours")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_NymphomaniaIncreasePerConsensual_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(NymphoIncreasePerConsensual)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(1, 25)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		NymphoIncreasePerConsensual = a_value as Int
		SetSliderOptionValueST(NymphoIncreasePerConsensual, "{0}")
	EndEvent
	
	Event OnDefaultST()
		NymphoIncreasePerConsensual = 2
		SetSliderOptionValueST(NymphoIncreasePerConsensual, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_PrideChangePerPlayerKill_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(PrideChangePerPlayerKill)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		PrideChangePerPlayerKill = a_value as Int
		SetSliderOptionValueST(PrideChangePerPlayerKill, "{0} per kill")
	EndEvent
	
	Event OnDefaultST()
		PrideChangePerPlayerKill = 5
		SetSliderOptionValueST(PrideChangePerPlayerKill, "{0} per kill")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_AttributeChangePerStealOrPickpocket_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(AttributeChangePerStealOrPickpocket)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		AttributeChangePerStealOrPickpocket = a_value as Int
		SetSliderOptionValueST(AttributeChangePerStealOrPickpocket, "{0} per pickpocket")
	EndEvent
	
	Event OnDefaultST()
		AttributeChangePerStealOrPickpocket = 5
		SetSliderOptionValueST(AttributeChangePerStealOrPickpocket, "{0} per pickpocket")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State General_PeriodicSelfEsteemIncrease_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(PeriodicSelfEsteemIncrease)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		PeriodicSelfEsteemIncrease = a_value as Int
		SetSliderOptionValueST(PeriodicSelfEsteemIncrease, "Increase by {0}")
	EndEvent
	
	Event OnDefaultST()
		PeriodicSelfEsteemIncrease = 5
		SetSliderOptionValueST(PeriodicSelfEsteemIncrease, "Increase by {0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState



; ==============================
; Decisions
; ==============================
State Decisions_WillpowerBaseDecisionCost_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WillpowerBaseDecisionCost)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		WillpowerBaseDecisionCost = a_value as Int
		SetSliderOptionValueST(WillpowerBaseDecisionCost, "{0} base per decision")
	EndEvent
	
	Event OnDefaultST()
		WillpowerBaseDecisionCost = 15
		SetSliderOptionValueST(WillpowerBaseDecisionCost, "{0} base per decision")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State Decisions_PrideChangePerDecision_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(PrideChangePerDecision)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		PrideChangePerDecision = a_value as Int
		SetSliderOptionValueST(PrideChangePerDecision, "{0} base per decision")
	EndEvent
	
	Event OnDefaultST()
		PrideChangePerDecision = 2
		SetSliderOptionValueST(PrideChangePerDecision, "{0} base per decision")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State Decisions_SelfEsteemChangePerDecision_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(SelfEsteemChangePerDecision)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		SelfEsteemChangePerDecision = a_value as Int
		SetSliderOptionValueST(SelfEsteemChangePerDecision, "{0} base per decision")
	EndEvent
	
	Event OnDefaultST()
		SelfEsteemChangePerDecision = 1
		SetSliderOptionValueST(SelfEsteemChangePerDecision, "{0} base per decision")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State Decisions_ObedienceChangePerDecision_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(ObedienceChangePerDecision)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		ObedienceChangePerDecision = a_value as Int
		SetSliderOptionValueST(ObedienceChangePerDecision, "{0} base per decision")
	EndEvent
	
	Event OnDefaultST()
		ObedienceChangePerDecision = 2
		SetSliderOptionValueST(ObedienceChangePerDecision, "{0} base per decision")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State Decisions_FetishIncrementPerDecision_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(FetishIncrementPerDecision)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		FetishIncrementPerDecision = a_value as Int
		SetSliderOptionValueST(FetishIncrementPerDecision, "{0}")
	EndEvent
	
	Event OnDefaultST()
		FetishIncrementPerDecision = 2
		SetSliderOptionValueST(FetishIncrementPerDecision, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State Decisions_ArousalThresholdToIncreaseFetish_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(ArousalThresholdToIncreaseFetish)
		SetSliderDialogDefaultValue(85)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		ArousalThresholdToIncreaseFetish = a_value as Int
		SetSliderOptionValueST(ArousalThresholdToIncreaseFetish, "{0}")
	EndEvent
	
	Event OnDefaultST()
		ArousalThresholdToIncreaseFetish = 85
		SetSliderOptionValueST(ArousalThresholdToIncreaseFetish, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState



; ==============================
; Misc
; ==============================
State Misc_ShowDebugMessages_ToggleId
	Event OnSelectST()
		IsLogging = !IsLogging
		SetToggleOptionValueST(IsLogging)
	EndEvent
	
	Event OnDefaultST()
		IsLogging = false
		SetToggleOptionValueST(IsLogging)
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State Misc_ResetPlayerAttribtes_ToggleId
	Event OnSelectST()
		Int resetToDefaultsEventId = ModEvent.Create("Datt_SetDefaults")
		If resetToDefaultsEventId
			ModEvent.PushForm(resetToDefaultsEventId, PlayerRef)
			If ModEvent.Send(resetToDefaultsEventId)
				Debug.MessageBox("Player attributes reset to defaults")
			Else
				Debug.MessageBox("Player attributes weren't reset to defaults, sending the event failed. Please try again. (Do you have script lag?)")
			EndIf
		Else
			ModEvent.Release(resetToDefaultsEventId)
			Debug.MessageBox("Player attributes reset to defaults failed, ModEvent didn't create the event properly.")
		EndIf
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State Misc_SimulateRape_ToggleId
	Event OnSelectST()
		dattUtility.SendEventWithFormAndIntParam("Datt_Simulate_Rape", PlayerRef, 2)
		Debug.MessageBox("Datt_Simulate_Rape event sent for PC.")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State Misc_ManualSoulState_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(AttributesAPI.GetAttribute(PlayerRef,SoulStateAttributeId))
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 2)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		AttributesAPI.SetAttribute(PlayerRef,SoulStateAttributeId, a_value as Int)
		SetSliderOptionValueST(a_value as Int, "{0}") 
	EndEvent
	
	Event OnDefaultST()
		AttributesAPI.SetAttribute(PlayerRef,SoulStateAttributeId, 0)
		SetSliderOptionValueST(0, "{0}") 
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState



; ==============================
; Player Decisions
; ==============================
State PlayerDecisions_DebugPlayerResponseType_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(DebugPlayerResponseType)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-2, 2)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		DebugPlayerResponseType = a_value as Int
		SetSliderOptionValueST(DebugPlayerResponseType, "{0}")
	EndEvent
	
	Event OnDefaultST()
		DebugPlayerResponseType = 0
		SetSliderOptionValueST(DebugPlayerResponseType, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State PlayerDecisions_DebugPlayerDecisionType_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(DebugPlayerDecisionType)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 4)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		DebugPlayerDecisionType = a_value as Int
		SetSliderOptionValueST(DebugPlayerDecisionType, "{0}")
	EndEvent
	
	Event OnDefaultST()
		DebugPlayerDecisionType = 0
		SetSliderOptionValueST(DebugPlayerDecisionType, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State PlayerDecisions_DebugExtraPrideChange_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(DebugExtraPrideChange)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-100, 100)
		SetSliderDialogInterval(1.0)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		DebugExtraPrideChange = a_value as Int
		SetSliderOptionValueST(DebugExtraPrideChange, "{0}")
	EndEvent
	
	Event OnDefaultST()
		DebugExtraPrideChange = 0
		SetSliderOptionValueST(DebugExtraPrideChange, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State PlayerDecisions_DebugExtraSelfEsteemChange_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(DebugExtraSelfEsteemChange)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-100, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		DebugExtraSelfEsteemChange = a_value as Int
		SetSliderOptionValueST(DebugExtraSelfEsteemChange, "{0}")
	EndEvent
	
	Event OnDefaultST()
		DebugExtraSelfEsteemChange = 0
		SetSliderOptionValueST(DebugExtraSelfEsteemChange, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State PlayerDecisions_DebugPlayerDecision_ToggleId
	Event OnSelectST()
		DebugSendPlayerDecision(DebugPlayerResponseType, DebugPlayerDecisionType)
		Debug.MessageBox("Sending player decision, DebugPlayerResponseType=" + DebugPlayerResponseType + ", DebugPlayerDecisionType=" + DebugPlayerDecisionType + ".")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State PlayerDecisions_DebugPlayerDecisionWithExtraChanges_ToggleId
	Event OnSelectST()
		DebugSendPlayerDecisionWithExtraChanges(DebugPlayerResponseType, DebugPlayerDecisionType, DebugExtraPrideChange, DebugExtraSelfEsteemChange)
		Debug.MessageBox("Sending player decision (with extra changes), DebugPlayerResponseType=" + DebugPlayerResponseType + ", DebugPlayerDecisionType=" + DebugPlayerDecisionType + ".")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState



; ==============================
; Tracked NPCs
; ==============================
State TrackedNPCs_ResetTrackedNPCStats_ToggleId
	Event OnSelectST()
		ResetTrackedNPCStats()
		Debug.MessageBox("Sent events to reset tracked NPC stats.")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State TrackedNPCs_ForceNPCScan_ToggleId
	Event OnSelectST()
		dattUtility.SendParameterlessEvent("Datt_ForceRemoveNPCMonitor")
		Utility.WaitMenuMode(1)
		StorageUtil.FormListClear(None, "_datt_tracked_npcs")
		dattUtility.SendParameterlessEvent("Datt_ForceNPCScan")
		Debug.MessageBox("Sent event to refersh tracked NPCs.")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState



; ==============================
; Change Attribute
; ==============================
State ChangeAttribute_DebugChangeAttribute_ToggleID
	Event OnSelectST()
		String m_event_name
		If DebugAttributeIsMod
			m_event_name = "Datt_ModAttribute"
		Else
			m_event_name = "Datt_SetAttribute"
		EndIf
		
		String m_attribute_string
		If DebugAttributeTypeIsFetish
			m_attribute_string = (BaseAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName
		Else
			m_attribute_string = (BaseAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName
		EndIf
		Debug.MessageBox(m_event_name + " fired.\nAttribute = " + m_attribute_string + "\nValue = " + DebugAttributeValue)
		Int m_event_id = ModEvent.Create(m_event_name)
		If (m_event_id)
			ModEvent.PushForm(m_event_id, PlayerRef) 
			ModEvent.PushString(m_event_id, m_attribute_string)
			ModEvent.PushInt(m_event_id, DebugAttributeValue)
			If ModEvent.Send(m_event_id) == false
				Debug.MessageBox("Failed to send event.\nEventName = " + m_event_name)
			EndIf
		EndIf
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State ChangeAttribute_DebugAttributeType_ToggleID
	Event OnSelectST()
		DebugAttributeTypeIsFetish = !DebugAttributeTypeIsFetish
		SetToggleOptionValueST(DebugAttributeTypeIsFetish)
		DebugAttributeStringIndex = 0
		If DebugAttributeTypeIsFetish
			SetTextOptionValueST((FetishAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName, a_stateName = "ChangeAttribute_DebugAttributeString_TextID")
		ElseIf !DebugAttributeIsMod
			If DebugAttributeValue < 0
				DebugAttributeValue = 0
				SetSliderOptionValueST(DebugAttributeValue, a_stateName = "ChangeAttribute_DebugAttributeValue_SliderID")
			EndIf
			SetTextOptionValueST((BaseAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName, a_stateName = "ChangeAttribute_DebugAttributeString_TextID")
		Else
			SetTextOptionValueST((BaseAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName, a_stateName = "ChangeAttribute_DebugAttributeString_TextID")
		EndIf
	EndEvent
	
	Event OnDefaultST()
		DebugAttributeTypeIsFetish = False
		SetToggleOptionValueST(DebugAttributeTypeIsFetish)
		DebugAttributeStringIndex = 0
		If DebugAttributeTypeIsFetish
			SetTextOptionValueST((FetishAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName, a_stateName = "ChangeAttribute_DebugAttributeString_TextID")
		ElseIf !DebugAttributeIsMod
			If DebugAttributeValue < 0
				DebugAttributeValue = 0
				SetSliderOptionValueST(DebugAttributeValue, a_stateName = "ChangeAttribute_DebugAttributeValue_SliderID")
			EndIf
			SetTextOptionValueST((BaseAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName, a_stateName = "ChangeAttribute_DebugAttributeString_TextID")
		Else
			SetTextOptionValueST((BaseAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName, a_stateName = "ChangeAttribute_DebugAttributeString_TextID")
		EndIf
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State ChangeAttribute_DebugAttributeString_TextID
	Event OnSelectST()
		If DebugAttributeTypeIsFetish
			If (DebugAttributeStringIndex < FetishAttributeList.GetSize - 1)
				DebugAttributeStringIndex += 1
			Else
				DebugAttributeStringIndex = 0
			EndIf
			SetTextOptionValueST((FetishAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName)
		Else
			If (DebugAttributeStringIndex < BaseAttributeList.GetSize() - 1)
				DebugAttributeStringIndex += 1
			Else
				DebugAttributeStringIndex = 0
			EndIf
			SetTextOptionValueST((BaseAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName)
		EndIf
	EndEvent
	
	Event OnDefaultST()
		DebugAttributeStringIndex = 0
		If DebugAttributeTypeIsFetish
			SetTextOptionValueST((FetishAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName)
		Else
			SetTextOptionValueST((BaseAttributeList.GetAt(DebugAttributeStringIndex) as dattAttribute).AttributeName)
		EndIf
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State ChangeAttribute_DebugAttributeValue_SliderID
	Event OnSliderOpenST()
		SetSliderDialogStartValue(DebugAttributeValue)
		SetSliderDialogDefaultValue(0)
		If DebugAttributeTypeIsFetish
			SetSliderDialogRange(MinFetishAttributeValue, MaxFetishAttributeValue)
		ElseIf DebugAttributeIsMod
			SetSliderDialogRange(-MaxBaseAttributeValue, MaxBaseAttributeValue)
		Else
			SetSliderDialogRange(0, MaxBaseAttributeValue)
		EndIf
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		DebugAttributeValue = a_value as Int
		SetSliderOptionValueST(DebugAttributeValue, "{0}")
	EndEvent
	
	Event OnDefaultST()
		DebugAttributeValue = 0
		SetSliderOptionValueST(DebugAttributeValue, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State ChangeAttribute_DebugAttributeMod_ToggleID
	Event OnSelectST()
		DebugAttributeIsMod = !DebugAttributeIsMod
		SetToggleOptionValueST(DebugAttributeIsMod)
		
		If !DebugAttributeIsMod && !DebugAttributeTypeIsFetish
			If DebugAttributeValue < 0
				DebugAttributeValue = 0
				SetSliderOptionValueST(DebugAttributeValue, a_stateName = "ChangeAttribute_DebugAttributeValue_SliderID")
			EndIf
		EndIf
	EndEvent
	
	Event OnDefaultST()
		DebugAttributeIsMod = False
		If !DebugAttributeTypeIsFetish
			If DebugAttributeValue < 0
				DebugAttributeValue = 0
				SetSliderOptionValueST(DebugAttributeValue, a_stateName = "ChangeAttribute_DebugAttributeValue_SliderID")
			EndIf
		EndIf
		SetToggleOptionValueST(DebugAttributeIsMod)
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState



; ==============================
; Default Base Values
; ==============================
State DefaultBase_WillpowerDefault_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WillpowerAttributeDefault)
		SetSliderDialogDefaultValue(MaxBaseAttributeValue)
		SetSliderDialogRange(0, MaxBaseAttributeValue)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		WillpowerAttributeDefault = a_value as Int
		SetSliderOptionValueST(WillpowerAttributeDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		WillpowerAttributeDefault = MaxBaseAttributeValue
		SetSliderOptionValueST(WillpowerAttributeDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State DefaultBase_PrideDefault_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(PrideAttributeDefault)
		SetSliderDialogDefaultValue(MaxBaseAttributeValue)
		SetSliderDialogRange(0, MaxBaseAttributeValue)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		PrideAttributeDefault = a_value as Int
		SetSliderOptionValueST(PrideAttributeDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		PrideAttributeDefault = MaxBaseAttributeValue
		SetSliderOptionValueST(PrideAttributeDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State DefaultBase_SelfEsteemDefault_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(SelfEsteemAttributeDefault)
		SetSliderDialogDefaultValue(MaxBaseAttributeValue)
		SetSliderDialogRange(0, MaxBaseAttributeValue)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		SelfEsteemAttributeDefault = a_value as Int
		SetSliderOptionValueST(SelfEsteemAttributeDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		SelfEsteemAttributeDefault = MaxBaseAttributeValue
		SetSliderOptionValueST(SelfEsteemAttributeDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State DefaultBase_ObedienceDefault_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(ObedienceAttributeDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, MaxFetishAttributeValue)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		ObedienceAttributeDefault = a_value as Int
		SetSliderOptionValueST(ObedienceAttributeDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		ObedienceAttributeDefault = 0
		SetSliderOptionValueST(ObedienceAttributeDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State DefaultBase_SubmissivenessDefault_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(SubmissivenessAttributeDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, MaxFetishAttributeValue)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		SubmissivenessAttributeDefault = a_value as Int
		SetSliderOptionValueST(SubmissivenessAttributeDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		SubmissivenessAttributeDefault = 0
		SetSliderOptionValueST(SubmissivenessAttributeDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState



; ==============================
; Default Fetish Values
; ==============================
State DefaultFetish_NymphomaniaDefault_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(NymphomaniaAttributeDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(MinFetishAttributeValue, MaxFetishAttributeValue)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		NymphomaniaAttributeDefault = a_value as Int
		SetSliderOptionValueST(NymphomaniaAttributeDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		NymphomaniaAttributeDefault = 0
		SetSliderOptionValueST(NymphomaniaAttributeDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State DefaultFetish_MasochismAttributeDefault_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(SadismAttributeDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(MinFetishAttributeValue, MaxFetishAttributeValue)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		SadismAttributeDefault = a_value as Int
		SetSliderOptionValueST(SadismAttributeDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		SadismAttributeDefault = 0
		SetSliderOptionValueST(SadismAttributeDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State DefaultFetish_SadismAttributeDefault_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(MasochismAttributeDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(MinFetishAttributeValue, MaxFetishAttributeValue)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		MasochismAttributeDefault = a_value as Int
		SetSliderOptionValueST(MasochismAttributeDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		MasochismAttributeDefault = 0
		SetSliderOptionValueST(MasochismAttributeDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State DefaultFetish_HumiliationAttributeDefault_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(HumiliationAttributeDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(MinFetishAttributeValue, MaxFetishAttributeValue)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		HumiliationAttributeDefault = a_value as Int
		SetSliderOptionValueST(HumiliationAttributeDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		HumiliationAttributeDefault = 0
		SetSliderOptionValueST(HumiliationAttributeDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State DefaultFetish_ExhibitionismAttributeDefault_SliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(ExhibitionismAttributeDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(MinFetishAttributeValue, MaxFetishAttributeValue)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(Float a_value)
		ExhibitionismAttributeDefault = a_value as Int
		SetSliderOptionValueST(ExhibitionismAttributeDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		ExhibitionismAttributeDefault = 0
		SetSliderOptionValueST(ExhibitionismAttributeDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

; State clearChangeQueueToggleId
	; Event OnSelectST()
		; Int cleanChangeQueueEventId = ModEvent.Create("Datt_ClearChangeQueue")
		; If cleanChangeQueueEventId
			; If ModEvent.Send(cleanChangeQueueEventId) == true
				; Debug.MessageBox("Player change queue cleared.")
				; Utility.Wait(0.5)
				; SetTextOptionValueST(StorageUtil.FormListCount(None, "_datt_queued_actors"), "queuedAttributeChangesTextId")
			; Else
				; Debug.MessageBox("Player change queue was not cleared, sending the event failed. Please try again. (Do you have script lag?)")
			; EndIf
		; Else
			; Debug.MessageBox("Player change queue was not cleared, ModEvent didn't create the event properly.")
		; EndIf
	; EndEvent
	
	; Event OnHighlightST()
		;SetInfoText("$TODO")
	; EndEvent
; EndState



; ==============================
; Functions
; ==============================
Function ResetTrackedNPCStats()
	Int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	Int index = 0
	While index < npcCount 
		Form npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index)
		dattUtility.SendEventWithFormParam("Datt_SetDefaults",npc)
		index += 1
	EndWhile
EndFunction

Function PrintTrackedNPCs()
	Int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	AddHeaderOption("Tracked NPCs (" + npcCount + ")")
	If NpcScannerMutex.TryLock(1) == false
		AddTextOption("Scanning NPCs, check this menu later...", "",1)
		Return
	EndIf

	Int index = 0
	While index < npcCount 
		If index >= npcCount / 2 && npcCount % 2 == 0
			SetCursorPosition(3)
		EndIf
		Actor npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index) as Actor
		If(npc != None && npc.GetBaseObject().GetName() != "") ;precaution
			Int willpower = StorageUtil.GetIntValue(npc, WillpowerAttributeId)
			Int pride = StorageUtil.GetIntValue(npc, PrideAttributeId)
			Int selfEsteem = StorageUtil.GetIntValue(npc, SelfEsteemAttributeId)
			Int obedience = StorageUtil.GetIntValue(npc, ObedienceAttributeId)
			Int submissiveness = StorageUtil.GetIntValue(npc, SubmissivenessAttributeId)

			String attributeValues = "w:" + willpower + ",p:" + pride + ",se:" + selfEsteem + ",o:" + obedience + ",sub:" + submissiveness

			AddHeaderOption(npc.GetBaseObject().GetName())
			AddTextOption("Attr:", attributeValues,1)
		Else 
			MiscUtil.PrintConsole("[Datt - Warning] Very weird, found non-actor in _datt_tracked_npcs list. This should be reported! (npc.GetName() ==" + npc.GetName() + ")")
			StorageUtil.FormListRemoveAt(None, "_datt_tracked_npcs", index)
		EndIf
		index += 1
	EndWhile

	;just in case
	StorageUtil.IntListClear(None, "_datt_tracked_npcs_mcm_id_list")
	StorageUtil.FormListClear(None, "_datt_tracked_npcs_mcm_actor_list") 

	NpcScannerMutex.Unlock()
EndFunction

Function DebugSendPlayerDecision(Int playerResponseType, Int decisionType)
	Int debugPlayerDecisionEventId = ModEvent.Create(PlayerDecisionEventName1)
	If(debugPlayerDecisionEventId)
		Debug.Notification("Devious Attributes -> debug.SendPlayerDecision()")
		ModEvent.PushInt(debugPlayerDecisionEventId, playerResponseType)
		ModEvent.PushInt(debugPlayerDecisionEventId, decisionType)
		ModEvent.Send(debugPlayerDecisionEventId)
	Else
		Debug.MessageBox("Devious Attributes -> debug.SendPlayerDecision() -> debugPlayerDecisionEventId not initialized!")
	EndIf
EndFunction

Function DebugSendPlayerDecisionWithExtraChanges(Int playerResponseType, Int decisionType,Int prideExtraChange, Int selfEsteemExtraChange)
	Int debugPlayerDecisionWithExtraEventId = ModEvent.Create(PlayerDecisionWithExtraEventName1)
	If(debugPlayerDecisionWithExtraEventId)
		Debug.Notification("Devious Attributes -> debug.DebugSendPlayerDecisionWithExtraChanges()")

		ModEvent.PushInt(debugPlayerDecisionWithExtraEventId, playerResponseType)
		ModEvent.PushInt(debugPlayerDecisionWithExtraEventId, decisionType)
		ModEvent.PushInt(debugPlayerDecisionWithExtraEventId, prideExtraChange)
		ModEvent.PushInt(debugPlayerDecisionWithExtraEventId, selfEsteemExtraChange)
		ModEvent.Send(debugPlayerDecisionWithExtraEventId)
	Else
		Debug.MessageBox("Devious Attributes -> debug.DebugSendPlayerDecisionWithExtraChanges() -> debugPlayerDecisionWithExtraEventId not initialized!")
	EndIf
EndFunction



; ==============================
; Properties
; ==============================
Int Property ArousalThresholdToIncreaseFetish Hidden
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_ArousalThresholdToIncreaseFetish")
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_ArousalThresholdToIncreaseFetish",value)
	EndFunction
EndProperty

Int Property FetishIncrementPerDecision Hidden
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_FetishIncrementPerDecision")
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_FetishIncrementPerDecision",value)
	EndFunction
EndProperty

Int Property PrideChangePerDecision Hidden
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_PrideChangePerDecision")
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_PrideChangePerDecision",value)
	EndFunction
EndProperty

Int Property SelfEsteemChangePerDecision Hidden
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_SelfEsteemChangePerDecision")
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_SelfEsteemChangePerDecision",value)
	EndFunction
EndProperty

Int Property ObedienceChangePerDecision Hidden
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_ObedienceChangePerDecision")
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_ObedienceChangePerDecision",value)
	EndFunction
EndProperty

Int Property WillpowerBaseDecisionCost Hidden
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_WillpowerBaseDecisionCost")
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_WillpowerBaseDecisionCost",value)
	EndFunction
EndProperty 

Int Property DebugPlayerDecisionType Hidden
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_DebugPlayerDecisionType")
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_DebugPlayerDecisionType",value)
	EndFunction
EndProperty

Int Property DebugPlayerResponseType Hidden
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_DebugPlayerResponseType")
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_DebugPlayerResponseType",value)
	EndFunction
EndProperty

Int Property DebugExtraPrideChange Hidden
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_DebugExtraPrideChange")
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_DebugExtraPrideChange",value)
	EndFunction
EndProperty

Int Property DebugExtraSelfEsteemChange Hidden
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_DebugExtraSelfEsteemChange")
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_DebugExtraSelfEsteemChange",value)
	EndFunction
EndProperty 

Int Property WillpowerBaseChange Hidden
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_willpower_base_change",10)
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_willpower_base_change",value)
	EndFunction
EndProperty

Int Property NymphoIncreasePerConsensual Hidden
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_NymphoIncreasePerConsensual", 2)
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_NymphoIncreasePerConsensual", value)
	EndFunction
EndProperty

Float Property IntervalBetweenSexToIncreaseNymphoHours Hidden
	Float Function Get()
		return StorageUtil.GetFloatValue(None, "_datt_IntervalBetweenSexToIncreaseNymphoHours", 6)
	EndFunction
	Function Set(Float value)
		StorageUtil.SetFloatValue(None, "_datt_IntervalBetweenSexToIncreaseNymphoHours", value)
	EndFunction
EndProperty

Int Property WillpowerChangePerOrgasm Hidden
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_willpowerChangePerOrgasm", 10)
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_willpowerChangePerOrgasm", value)
	EndFunction
EndProperty

Int Property WillpowerChangePerRape Hidden
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_willpowerChangePerRape", 25)
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_willpowerChangePerRape", value)
	EndFunction
EndProperty

Int Property PrideChangePerRape Hidden
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_prideChangePerRape", 5)
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_prideChangePerRape", value)
	EndFunction
EndProperty

Int Property SelfEsteemChangePerRape Hidden
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_SelfEsteemChangePerRape", 2)
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_SelfEsteemChangePerRape", value)
	EndFunction
EndProperty

Float Property TraumaStageDecreaseTime Hidden ;in hame hours
	Float Function Get()
		return StorageUtil.GetFloatValue(None, "_datt_traumaStageDecreaseTime", 12.0)
	EndFunction
	Function Set(Float value)
		StorageUtil.SetFloatValue(None, "_datt_traumaStageDecreaseTime", value)
	EndFunction
EndProperty

Int Property FrequentEventUpdateLatency Hidden
	Int Function Get()
		Int value = StorageUtil.GetIntValue(None, "_datt_frequentEventUpdateLatency")
		If value == 0
			value = 30 ;sec
		EndIf
		return value
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_frequentEventUpdateLatency",value)
	EndFunction
EndProperty

Int Property PeriodicEventUpdateLatencyHours Hidden
	Int Function Get()
		Int value = StorageUtil.GetIntValue(None, "_datt_periodicEventUpdateLatency")
		If value == 0
			value = 12 ;hours
		EndIf
		return value
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_periodicEventUpdateLatency",value)
	EndFunction
EndProperty

Int Property PrideChangePerPlayerKill Hidden
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_PrideChangePerPlayerKill", 5)
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_PrideChangePerPlayerKill",value)
	EndFunction
EndProperty

Int Property AttributeChangePerStealOrPickpocket Hidden
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_AttributeChangePerStealOrPickpocket", 3)
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_AttributeChangePerStealOrPickpocket",value)
	EndFunction
EndProperty

Int Property NPCScannerTickSec Hidden
	Int Function Get()
		Int value = StorageUtil.GetIntValue(None, "_datt_NPCScannerTickSec")
		If value == 0
			value = 15 ;sec
		EndIf
		return value
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_NPCScannerTickSec",value)
	EndFunction
EndProperty

Int Property PeriodicSelfEsteemIncrease Hidden
	Int Function Get()
		Int value = StorageUtil.GetIntValue(None, "_datt_PeriodicSelfEsteemIncrease")
		If value == 0
			value = 5
		EndIf
		return value
	EndFunction
	Function Set(Int value)
		StorageUtil.SetIntValue(None, "_datt_PeriodicSelfEsteemIncrease",value)
	EndFunction
EndProperty

Bool Property EnableAttributeEffects Hidden
	Bool Function Get()
		Int value = dattEnableAttributeEffects.GetValueInt()
		return value == 1
	EndFunction
	Function Set(bool value)
		if(value == true)
			dattEnableAttributeEffects.SetValueInt(1)
		Else
			dattEnableAttributeEffects.SetValueInt(0)
		EndIf
	EndFunction
EndProperty



; ==============================
; Debug Change Attribute Properties
; ==============================

Bool Property DebugAttributeTypeIsFetish = False Auto Hidden
Int Property DebugAttributeStringIndex = 0 Auto Hidden
Int Property DebugAttributeValue = 0 Auto Hidden
Bool Property DebugAttributeIsMod = false Auto Hidden
>>>>>>> origin/master



; ==============================
; Max/Max Attribute Values
; ==============================

Int Property MaxBaseAttributeValue = 100 AutoReadonly Hidden
Int Property MinBaseAttributeValue = 0 AutoReadonly Hidden
Int Property MaxFetishAttributeValue = 100 AutoReadonly Hidden
Int Property MinFetishAttributeValue = -100 AutoReadonly Hidden



; ==============================
; Default Attribute Values
; ==============================

; Base Attributes
Int Property WillpowerAttributeDefault = 100 Auto Hidden

; Fetish Attributes
Int Property NymphomaniaAttributeDefault = 0 Auto Hidden

; Calculated Attributes
; None here, they are being calculated (duh)

; Misc Attributes
; None here, all Misc Attributes start with a value of 0



; ==============================
; Attribute IDs for StorageUtil
; ==============================

; Base Attributes
String Property WillpowerAttributeName = "Datt_Willpower" AutoReadonly Hidden
; Base Attributes States
String Property WillpowerAttributeStateName = "Datt_Willpower_State" AutoReadonly Hidden

; Fetish Attributes
<<<<<<< HEAD
String Property NymphomaniaAttributeName = "Datt_Nymphomania" AutoReadonly Hidden
; Fetish Attributes States
String Property NymphomaniaAttributeStateName = "Datt_Nymphomaniac_State" AutoReadonly Hidden
=======
String Property NymphomaniaAttributeId = "_Datt_Nymphomania" AutoReadonly Hidden
String Property MasochismAttributeId = "_Datt_Masochism" AutoReadonly Hidden
String Property SadismAttributeId = "_Datt_Sadism" AutoReadonly Hidden
String Property HumiliationAttributeId = "_Datt_Humiliation" AutoReadonly Hidden
String Property ExhibitionismAttributeId = "_Datt_Exhibitionism" AutoReadonly Hidden

; Legacy Fetish Attributes
String Property NymphomaniaLegacyAttributeId = "_Datt_Nymphomaniac" AutoReadonly Hidden
String Property MasochismLegacyAttributeId = "_Datt_Masochist" AutoReadonly Hidden
String Property SadismLegacyAttributeId = "_Datt_Sadist" AutoReadonly Hidden
String Property HumiliationLegacyAttributeId = "_Datt_HumiliationLover" AutoReadonly Hidden
String Property ExhibitionismLegacyAttributeId = "_Datt_Exhibitionist" AutoReadonly Hidden
>>>>>>> origin/master

; Calculated Attributes
String Property SubmissivenessAttributeName = "Datt_Submissiveness" AutoReadonly Hidden
; Calculated Attributes States
String Property SubmissivenessAttributeStateName = "Datt_Submissiveness_State" AutoReadonly Hidden

<<<<<<< HEAD
; Misc Attributes
String Property SlaveAbusivenessStateAttributeName = "Datt_Soul_State" AutoReadonly Hidden
=======
; Fetish Attributes States
String Property NymphomaniaAttributeStateId = "_Datt_Nymphomaniac_State" AutoReadonly Hidden
String Property MasochismAttributeStateId = "_Datt_Masochist_State" AutoReadonly Hidden
String Property SadismAttributeStateId = "_Datt_Sadist_State" AutoReadonly Hidden
String Property HumiliationAttributeStateId = "_Datt_HumiliationLover_State" AutoReadonly Hidden
String Property ExhibitionismAttributeStateId = "_Datt_Exhibitionist_State" AutoReadonly Hidden
>>>>>>> origin/master



; ==============================
; Event Names
; ==============================

String Property PlayerDecisionEventName1 = "Datt_PlayerDecision1" AutoReadonly Hidden
String Property PlayerDecisionEventName2 = "Datt_PlayerDecision2" AutoReadonly Hidden
String Property PlayerDecisionEventName3 = "Datt_PlayerDecision3" AutoReadonly Hidden
String Property PlayerDecisionEventName4 = "Datt_PlayerDecision4" AutoReadonly Hidden

String Property PlayerDecisionWithExtraEventName1 = "Datt_PlayerDecision1WithExtra" AutoReadonly Hidden
String Property PlayerDecisionWithExtraEventName2 = "Datt_PlayerDecision2WithExtra" AutoReadonly Hidden
String Property PlayerDecisionWithExtraEventName3 = "Datt_PlayerDecision3WithExtra" AutoReadonly Hidden
String Property PlayerDecisionWithExtraEventName4 = "Datt_PlayerDecision4WithExtra" AutoReadonly Hidden

String Property PlayerSlaveAbusivenessStateChangeEventName = "Datt_PlayerSlaveAbusivenessStateChange" AutoReadonly Hidden

; The Current Attribute Version... Increases whenever this mod introduces new Attributes.
Int Property CurrentVersionAttributeFaction Auto

; ==============================
; Factions
; ==============================

; Used to determine if an actor's attributes have been initialized. 
Faction Property InitVersionAttributeFaction Auto

; Base Attributes
Faction Property WillpowerAttributeFaction Auto

; Fetish Attributes
Faction Property NymphomaniaAttributeFaction Auto

; Calculated Attributes
Faction Property SubmissivenessAttributeFaction Auto

; Misc Attributes
Faction Property SlaveAbusivenessStateAttributeFaction Auto

GlobalVariable Property HateAttributeValue Auto				; -80
GlobalVariable Property StrongDislikeAttributeValue Auto	; -50
GlobalVariable Property DislikeAttributeValue Auto			; -20
GlobalVariable Property LikeAttributeValue Auto				; +20
GlobalVariable Property StrongLikeAttributeValue Auto		; +50
GlobalVariable Property LoveAttributeValue Auto				; +80