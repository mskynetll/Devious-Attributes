Scriptname dattConfigQuest Extends SKI_ConfigBase

Actor Property PlayerRef Auto

String Property SettingsPageName = "Settings" AutoReadonly Hidden
String Property AttributesPageName = "Attributes" AutoReadonly Hidden
String Property TrackedNPCsPageName = "Tracked NPCs" AutoReadonly Hidden
String Property DebugPageName = "Debug" AutoReadonly Hidden
String Property AdvancedPageName = "Advanced Options" AutoReadonly Hidden

GlobalVariable Property dattEnableAttributeEffects Auto
dattAttributesAPIQuest Property AttributesAPI Auto
Bool Property IsLogging Auto

dattMutex Property NpcScannerMutex Auto

Event OnConfigInit()
	Pages = new string[5]
	Pages[0] = SettingsPageName
	Pages[1] = AttributesPageName
	Pages[2] = TrackedNPCsPageName
	Pages[3] = DebugPageName
	Pages[4] = AdvancedPageName
EndEvent

Event OnPageReset(string page)
{Called when a new page is selected, including the initial empty page}
	SetCursorFillMode(TOP_TO_BOTTOM) 
	If (page == SettingsPageName)
		SetCursorPosition(0)
		AddHeaderOption("General")
		AddToggleOptionST("enableAttributeEffectsToggleId", "Enable Attribute Effects", EnableAttributeEffects)
		AddSliderOptionST("frequentEventUpdateLatencySliderId", "Frequent Attr. Changes", FrequentEventUpdateLatency as float, "Each {0} hours")
		AddSliderOptionST("periodicEventUpdateLatencySliderId", "Periodic Attr. Changes", PeriodicEventUpdateLatencyHours as float, "Each {0} hours")
		AddSliderOptionST("npcScannerTickSliderId", "NPC Scanning Tick", NPCScannerTickSec, "Each {0} sec.")
		AddSliderOptionST("traumaStageDecreaseTimeSliderId", "Trauma Stage Decrease", TraumaStageDecreaseTime, "Each {1} hours")
		AddSliderOptionST("willpowerBaseChangeSliderId", "Willpower/tick", WillpowerBaseChange, "{0}")
		AddSliderOptionST("willpowerChangePerOrgasmSliderId", "Willpower/orgasm", WillpowerChangePerOrgasm, "{0} per orgasm")
		AddSliderOptionST("willpowerChangePerRapeSliderId", "Willpower/rape", WillpowerChangePerRape, "{0} per rape")
		AddSliderOptionST("prideChangePerRapeSliderId", "Pride/rape", PrideChangePerRape, "{0} per rape")
		AddSliderOptionST("selfEsteemChangePerRapeSliderId", "Self-Esteem/rape", SelfEsteemChangePerRape, "{0} per rape") 
		AddSliderOptionST("intervalBetweenSexToIncreaseNymphoHoursSliderId", "Interval/increase nympho", IntervalBetweenSexToIncreaseNymphoHours, "Less than {0} hours")
		AddSliderOptionST("nymphoIncreasePerConsensualSliderId" ,"Nympho incr/consensual", NymphoIncreasePerConsensual, "{0}")
		AddSliderOptionST("prideChangePerPlayerKillSliderId", "Pride/kill", PrideChangePerPlayerKill, "{0} per kill")
		AddSliderOptionST("attributeChangePerStealOrPickpocketSliderId", "Pride,Self-Esteem/theft", AttributeChangePerStealOrPickpocket, "{0} per pickpocket")
		AddSliderOptionST("periodicSelfEsteemIncreaseSliderId", "Self-esteem/periodic", PeriodicSelfEsteemIncrease, "Increase by {0}")
		
		SetCursorPosition(1)
		AddHeaderOption("Decisions")
		AddSliderOptionST("willpowerBaseDecisionCostSliderId", "Willpower base cost", WillpowerBaseDecisionCost, "{0}")
		AddSliderOptionST("prideChangePerDecisionSliderId", "Pride change", PrideChangePerDecision,"{0}")
		AddSliderOptionST("selfEsteemChangePerDecisionSliderId", "Self-Esteem change", SelfEsteemChangePerDecision,"{0}")
		AddSliderOptionST("obedienceChangePerDecisionSliderId", "Obedience change", ObedienceChangePerDecision,"{0}")
		AddSliderOptionST("fetishIncrementPerDecisionSliderId", "Fetish increment", FetishIncrementPerDecision, "{0}")
		AddSliderOptionST("arousalThresholdToIncreaseFetishSliderId", "Arousal threshold - fetishes", ArousalThresholdToIncreaseFetish) 
		
	ElseIf (page == TrackedNPCsPageName)
		PrintTrackedNPCs()
	ElseIf (page == AttributesPageName)
		SetCursorPosition(0)
		AddHeaderOption("Player Attributes")
		
		AddTextOptionST("WillpowerTextID", "Willpower", PlayerRef.GetFactionRank(dattWillpower), 1)
		AddTextOptionST("SelfEsteemTextID", "Self-Esteem", PlayerRef.GetFactionRank(dattSelfEsteem), 1)
		AddTextOptionST("PrideTextID", "Pride", PlayerRef.GetFactionRank(dattPride), 1)
		AddTextOptionST("ObedienceTextID", "Obedience", PlayerRef.GetFactionRank(dattObedience), 1)
		AddTextOptionST("SubmissivenessTextID", "Submissiveness", PlayerRef.GetFactionRank(dattSubmissive), 1)
		
		int soulState = AttributesAPI.GetAttribute(PlayerRef, SoulStateAttributeId)
		AddTextOptionST("SoulStateTextID", "Soul State", "Free(0)",1)
		If(soulState == 0)
			SetTextOptionValueST("Free(0)", "SoulStateTextID")
		ElseIf(soulState == 1)
			SetTextOptionValueST("Willing Sub(1)", "SoulStateTextID")
		ElseIf(soulState == 2)
			SetTextOptionValueST("Forced Slave(2)", "SoulStateTextID")
		EndIf
		
		SetCursorPosition(1)
		AddHeaderOption("Player Traits")
		float humiliation = StorageUtil.GetIntValue(PlayerRef as Form, HumiliationLoverAttributeId) as float 
		float exhibitionist = StorageUtil.GetIntValue(PlayerRef as Form, ExhibitionistAttributeId) as float 
		float sadist = StorageUtil.GetIntValue(PlayerRef as Form, SadistAttributeId) as float 
		float masochist = StorageUtil.GetIntValue(PlayerRef as Form, MasochistAttributeId) as float
		float nympho = StorageUtil.GetIntValue(PlayerRef as Form, NymphomaniacAttributeId) as float
		
		AddTextOptionST("HumiliationLoverTextId", "Humiliation Lover", humiliation, 1)
		AddTextOptionST("ExhibitionistTextId", "Exhibitionist", exhibitionist, 1)
		AddTextOptionST("MasochistTextId", "Masochist", masochist, 1)
		AddTextOptionST("SadistTextId", "Sadist", sadist, 1)
		AddTextOptionST("NymphoTextId", "Nympho", nympho, 1)
		
		AddHeaderOption("Trauma")
		AddTextOptionST("Rape Trauma Level", "Rape Trauma Level", PlayerRef.GetFactionRank(dattRapeTraumaFaction) / 10, 1)
	ElseIf (page == DebugPageName)
		SetCursorPosition(0)
		AddHeaderOption("Misc")
		AddToggleOptionST("showDebugMessagesToggleId", "Turn on/off logging", IsLogging)
		AddToggleOptionST("resetPlayerAttribtesToggleId", "Reset player attributes", false)
		AddToggleOptionST("simulateRapeToggleId", "Simulate Rape (2 actors)", false)
		AddSliderOptionST("manualSoulStateSliderId", "Soul State", AttributesAPI.GetAttribute(PlayerRef,SoulStateAttributeId) as float, "{0}")
		
		AddHeaderOption("Player Decisions")
		AddSliderOptionST("debugPlayerResponseTypeSliderId", "Response type", DebugPlayerResponseType, "{0}")
		AddSliderOptionST("debugPlayerDecisionTypeSliderId", "Decision type", DebugPlayerDecisionType, "{0}")
		AddSliderOptionST("debugExtraPrideChangeSliderId", "Extra pride change", DebugExtraPrideChange, "{0}")
		AddSliderOptionST("debugExtraSelfEsteemChangeSliderId", "Extra self-esteem change", DebugExtraSelfEsteemChange, "{0}")
		AddToggleOptionST("debugPlayerDecisionToggleId", "Simulate player decision", false)
		AddToggleOptionST("debugPlayerDecisionWithExtraChangesToggleId", "Simulate player decision(extra changes)", false)
		
		SetCursorPosition(1)
		AddHeaderOption("Internal Stuff")
		int queuedChangeCount = StorageUtil.FormListCount(None, "_datt_queued_actors")
		AddTextOptionST("queuedAttributeChangesTextId", "Queued Attribute Changes", queuedChangeCount, 1)
		AddToggleOptionST("clearChangeQueueToggleId", "Clean Attribute Change Queue", false)
		
		AddHeaderOption("Tracked NPCs")
		AddToggleOptionST("resetTrackedNPCStatsToggleId", "Reset tracked NPC stats", false)
		AddToggleOptionST("forceNPCScanToggleId", "Refresh Tracked NPCs", false)
	ElseIf (page == AdvancedPageName)
		SetCursorPosition(0)
		AddHeaderOption("Default Fetish Values")
		AddSliderOptionST("HumiliationDefaultSliderId", "Humiliation Lover Default Value", HumiliationDefault as float, "{0}")
		AddSliderOptionST("ExhibitionistDefaultSliderId", "Exhibitionist Default Value", ExhibitionistDefault as float, "{0}")
		AddSliderOptionST("MasochistDefaultSliderId", "Masochist Default Value", SadistDefault as float, "{0}")
		AddSliderOptionST("SadistDefaultSliderId", "Sadist Default Value", MasochistDefault as float, "{0}")
		AddSliderOptionST("NymphoDefaultSliderId", "Nymphomaniac Default Value", NymphomanicDefault as float, "{0}")
	EndIf
