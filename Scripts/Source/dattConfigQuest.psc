Scriptname dattConfigQuest Extends SKI_ConfigBase

Actor Property PlayerRef Auto

String Property SettingsPageName = "Settings" AutoReadonly Hidden
String Property AttributesPageName = "Attributes" AutoReadonly Hidden
String Property TrackedNPCsPageName = "Tracked NPCs" AutoReadonly Hidden
String Property DebugPageName = "Debug" AutoReadonly Hidden

GlobalVariable Property dattEnableAttributeEffects Auto

Bool Property IsLogging Auto

dattMutex Property NpcScannerMutex Auto

Event OnConfigInit()
	Pages = new string[4]
    Pages[0] = SettingsPageName
    Pages[1] = AttributesPageName
    Pages[2] = TrackedNPCsPageName  
    Pages[3] = DebugPageName  
EndEvent

Event OnPageReset(string page)
{Called when a new page is selected, including the initial empty page} 	
    SetCursorFillMode(TOP_TO_BOTTOM) 

    If (page == SettingsPageName)
        AddHeaderOption("General")
        enableAttributeEffectsToggleId = AddToggleOption("Enable Attribute Effects", EnableAttributeEffects)
        frequentEventUpdateLatencySliderId = AddSliderOption("Frequent Attr. Changes", FrequentEventUpdateLatency as float, "Each {0} hours")
        periodicEventUpdateLatencySliderId = AddSliderOption("Periodic Attr. Changes", PeriodicEventUpdateLatencyHours as float, "Each {0} hours")
        npcScannerTickSliderId = AddSliderOption("NPC Scanning Tick", NPCScannerTickSec, "Each {0} sec.")
        traumaStageDecreaseTimeSliderId = AddSliderOption("Trauma Stage Decrease", TraumaStageDecreaseTime, "Each {1} hours")
        willpowerBaseChangeSliderId = AddSliderOption("Willpower/tick", WillpowerBaseChange, "{0}")
        willpowerChangePerOrgasmSliderId = AddSliderOption("Willpower/orgasm", WillpowerChangePerOrgasm, "{0} per orgasm")
        willpowerChangePerRapeSliderId = AddSliderOption("Willpower/rape", WillpowerChangePerRape, "{0} per rape")
        prideChangePerRapeSliderId= AddSliderOption("Pride/rape", PrideChangePerRape, "{0} per rape")
        selfEsteemChangePerRapeSliderId= AddSliderOption("Self-Esteem/rape", SelfEsteemChangePerRape, "{0} per rape")        
        intervalBetweenSexToIncreaseNymphoHoursSliderId = AddSliderOption("Interval/increase nympho", IntervalBetweenSexToIncreaseNymphoHours, "Less than {0} hours")
        nymphoIncreasePerConsensualSliderId = AddSliderOption("Nympho incr/consensual", NymphoIncreasePerConsensual, "{0}")
        prideChangePerPlayerKillSliderId = AddSliderOption("Pride/kill", PrideChangePerPlayerKill, "{0}")
        attributeChangePerStealOrPickpocketSliderId = AddSliderOption("Pride,Self-Esteem/theft", AttributeChangePerStealOrPickpocket, "{0}")
        periodicSelfEsteemIncreaseSliderId = AddSliderOption("Self-esteem/periodic", PeriodicSelfEsteemIncrease, "Increase by {0}")
    ElseIf (page == TrackedNPCsPageName)
        PrintTrackedNPCs()
    ElseIf (page == AttributesPageName)
        AddHeaderOption("Player Attributes")
        float willpower = StorageUtil.GetIntValue(PlayerRef as Form, WillpowerAttributeId) 
        float selfEsteem = StorageUtil.GetIntValue(PlayerRef as Form, SelfEsteemAttributeId) 
        float pride = StorageUtil.GetIntValue(PlayerRef as Form, PrideAttributeId) 
        float obedience = StorageUtil.GetIntValue(PlayerRef as Form, ObedienceAttributeId) 
        float submissiveness = StorageUtil.GetIntValue(PlayerRef as Form, SubmissivenessAttributeId)

        AddTextOption("Willpower", PlayerRef.GetFactionRank(dattWillpower), 1)
        AddTextOption("Self-Esteem", PlayerRef.GetFactionRank(dattSelfEsteem), 1)
        AddTextOption("Pride", PlayerRef.GetFactionRank(dattPride), 1)
        AddTextOption("Obedience", PlayerRef.GetFactionRank(dattObedience), 1)
        AddTextOption("Submissiveness", PlayerRef.GetFactionRank(dattSubmissive), 1)

        AddHeaderOption("Player Traits")
        float humiliation = StorageUtil.GetIntValue(PlayerRef as Form, HumiliationLoverAttributeId) as float 
        float exhibitionist = StorageUtil.GetIntValue(PlayerRef as Form, ExhibitionistAttributeId) as float 
        float sadist = StorageUtil.GetIntValue(PlayerRef as Form, SadistAttributeId) as float 
        float masochist = StorageUtil.GetIntValue(PlayerRef as Form, MasochistAttributeId) as float
        float nympho = StorageUtil.GetIntValue(PlayerRef as Form, NymphomaniacAttributeId) as float

        AddTextOption("Humiliation Lover",humiliation, 1)
        AddTextOption("Exhibitionist", exhibitionist, 1)
        AddTextOption("Masochist", masochist, 1)
        AddTextOption("Sadist", sadist, 1)
        AddTextOption("Nympho", nympho, 1)

        AddHeaderOption("Trauma")
        AddTextOption("Rape Trauma Level", PlayerRef.GetFactionRank(dattRapeTraumaFaction) / 10, 1)

    ElseIf (page == DebugPageName)
    	AddHeaderOption("Misc")
    	showDebugMessagesToggleId = AddToggleOption("Turn on/off logging", IsLogging)
        resetPlayerAttribtesToggleId = AddToggleOption("Reset player attributes", false)
        simulateRapeToggleId = AddToggleOption("Simulate Rape (2 actors)", false)

        AddHeaderOption("Internal Stuff")
        int queuedChangeCount = StorageUtil.FormListCount(None, "_datt_queued_actors")
        queuedAttributeChangesTextId = AddTextOption("Queued Attribute Changes", queuedChangeCount, 1)
        clearChangeQueueToggleId = AddToggleOption("Clean Attribute Change Queue", false)

        AddHeaderOption("Tracked NPCs")
        resetTrackedNPCStatsToggleId = AddToggleOption("Reset tracked NPC stats", false)
        forceNPCScanToggleId = AddToggleOption("Refresh Tracked NPCs", false)
    EndIf
EndEvent

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

Event OnOptionSliderOpen(int option)
     If option == frequentEventUpdateLatencySliderId
        SetSliderDialogStartValue(FrequentEventUpdateLatency)
        SetSliderDialogDefaultValue(30)
        SetSliderDialogRange(1.0, 360.0) 
        SetSliderDialogInterval(1.0)
    EndIf
    If option == periodicEventUpdateLatencySliderId
        SetSliderDialogStartValue(PeriodicEventUpdateLatencyHours)
        SetSliderDialogDefaultValue(12)
        SetSliderDialogRange(1.0, 360.0) 
        SetSliderDialogInterval(1.0)
    EndIf
    If option == npcScannerTickSliderId
        SetSliderDialogStartValue(NPCScannerTickSec)
        SetSliderDialogDefaultValue(10)
        SetSliderDialogRange(1.0, 30.0) 
        SetSliderDialogInterval(1.0)
    EndIf
    If option == traumaStageDecreaseTimeSliderId
        SetSliderDialogStartValue(TraumaStageDecreaseTime)
        SetSliderDialogDefaultValue(12.0)
        SetSliderDialogRange(1.0, 24.0) 
        SetSliderDialogInterval(0.5)
    EndIf

    If option == willpowerChangePerOrgasmSliderId
        SetSliderDialogStartValue(WillpowerChangePerOrgasm)
        SetSliderDialogDefaultValue(5.0)
        SetSliderDialogRange(0.0, 100.0) 
        SetSliderDialogInterval(1.0)
    EndIf

    If option == willpowerChangePerRapeSliderId
        SetSliderDialogStartValue(WillpowerChangePerRape)
        SetSliderDialogDefaultValue(10.0)
        SetSliderDialogRange(0.0, 100.0) 
        SetSliderDialogInterval(1.0)
    EndIf
    If option == prideChangePerRapeSliderId
        SetSliderDialogStartValue(PrideChangePerRape)
        SetSliderDialogDefaultValue(2.0)
        SetSliderDialogRange(0.0, 100.0) 
        SetSliderDialogInterval(1.0)
    EndIf
    If option == selfEsteemChangePerRapeSliderId
        SetSliderDialogStartValue(SelfEsteemChangePerRape)
        SetSliderDialogDefaultValue(1.0)
        SetSliderDialogRange(0.0, 100.0) 
        SetSliderDialogInterval(1.0)
    EndIf                
    If option == intervalBetweenSexToIncreaseNymphoHoursSliderId
        SetSliderDialogStartValue(IntervalBetweenSexToIncreaseNymphoHours)
        SetSliderDialogDefaultValue(6.0)
        SetSliderDialogRange(1.0, 24.0) 
        SetSliderDialogInterval(1.0)
    EndIf

    If option == nymphoIncreasePerConsensualSliderId
        SetSliderDialogStartValue(NymphoIncreasePerConsensual)
        SetSliderDialogDefaultValue(2.0)
        SetSliderDialogRange(1.0, 25.0) 
        SetSliderDialogInterval(1.0)
    EndIf    

    If option == willpowerBaseChangeSliderId
        SetSliderDialogStartValue(WillpowerBaseChange)
        SetSliderDialogDefaultValue(10.0)
        SetSliderDialogRange(2.0, 50.0) 
        SetSliderDialogInterval(1.0)
    EndIf 

    If option == prideChangePerPlayerKillSliderId
        SetSliderDialogStartValue(PrideChangePerPlayerKill)
        SetSliderDialogDefaultValue(5.0)
        SetSliderDialogRange(0.0, 100.0) 
        SetSliderDialogInterval(1.0)
    EndIf  

    If option == attributeChangePerStealOrPickpocketSliderId
        SetSliderDialogStartValue(AttributeChangePerStealOrPickpocket)
        SetSliderDialogDefaultValue(5.0)
        SetSliderDialogRange(0.0, 100.0) 
        SetSliderDialogInterval(1.0)
    EndIf  

    If option == periodicSelfEsteemIncreaseSliderId
        SetSliderDialogStartValue(PeriodicSelfEsteemIncrease)
        SetSliderDialogDefaultValue(5.0)
        SetSliderDialogRange(0.0, 100.0) 
        SetSliderDialogInterval(1.0)
    EndIf
    