EndEvent

; ==============================
; TOGGLES
; ==============================
State enableAttributeEffectsToggleId
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

State showDebugMessagesToggleId
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

State resetPlayerAttribtesToggleId
	Event OnSelectST()
		int resetToDefaultsEventId = ModEvent.Create("Datt_SetDefaults")
		If resetToDefaultsEventId
			ModEvent.PushForm(resetToDefaultsEventId, PlayerRef as Form)
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

State simulateRapeToggleId
	Event OnSelectST()
		dattUtility.SendEventWithFormAndIntParam("Datt_Simulate_Rape", PlayerRef as Form, 2)
		Debug.MessageBox("Datt_Simulate_Rape event sent for PC.")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State debugPlayerDecisionToggleId
	Event OnSelectST()
		DebugSendPlayerDecision(DebugPlayerResponseType, DebugPlayerDecisionType)
		Debug.MessageBox("Sending player decision, DebugPlayerResponseType=" + DebugPlayerResponseType + ", DebugPlayerDecisionType=" + DebugPlayerDecisionType + ".")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State debugPlayerDecisionWithExtraChangesToggleId
	Event OnSelectST()
		DebugSendPlayerDecisionWithExtraChanges(DebugPlayerResponseType, DebugPlayerDecisionType, DebugExtraPrideChange, DebugExtraSelfEsteemChange)
		Debug.MessageBox("Sending player decision (with extra changes), DebugPlayerResponseType=" + DebugPlayerResponseType + ", DebugPlayerDecisionType=" + DebugPlayerDecisionType + ".")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State clearChangeQueueToggleId
	Event OnSelectST()
		int cleanChangeQueueEventId = ModEvent.Create("Datt_ClearChangeQueue")
		If cleanChangeQueueEventId
			If ModEvent.Send(cleanChangeQueueEventId) == true
				Debug.MessageBox("Player change queue cleared.")
				Utility.Wait(0.5)
				SetTextOptionValueST(StorageUtil.FormListCount(None, "_datt_queued_actors"), "queuedAttributeChangesTextId")
			Else
				Debug.MessageBox("Player change queue was not cleared, sending the event failed. Please try again. (Do you have script lag?)")
			EndIf
		Else
			Debug.MessageBox("Player change queue was not cleared, ModEvent didn't create the event properly.")
		EndIf
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State resetTrackedNPCStatsToggleId
	Event OnSelectST()
		ResetTrackedNPCStats()
		Debug.MessageBox("Sent events to reset tracked NPC stats.")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State forceNPCScanToggleId
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
; SLIDERS
; ==============================
State frequentEventUpdateLatencySliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(FrequentEventUpdateLatency)
		SetSliderDialogDefaultValue(30)
		SetSliderDialogRange(1, 360) 
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		FrequentEventUpdateLatency = a_value as int
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

State periodicEventUpdateLatencySliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(PeriodicEventUpdateLatencyHours)
		SetSliderDialogDefaultValue(12)
		SetSliderDialogRange(1, 360) 
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		PeriodicEventUpdateLatencyHours = a_value as int
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

State npcScannerTickSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(NPCScannerTickSec)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(1, 30) 
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		NPCScannerTickSec = a_value as int
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

State traumaStageDecreaseTimeSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(TraumaStageDecreaseTime)
		SetSliderDialogDefaultValue(12.0)
		SetSliderDialogRange(1.0, 24.0)
		SetSliderDialogInterval(0.5)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
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

State willpowerBaseChangeSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WillpowerBaseChange)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(2, 50)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		WillpowerBaseChange = a_value as int
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

State willpowerChangePerOrgasmSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WillpowerChangePerOrgasm)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(7, 100) 
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		WillpowerChangePerOrgasm = a_value as int
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

State willpowerChangePerRapeSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WillpowerChangePerRape)
		SetSliderDialogDefaultValue(10)
		SetSliderDialogRange(0, 100) 
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		WillpowerChangePerRape = a_value as int
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

State prideChangePerRapeSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(PrideChangePerRape)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		PrideChangePerRape = a_value as int
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

State selfEsteemChangePerRapeSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(SelfEsteemChangePerRape)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		SelfEsteemChangePerRape = a_value as int
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