EndEvent

Event OnOptionSliderAccept(int option, float value)
     If option == frequentEventUpdateLatencySliderId
        FrequentEventUpdateLatency = value as int
        SetSliderOptionValue(frequentEventUpdateLatencySliderId, value, "Each {0} hours")
    ElseIf option == periodicEventUpdateLatencySliderId 
        PeriodicEventUpdateLatencyHours = value as int
        SetSliderOptionValue(periodicEventUpdateLatencySliderId, value, "Each {0} hours")
    ElseIf option == npcScannerTickSliderId 
        NPCScannerTickSec = value as int
        SetSliderOptionValue(npcScannerTickSliderId, value, "Each {0} sec.")
    ElseIf option == traumaStageDecreaseTimeSliderId 
        TraumaStageDecreaseTime = value
        SetSliderOptionValue(traumaStageDecreaseTimeSliderId, value, "Each {1} hours")
    ElseIf option == willpowerChangePerRapeSliderId 
        WillpowerChangePerRape = value as int
        SetSliderOptionValue(willpowerChangePerRapeSliderId, value, "{0} per rape")
    ElseIf option == prideChangePerRapeSliderId 
        PrideChangePerRape = value as int
        SetSliderOptionValue(prideChangePerRapeSliderId, value, "{0} per rape")
    ElseIf option == selfEsteemChangePerRapeSliderId 
        SelfEsteemChangePerRape = value as int
        SetSliderOptionValue(selfEsteemChangePerRapeSliderId, value, "{0} per rape")
    ElseIf option == intervalBetweenSexToIncreaseNymphoHoursSliderId 
        IntervalBetweenSexToIncreaseNymphoHours = value
        SetSliderOptionValue(intervalBetweenSexToIncreaseNymphoHoursSliderId, value, "Less than {0} hours")
    ElseIf option == nymphoIncreasePerConsensualSliderId 
        NymphoIncreasePerConsensual = value as int
        SetSliderOptionValue(nymphoIncreasePerConsensualSliderId, value, "{0}")
    ElseIf option == willpowerBaseChangeSliderId 
        WillpowerBaseChange = value as int
        SetSliderOptionValue(willpowerBaseChangeSliderId, value, "{0}")
    ElseIf option == prideChangePerPlayerKillSliderId 
        PrideChangePerPlayerKill = value as int
        SetSliderOptionValue(prideChangePerPlayerKillSliderId, value, "{0}")
    ElseIf option == attributeChangePerStealOrPickpocketSliderId 
        AttributeChangePerStealOrPickpocket = value as int
        SetSliderOptionValue(attributeChangePerStealOrPickpocketSliderId, value, "{0}")
    ElseIf option == periodicSelfEsteemIncreaseSliderId 
        PeriodicSelfEsteemIncrease = value as int
        SetSliderOptionValue(periodicSelfEsteemIncreaseSliderId, value, "Increase by {0}")
    EndIf

EndEvent

Event OnOptionSelect(int option)
    if enableAttributeEffectsToggleId == option
        EnableAttributeEffects = !EnableAttributeEffects
        SetToggleOptionValue(enableAttributeEffectsToggleId, EnableAttributeEffects)
    EndIf

    if forceNPCScanToggleId == option
        dattUtility.SendParameterlessEvent("Datt_ForceRemoveNPCMonitor")
        Utility.WaitMenuMode(1)        
        StorageUtil.FormListClear(None, "_datt_tracked_npcs")
        dattUtility.SendParameterlessEvent("Datt_ForceNPCScan")
        Debug.MessageBox("Sent event to refersh tracked NPCs")
    EndIf

    If resetTrackedNPCStatsToggleId == option
        ResetTrackedNPCStats()
        Debug.MessageBox("Sent events to reset tracked NPC stats")
    EndIf

	If showDebugMessagesToggleId == option
		IsLogging = !IsLogging
		SetToggleOptionValue(showDebugMessagesToggleId, IsLogging)
	EndIf
    If resetPlayerAttribtesToggleId == option
        int resetToDefaultsEventId = ModEvent.Create("Datt_SetDefaults")
        If resetToDefaultsEventId
            ModEvent.PushForm(resetToDefaultsEventId, PlayerRef as Form)
            If ModEvent.Send(resetToDefaultsEventId) == true
                Debug.MessageBox("Player attributes reset to defaults..")
            Else
                Debug.MessageBox("Player attributes weren't reset to defaults, sending the event failed. Please try again. (Do you have script lag?)")
            EndIf
        Else
            ModEvent.Release(resetToDefaultsEventId)
            Debug.MessageBox("Player attributes reset to defaults failed, ModEvent didn't create the event properly")
        EndIf        
    EndIf
    If clearChangeQueueToggleId == option
        int cleanChangeQueueEventId = ModEvent.Create("Datt_ClearChangeQueue")
        If cleanChangeQueueEventId
            If ModEvent.Send(cleanChangeQueueEventId) == true
                Debug.MessageBox("Player change queue cleared..")
                Utility.Wait(0.5)
                SetTextOptionValue(queuedAttributeChangesTextId, StorageUtil.FormListCount(None, "_datt_queued_actors"))
            Else
                Debug.MessageBox("Player change queue was not cleared, sending the event failed. Please try again. (Do you have script lag?)")
            EndIf
        Else
            Debug.MessageBox("Player change queue was not cleared, ModEvent didn't create the event properly")
        EndIf
    EndIf
    If simulateRapeToggleId == option
        dattUtility.SendEventWithFormAndIntParam("Datt_Simulate_Rape",PlayerRef as Form,2)
        Debug.MessageBox("Datt_Simulate_Rape event sent for PC")
    EndIf
EndEvent

int enableAttributeEffectsToggleId
int showDebugMessagesToggleId
int resetPlayerAttribtesToggleId
int frequentEventUpdateLatencySliderId
int periodicEventUpdateLatencySliderId
int maxNPCsToScanSliderId
int npcScannerTickSliderId
int clearChangeQueueToggleId
int queuedAttributeChangesTextId
int traumaStageDecreaseTimeSliderId
int willpowerChangePerRapeSliderId
int prideChangePerRapeSliderId
int selfEsteemChangePerRapeSliderId
int willpowerChangePerOrgasmSliderId
int intervalBetweenSexToIncreaseNymphoHoursSliderId
int nymphoIncreasePerConsensualSliderId
int simulateRapeToggleId
int willpowerBaseChangeSliderId
int resetTrackedNPCStatsToggleId
int prideChangePerPlayerKillSliderId
int attributeChangePerStealOrPickpocketSliderId
int forceNPCScanToggleId
int periodicSelfEsteemIncreaseSliderId

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
        return StorageUtil.GetIntValue(None, "_datt_willpowerChangePerOrgasm", 8)
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

String Property SoulStateAttributeId = "_Datt_Soul_State" AutoReadonly Hidden

;attribute value keys for StorageUtil
String Property PrideAttributeId = "_Datt_Pride" AutoReadonly Hidden
String Property SelfEsteemAttributeId = "_Datt_SelfEsteem" AutoReadonly Hidden
String Property WillpowerAttributeId = "_Datt_Willpower" AutoReadonly Hidden
String Property ObedienceAttributeId = "_Datt_Obedience" AutoReadonly Hidden
String Property SubmissivenessAttributeId = "_Datt_Submissiveness" AutoReadonly Hidden

;fetish value keys for StorageUtil
String Property HumiliationLoverAttributeId = "_Datt_HumiliationLover" AutoReadonly Hidden
String Property ExhibitionistAttributeId = "_Datt_Exhibitionist" AutoReadonly Hidden
String Property MasochistAttributeId = "_Datt_Masochist" AutoReadonly Hidden
String Property SadistAttributeId = "_Datt_Sadist" AutoReadonly Hidden
String Property NymphomaniacAttributeId = "_Datt_Nymphomaniac" AutoReadonly Hidden

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