State intervalBetweenSexToIncreaseNymphoHoursSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(IntervalBetweenSexToIncreaseNymphoHours)
		SetSliderDialogDefaultValue(6)
		SetSliderDialogRange(1, 24)
		SetSliderDialogInterval(1.0)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
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

State nymphoIncreasePerConsensualSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(NymphoIncreasePerConsensual)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(1, 25)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		NymphoIncreasePerConsensual = a_value as int
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

State prideChangePerPlayerKillSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(PrideChangePerPlayerKill)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		PrideChangePerPlayerKill = a_value as int
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

State attributeChangePerStealOrPickpocketSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(AttributeChangePerStealOrPickpocket)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		AttributeChangePerStealOrPickpocket = a_value as int
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

State periodicSelfEsteemIncreaseSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(PeriodicSelfEsteemIncrease)
		SetSliderDialogDefaultValue(5)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		PeriodicSelfEsteemIncrease = a_value as int
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

State willpowerBaseDecisionCostSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(WillpowerBaseDecisionCost)
		SetSliderDialogDefaultValue(15)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		WillpowerBaseDecisionCost = a_value as int
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

State prideChangePerDecisionSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(PrideChangePerDecision)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		PrideChangePerDecision = a_value as int
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

State selfEsteemChangePerDecisionSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(SelfEsteemChangePerDecision)
		SetSliderDialogDefaultValue(1)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		SelfEsteemChangePerDecision = a_value as int
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

State obedienceChangePerDecisionSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(ObedienceChangePerDecision)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(1, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		ObedienceChangePerDecision = a_value as int
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

State fetishIncrementPerDecisionSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(FetishIncrementPerDecision)
		SetSliderDialogDefaultValue(2)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		FetishIncrementPerDecision = a_value as int
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

State arousalThresholdToIncreaseFetishSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(ArousalThresholdToIncreaseFetish)
		SetSliderDialogDefaultValue(85)
		SetSliderDialogRange(0, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		ArousalThresholdToIncreaseFetish = a_value as int
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

State manualSoulStateSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(AttributesAPI.GetAttribute(PlayerRef,SoulStateAttributeId))
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 2)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		AttributesAPI.SetAttribute(PlayerRef,SoulStateAttributeId, a_value as int)
		SetSliderOptionValueST(a_value as int, "{0}") 
	EndEvent
	
	Event OnDefaultST()
		AttributesAPI.SetAttribute(PlayerRef,SoulStateAttributeId, 0)
		SetSliderOptionValueST(0, "{0}") 
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State debugPlayerResponseTypeSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(DebugPlayerResponseType)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-2, 2)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		DebugPlayerResponseType = a_value as int
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

State debugPlayerDecisionTypeSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(DebugPlayerDecisionType)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 4)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		DebugPlayerDecisionType = a_value as int
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

State debugExtraPrideChangeSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(DebugExtraPrideChange)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-100, 100)
		SetSliderDialogInterval(1.0)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		DebugExtraPrideChange = a_value as int
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

State debugExtraSelfEsteemChangeSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(DebugExtraSelfEsteemChange)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-100, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		DebugExtraSelfEsteemChange = a_value as int
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

State HumiliationDefaultSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(HumiliationDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-100, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		HumiliationDefault = a_value as int
		SetSliderOptionValueST(HumiliationDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		HumiliationDefault = 0
		SetSliderOptionValueST(HumiliationDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State ExhibitionistDefaultSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(ExhibitionistDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-100, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		ExhibitionistDefault = a_value as int
		SetSliderOptionValueST(ExhibitionistDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		ExhibitionistDefault = 0
		SetSliderOptionValueST(ExhibitionistDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State MasochistDefaultSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(SadistDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-100, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		SadistDefault = a_value as int
		SetSliderOptionValueST(SadistDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		SadistDefault = 0
		SetSliderOptionValueST(SadistDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State SadistDefaultSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(MasochistDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-100, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		MasochistDefault = a_value as int
		SetSliderOptionValueST(MasochistDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		MasochistDefault = 0
		SetSliderOptionValueST(MasochistDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState

State NymphoDefaultSliderId
	Event OnSliderOpenST()
		SetSliderDialogStartValue(NymphomanicDefault)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(-100, 100)
		SetSliderDialogInterval(1)
	EndEvent
	
	Event OnSliderAcceptST(float a_value)
		NymphomanicDefault = a_value as int
		SetSliderOptionValueST(NymphomanicDefault, "{0}")
	EndEvent
	
	Event OnDefaultST()
		NymphomanicDefault = 0
		SetSliderOptionValueST(NymphomanicDefault, "{0}")
	EndEvent
	
	Event OnHighlightST()
		;SetInfoText("$TODO")
	EndEvent
EndState



; ==============================
; Functions
; ==============================
Function ResetTrackedNPCStats()
	int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	int index = 0
	While index < npcCount 
		Form npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index)
		dattUtility.SendEventWithFormParam("Datt_SetDefaults",npc)
		index += 1
	EndWhile
EndFunction

Function PrintTrackedNPCs()
	int npcCount = StorageUtil.FormListCount(None, "_datt_tracked_npcs")
	AddHeaderOption("Tracked NPCs (" + npcCount + ")")
	If NpcScannerMutex.TryLock(1) == false
		AddTextOption("Scanning NPCs, check this menu later...", "",1)
		Return
	EndIf

	int index = 0
	While index < npcCount 
		Actor npc = StorageUtil.FormListGet(None, "_datt_tracked_npcs", index) as Actor
		If(npc != None && npc.GetBaseObject().GetName() != "") ;precaution
			int willpower = StorageUtil.GetIntValue(npc, WillpowerAttributeId)
			int pride = StorageUtil.GetIntValue(npc, PrideAttributeId)
			int selfEsteem = StorageUtil.GetIntValue(npc, SelfEsteemAttributeId)
			int obedience = StorageUtil.GetIntValue(npc, ObedienceAttributeId)
			int submissiveness = StorageUtil.GetIntValue(npc, SubmissivenessAttributeId)

			string attributeValues = "w:" + willpower + ",p:" + pride + ",se:" + selfEsteem + ",o:" + obedience + ",sub:" + submissiveness

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



Function DebugSendPlayerDecision(int playerResponseType, int decisionType)
	int debugPlayerDecisionEventId = ModEvent.Create(PlayerDecisionEventName1)
	If(debugPlayerDecisionEventId)
		Debug.Notification("Devious Attributes -> debug.SendPlayerDecision()")

		ModEvent.PushInt(debugPlayerDecisionEventId, playerResponseType)
		ModEvent.PushInt(debugPlayerDecisionEventId, decisionType)
		ModEvent.Send(debugPlayerDecisionEventId)
	Else
		Debug.MessageBox("Devious Attributes -> debug.SendPlayerDecision() -> debugPlayerDecisionEventId not initialized!")
	EndIf
EndFunction

Function DebugSendPlayerDecisionWithExtraChanges(int playerResponseType, int decisionType,int prideExtraChange, int selfEsteemExtraChange)
	int debugPlayerDecisionWithExtraEventId = ModEvent.Create(PlayerDecisionWithExtraEventName1)
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
Int Property ArousalThresholdToIncreaseFetish
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_ArousalThresholdToIncreaseFetish")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_ArousalThresholdToIncreaseFetish",value)
	EndFunction
EndProperty

Int Property FetishIncrementPerDecision
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_FetishIncrementPerDecision")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_FetishIncrementPerDecision",value)
	EndFunction
EndProperty

Int Property PrideChangePerDecision
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_PrideChangePerDecision")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_PrideChangePerDecision",value)
	EndFunction
EndProperty

Int Property SelfEsteemChangePerDecision
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_SelfEsteemChangePerDecision")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_SelfEsteemChangePerDecision",value)
	EndFunction
EndProperty

Int Property ObedienceChangePerDecision
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_ObedienceChangePerDecision")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_ObedienceChangePerDecision",value)
	EndFunction
EndProperty

Int Property WillpowerBaseDecisionCost
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_WillpowerBaseDecisionCost")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_WillpowerBaseDecisionCost",value)
	EndFunction
EndProperty 

Int Property DebugPlayerDecisionType
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_DebugPlayerDecisionType")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_DebugPlayerDecisionType",value)
	EndFunction
EndProperty

Int Property DebugPlayerResponseType
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_DebugPlayerResponseType")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_DebugPlayerResponseType",value)
	EndFunction
EndProperty

Int Property DebugExtraPrideChange
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_DebugExtraPrideChange")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_DebugExtraPrideChange",value)
	EndFunction
EndProperty

Int Property DebugExtraSelfEsteemChange
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_DebugExtraSelfEsteemChange")
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_DebugExtraSelfEsteemChange",value)
	EndFunction
EndProperty 

Int Property WillpowerBaseChange
	Int Function Get()
		Return StorageUtil.GetIntValue(None, "_datt_willpower_base_change",10)
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_willpower_base_change",value)
	EndFunction
EndProperty

Int Property NymphoIncreasePerConsensual
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_NymphoIncreasePerConsensual", 2)
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_NymphoIncreasePerConsensual", value)
	EndFunction
EndProperty

Float Property IntervalBetweenSexToIncreaseNymphoHours
	Float Function Get()
		return StorageUtil.GetFloatValue(None, "_datt_IntervalBetweenSexToIncreaseNymphoHours", 6)
	EndFunction
	Function Set(Float value)
		StorageUtil.SetFloatValue(None, "_datt_IntervalBetweenSexToIncreaseNymphoHours", value)
	EndFunction
EndProperty

Int Property WillpowerChangePerOrgasm
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_willpowerChangePerOrgasm", 10)
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_willpowerChangePerOrgasm", value)
	EndFunction
EndProperty

Int Property WillpowerChangePerRape
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_willpowerChangePerRape", 25)
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_willpowerChangePerRape", value)
	EndFunction
EndProperty

Int Property PrideChangePerRape
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_prideChangePerRape", 5)
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_prideChangePerRape", value)
	EndFunction
EndProperty

Int Property SelfEsteemChangePerRape
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_SelfEsteemChangePerRape", 2)
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_SelfEsteemChangePerRape", value)
	EndFunction
EndProperty

float Property TraumaStageDecreaseTime ;in hame hours
	Float Function Get()
		return StorageUtil.GetFloatValue(None, "_datt_traumaStageDecreaseTime", 12.0)
	EndFunction

	Function Set(float value)
		StorageUtil.SetFloatValue(None, "_datt_traumaStageDecreaseTime", value)
	EndFunction
EndProperty

Int Property FrequentEventUpdateLatency
	Int Function Get()
		int value = StorageUtil.GetIntValue(None, "_datt_frequentEventUpdateLatency")
		If value == 0
			value = 30 ;sec
		EndIf
		return value
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_frequentEventUpdateLatency",value)
	EndFunction
EndProperty

Int Property PeriodicEventUpdateLatencyHours
	Int Function Get()
		int value = StorageUtil.GetIntValue(None, "_datt_periodicEventUpdateLatency")
		If value == 0
			value = 12 ;hours
		EndIf
		return value
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_periodicEventUpdateLatency",value)
	EndFunction
EndProperty

Int Property PrideChangePerPlayerKill
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_PrideChangePerPlayerKill", 5)
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_PrideChangePerPlayerKill",value)
	EndFunction
EndProperty

Int Property AttributeChangePerStealOrPickpocket
	Int Function Get()
		return StorageUtil.GetIntValue(None, "_datt_AttributeChangePerStealOrPickpocket", 3)
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_AttributeChangePerStealOrPickpocket",value)
	EndFunction
EndProperty

Int Property NPCScannerTickSec
	Int Function Get()
		int value = StorageUtil.GetIntValue(None, "_datt_NPCScannerTickSec")
		If value == 0
			value = 15 ;sec
		EndIf
		return value
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_NPCScannerTickSec",value)
	EndFunction
EndProperty

Int Property PeriodicSelfEsteemIncrease
	Int Function Get()
		int value = StorageUtil.GetIntValue(None, "_datt_PeriodicSelfEsteemIncrease")
		If value == 0
			value = 5
		EndIf
		return value
	EndFunction
	Function Set(int value)
		StorageUtil.SetIntValue(None, "_datt_PeriodicSelfEsteemIncrease",value)
	EndFunction
EndProperty

Bool Property EnableAttributeEffects
	Bool Function Get()
		int value = dattEnableAttributeEffects.GetValueInt()
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

Int Property MaxAttributeValue = 100 AutoReadonly Hidden

Float Property HumiliationDefault = 0.0 Auto Hidden
Float Property ExhibitionistDefault = 0.0 Auto Hidden
Float Property SadistDefault = 0.0 Auto Hidden
Float Property MasochistDefault = 0.0 Auto Hidden
Float Property NymphomanicDefault = 0.0 Auto Hidden

String Property SoulStateAttributeId = "_Datt_Soul_State" AutoReadonly Hidden

;attribute value keys for StorageUtil
String Property PrideAttributeId = "_Datt_Pride" AutoReadonly Hidden
String Property SelfEsteemAttributeId = "_Datt_SelfEsteem" AutoReadonly Hidden
String Property WillpowerAttributeId = "_Datt_Willpower" AutoReadonly Hidden
String Property ObedienceAttributeId = "_Datt_Obedience" AutoReadonly Hidden
String Property SubmissivenessAttributeId = "_Datt_Submissiveness" AutoReadonly Hidden

;attribute states keys for StorageUtil
;String Property PrideAttributeStateId = "_Datt_PrideState" AutoReadonly Hidden
;String Property SelfEsteemAttributeStateId = "_Datt_SelfEsteemState" AutoReadonly Hidden
;String Property WillpowerAttributeStateId = "_Datt_WillpowerState" AutoReadonly Hidden
;String Property ObedienceAttributeStateId = "_Datt_ObedienceState" AutoReadonly Hidden
;String Property SubmissivenessAttributeStateId = "_Datt_SubmissivenessState" AutoReadonly Hidden

;fetish value keys for StorageUtil
String Property HumiliationLoverAttributeId = "_Datt_HumiliationLover" AutoReadonly Hidden
String Property ExhibitionistAttributeId = "_Datt_Exhibitionist" AutoReadonly Hidden
String Property MasochistAttributeId = "_Datt_Masochist" AutoReadonly Hidden
String Property SadistAttributeId = "_Datt_Sadist" AutoReadonly Hidden
String Property NymphomaniacAttributeId = "_Datt_Nymphomaniac" AutoReadonly Hidden

;fetish states keys for StorageUtil
;String Property HumiliationLoverAttributeStateId = "_Datt_HumiliationLoverState" AutoReadonly Hidden
;String Property ExhibitionistAttributeStateId = "_Datt_ExhibitionistState" AutoReadonly Hidden
;String Property MasochistAttributeStateId = "_Datt_MasochistState" AutoReadonly Hidden
;String Property SadistAttributeStateId = "_Datt_SadistState" AutoReadonly Hidden
;String Property NymphomaniacAttributeStateId = "_Datt_NymphomaniacState" AutoReadonly Hidden

;player decision/choice event names
String Property PlayerDecisionEventName1 = "Datt_PlayerDecision1" AutoReadonly Hidden
String Property PlayerDecisionEventName2 = "Datt_PlayerDecision2" AutoReadonly Hidden
String Property PlayerDecisionEventName3 = "Datt_PlayerDecision3" AutoReadonly Hidden
String Property PlayerDecisionEventName4 = "Datt_PlayerDecision4" AutoReadonly Hidden

String Property PlayerDecisionWithExtraEventName1 = "Datt_PlayerDecision1WithExtra" AutoReadonly Hidden
String Property PlayerDecisionWithExtraEventName2 = "Datt_PlayerDecision2WithExtra" AutoReadonly Hidden
String Property PlayerDecisionWithExtraEventName3 = "Datt_PlayerDecision3WithExtra" AutoReadonly Hidden
String Property PlayerDecisionWithExtraEventName4 = "Datt_PlayerDecision4WithExtra" AutoReadonly Hidden

String Property PlayerSoulStateChangeEventName = "Datt_PlayerSoulStateChange" AutoReadonly Hidden


dattMonitorQuest Property MonitorQuest Auto 
Faction Property dattWillpower Auto
Faction Property dattPride Auto
Faction Property dattSelfEsteem Auto
Faction Property dattObedience Auto
Faction Property dattSubmissive Auto

Faction Property dattSadist Auto
Faction Property dattMasochist Auto
Faction Property dattNympho Auto
Faction Property dattHumiliationLover Auto
Faction Property dattExhibitionist Auto

Faction Property dattSoulState Auto

Faction Property dattRapeTraumaFaction Auto