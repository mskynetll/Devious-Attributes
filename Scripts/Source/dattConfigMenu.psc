Scriptname dattConfigMenu extends SKI_ConfigBase

;reference to the main monitoring quest
dattMonitorQuest Property MonitorQuest Auto 
dattLibraries Property Libs Auto
dattAttributes Property Attributes Auto
dattDecisions Property Decisions Auto
dattConstants Property Constants Auto

;constants
Float Property DefaultRefreshRate = 15.0 AutoReadonly Hidden ;in Seconds

;refresh rate in Seconds
Float Property MinRefreshRate = 5.0 AutoReadonly Hidden
Float Property MaxRefreshRate = 60.0 AutoReadonly Hidden 

;page names
string SettingsPageName = "Settings"
string AttributesPageName = "Attributes"
string DebugPageName = "Debug"

;private field ids
int resetStatsToggleId
int pauseRefreshTimerToggleId
int simulateRapeToggleId
int showDebugMessagesToggleId

int debugPlayerDecisionToggleId
int debugPlayerDecisionTypeSliderId
int debugPlayerResponseTypeSliderId
int debugExtraPrideChangeSliderId
int debugExtraSelfEsteemChangeSliderId
int debugPlayerDecisionWithExtraChangesToggleId
int debugPlayerDecisionEventId
int debugPlayerDecisionWithExtraEventId
int debugPlayerSoulStateChangeEventId

int manualSoulStateSliderId
int refreshRateSliderId
int simulateRapeActorCountSliderId
int selfEsteemPeriodicIncreasePerDaySliderId
int prideHitPercentagePerRapeSliderId
int prideIncreasePercentagePerEnemyKillSliderId
int prideIncreasePercentagePerSpellCastSliderId
int willpowerHitPercentagePerRapeSliderId
int statIncreasePercentagePerStealingSliderId
int selfesteemHitPercentagePerRapeSliderId
int arousalThresholdToIncreaseFetishSliderId
int obedienceDailyDecreaseSliderId
int fetishIncrementPerDecisionSliderId
int willpowerBaseDecisionCostSliderId
int selfesteemIncreasePercentagePerConsensualSexSliderId
int sdLooksChangePrideHitSliderId
int sdLooksChangeSelfEsteemHitSliderId
int sdSubSexPrideChangePercentageSliderId
int sdSubEntertainSelfEsteemChangePercentageSliderId

;Settings
Int Property DebugPlayerDecisionType Auto
Int Property DebugPlayerResponseType Auto
Int Property DebugExtraPrideChange Auto
Int Property DebugExtraSelfEsteemChange Auto

Float Property RefreshRate Auto Hidden
Bool Property IsRunningRefresh Auto Hidden
Bool Property ShowDebugMessages Auto

Float Property SdSubEntertainSelfEsteemChangePercentage Auto Hidden
Float Property DefaultSdSubEntertainSelfEsteemChangePercentage = 10.0 AutoReadonly Hidden

Float Property SdSubSexPrideChangePercentage Auto Hidden
Float Property DefaultSdSubSexPrideChangePercentage = 5.0 AutoReadonly Hidden

Float Property SdLooksChangePridePercentageHit Auto Hidden
Float Property DefaultSdLooksChangePridePercentageHit = 50.0 AutoReadonly Hidden

Float Property SdLooksChangeSelfEsteemPercentageHit Auto Hidden
Float Property DefaultSdLooksChangeSelfEsteemPercentageHit = 25 AutoReadonly Hidden


Int Property ArousalThresholdToIncreaseFetish Auto Hidden
Int Property DefaultArousalThresholdToIncreaseFetish = 50 AutoReadonly Hidden

Float Property FetishIncrementPerDecision Auto Hidden
Float Property DefaultFetishIncrementPerDecision = 0.5 AutoReadonly Hidden

Int Property WillpowerBaseDecisionCost Auto Hidden
Int Property DefaultWillpowerBaseDecisionCost = 15 AutoReadonly Hidden

Int Property ObedienceDailyDecrease Auto Hidden
Int Property DefaultObedienceDailyDecrease = 1 AutoReadonly Hidden

Int Property SelfEsteemPeriodicIncreasePerDay Auto Hidden
Int Property DefaultSelfEsteemPeriodicIncreasePerDay = 1 AutoReadonly Hidden

Float Property PrideIncreasePercentagePerSpellCast Auto Hidden
Float Property DefaultPrideIncreasePercentagePerSpellCast = 0.05 AutoReadonly Hidden

Float Property StatIncreasePercentagePerStealing Auto Hidden
Float Property DefaultStatIncreasePercentagePerStealing = 0.1 AutoReadonly Hidden

Float Property PrideHitPercentagePerRape Auto Hidden
Float Property DefaultPrideHitPercentagePerRape = 15 AutoReadonly Hidden
Float Property PrideIncreasePercentagePerEnemyKill Auto Hidden
Float Property DefaultPrideIncreasePercentagePerEnemyKill = 0.5 AutoReadonly Hidden
Float Property WillpowerHitPercentagePerRape Auto Hidden
Float Property DefaultWillpowerHitPercentagePerRape = 50 AutoReadonly Hidden

Float Property SelfesteemIncreasePercentagePerConsensualSex Auto Hidden
Float Property DefaultSelfesteemIncreasePercentagePerConsensualSex = 1 AutoReadonly Hidden

Float Property SelfesteemHitPercentagePerRape Auto Hidden
Float Property DefaultSelfesteemHitPercentagePerRape = 5 AutoReadonly Hidden
Float Property SimulateRapeActorCount Auto Hidden

;Soft dependency flags
Bool Property IsRealisticNeedsInstalled Auto
Bool Property IsSexlabSexualFameInstalled Auto
Bool Property IsSkoomaWhoreInstalled Auto
Bool Property IsSanguinesDebaucheryInstalled Auto

Event OnConfigInit()
    Pages = new string[3]
    Pages[0] = SettingsPageName
    Pages[1] = AttributesPageName
    Pages[2] = DebugPageName   

    If(RefreshRate == 0)
        RefreshRate = DefaultRefreshRate
    EndIf
    If(PrideHitPercentagePerRape == 0)
        PrideHitPercentagePerRape = DefaultPrideHitPercentagePerRape
    EndIf
    If(PrideIncreasePercentagePerEnemyKill == 0)
        PrideIncreasePercentagePerEnemyKill = DefaultPrideIncreasePercentagePerEnemyKill
    EndIf
    If(WillpowerHitPercentagePerRape == 0)
        WillpowerHitPercentagePerRape = DefaultWillpowerHitPercentagePerRape
    EndIf 
    If (SimulateRapeActorCount < 2)
        SimulateRapeActorCount = 2
    EndIf
    If (SelfEsteemPeriodicIncreasePerDay == 0)
        SelfEsteemPeriodicIncreasePerDay = DefaultSelfEsteemPeriodicIncreasePerDay
    EndIf
    If (PrideIncreasePercentagePerSpellCast == 0)
        PrideIncreasePercentagePerSpellCast = DefaultPrideIncreasePercentagePerSpellCast
    EndIf    
    If (SelfesteemHitPercentagePerRape == 0)
        SelfesteemHitPercentagePerRape = DefaultSelfesteemHitPercentagePerRape
    EndIf
    If (ArousalThresholdToIncreaseFetish == 0)
        ArousalThresholdToIncreaseFetish = DefaultArousalThresholdToIncreaseFetish
    EndIf
    If (ObedienceDailyDecrease == 0)
        ObedienceDailyDecrease = DefaultObedienceDailyDecrease
    EndIf
    If (FetishIncrementPerDecision == 0)
        FetishIncrementPerDecision = DefaultFetishIncrementPerDecision
    EndIf
    If (WillpowerBaseDecisionCost == 0)
        WillpowerBaseDecisionCost = DefaultWillpowerBaseDecisionCost
    EndIf
    If (SdLooksChangePridePercentageHit == 0.0)
        SdLooksChangePridePercentageHit = DefaultSdLooksChangePridePercentageHit
    EndIf
    If (SdLooksChangeSelfEsteemPercentageHit == 0.0)
        SdLooksChangeSelfEsteemPercentageHit = DefaultSdLooksChangeSelfEsteemPercentageHit
    EndIf
    If (SdSubSexPrideChangePercentage == 0.0)
        SdSubSexPrideChangePercentage = DefaultSdSubSexPrideChangePercentage
    EndIf
    If (SdSubEntertainSelfEsteemChangePercentage == 0.0)
        SdSubEntertainSelfEsteemChangePercentage = DefaultSdSubEntertainSelfEsteemChangePercentage
    EndIf
    If (SelfesteemIncreasePercentagePerConsensualSex == 0.0)
        SelfesteemIncreasePercentagePerConsensualSex = DefaultSelfesteemIncreasePercentagePerConsensualSex
    EndIf

    CheckSoftDependencies()

    If(Constants == None)
        Debug.MessageBox("Constants == None -> something happened with references filling out. This is not supposed to happen and needs to be reported.")
    ElseIf(MonitorQuest == None)
        Debug.MessageBox("MonitorQuest == None -> something happened with references filling out. This is not supposed to happen and needs to be reported.")
    ElseIf(Attributes == None)
        Debug.MessageBox("Attributes == None -> something happened with references filling out. This is not supposed to happen and needs to be reported.")
    EndIf
EndEvent

Function DebugSendPlayerDecision(int playerResponseType, int decisionType)
    If(debugPlayerDecisionEventId)
        If(ShowDebugMessages)
            Debug.Notification("Devious Attributes -> debug.SendPlayerDecision()")
        EndIf

        ModEvent.PushInt(debugPlayerDecisionEventId, playerResponseType)
        ModEvent.PushInt(debugPlayerDecisionEventId, decisionType)
        ModEvent.Send(debugPlayerDecisionEventId)
    Else
        If(ShowDebugMessages)
            Debug.Notification("Devious Attributes -> debug.SendPlayerDecision() -> debugPlayerDecisionEventId not initialized!")
        EndIf
    EndIf
EndFunction

Function DebugSendPlayerDecisionWithExtraChanges(int playerResponseType, int decisionType,int prideExtraChange, int selfEsteemExtraChange)
    If(debugPlayerDecisionWithExtraEventId)
        If(ShowDebugMessages)
            Debug.Notification("Devious Attributes -> debug.DebugSendPlayerDecisionWithExtraChanges()")
        EndIf

        ModEvent.PushInt(debugPlayerDecisionWithExtraEventId, playerResponseType)
        ModEvent.PushInt(debugPlayerDecisionWithExtraEventId, decisionType)
        ModEvent.PushInt(debugPlayerDecisionWithExtraEventId, prideExtraChange)
        ModEvent.PushInt(debugPlayerDecisionWithExtraEventId, selfEsteemExtraChange)
        ModEvent.Send(debugPlayerDecisionWithExtraEventId)
    Else
        If(ShowDebugMessages)
            Debug.Notification("Devious Attributes -> debug.DebugSendPlayerDecisionWithExtraChanges() -> debugPlayerDecisionWithExtraEventId not initialized!")
        EndIf
    EndIf
EndFunction

Function CheckSoftDependencies()
    If(ShowDebugMessages)
            Debug.Notification("Devious Attributes -> checking soft dependencies")
    EndIf
    If Game.GetModByName("RealisticNeedsandDiseases.esp") == 255
        IsRealisticNeedsInstalled = false       
    Else
        IsRealisticNeedsInstalled = true
    EndIf
    If Game.GetModByName("SexLab - Sexual Fame [SLSF].esm") == 255
        IsSexlabSexualFameInstalled = false       
    Else
        IsSexlabSexualFameInstalled = true
    EndIf
    If Game.GetModByName("SexLabSkoomaWhore.esp") == 255
        IsSkoomaWhoreInstalled = false       
    Else
        IsSkoomaWhoreInstalled = true
    EndIf
        If Game.GetModByName("sanguinesDebauchery.esp") == 255
        IsSanguinesDebaucheryInstalled = false       
    Else
        IsSanguinesDebaucheryInstalled = true
    EndIf

EndFunction

Event OnPageReset(string page)
{Called when a new page is selected, including the initial empty page} 	
    debugPlayerDecisionEventId = ModEvent.Create(Constants.PlayerDecisionEventName1)
    debugPlayerDecisionWithExtraEventId = ModEvent.Create(Constants.PlayerDecisionWithExtraEventName1)
    debugPlayerSoulStateChangeEventId = ModEvent.Create(Constants.PlayerSoulStateChangeEventName)
    SetCursorFillMode(TOP_TO_BOTTOM)    
    If (page == SettingsPageName)
        AddHeaderOption("Mod Options")
        refreshRateSliderId = AddSliderOption("Stats refresh rate", RefreshRate, "Every {0} Seconds")
        pauseRefreshTimerToggleId = AddToggleOption("Start/Stop stats refresh", IsRunningRefresh)        

        AddHeaderOption("Player decision settings")        
        willpowerBaseDecisionCostSliderId  = AddSliderOption("Willpower base cost", WillpowerBaseDecisionCost, "{0}")
        fetishIncrementPerDecisionSliderId  = AddSliderOption("Fetish increment", FetishIncrementPerDecision, "{1}")
        arousalThresholdToIncreaseFetishSliderId = AddSliderOption("Arousal threshold - fetishes", ArousalThresholdToIncreaseFetish)        

        AddHeaderOption("Negative Stat Changes")
        prideHitPercentagePerRapeSliderId = AddSliderOption("Sex Victim - pride", PrideHitPercentagePerRape, "Decrease {1}%")        
        selfesteemHitPercentagePerRapeSliderId = AddSliderOption("Sex Victim - self-esteem", SelfesteemHitPercentagePerRape, "Decrease {1}%")        
        willpowerHitPercentagePerRapeSliderId = AddSliderOption("Sex Victim - willpower", WillpowerHitPercentagePerRape, "Decrease {1}%")        

        AddHeaderOption("Positive Stat Changes")
        obedienceDailyDecreaseSliderId = AddSliderOption("Obedience", ObedienceDailyDecrease, "Decrease {0} per day")
        selfesteemIncreasePercentagePerConsensualSexSliderId = AddSliderOption("Self-esteem (consensual sex)", SelfesteemIncreasePercentagePerConsensualSex, "Increase {1}%")
        selfEsteemPeriodicIncreasePerDaySliderId = AddSliderOption("Self-esteem", SelfEsteemPeriodicIncreasePerDay, "Increase {0} per day")
        prideIncreasePercentagePerEnemyKillSliderId = AddSliderOption("Enemy kill - pride", PrideIncreasePercentagePerEnemyKill, "Increase {1}%")
        prideIncreasePercentagePerSpellCastSliderId = AddSliderOption("Spellcast - pride", PrideIncreasePercentagePerSpellCast, "Increase {1}%")
        statIncreasePercentagePerStealingSliderId = AddSliderOption("Stealing - pride,self-esteem", StatIncreasePercentagePerStealing, "Increase {1}%")

        AddHeaderOption("SD+")
        sdSubSexPrideChangePercentageSliderId = AddSliderOption("Sex with PC/sub - pride", SdSubSexPrideChangePercentage, "Change {1}%")
        sdSubEntertainSelfEsteemChangePercentageSliderId = AddSliderOption("PC/sub Entertain - self-esteem", SdSubEntertainSelfEsteemChangePercentage, "Change {1}%")
        sdLooksChangePrideHitSliderId = AddSliderOption("Looks Change - pride", SdLooksChangePridePercentageHit, "Decrease {1}%")
        sdLooksChangeSelfEsteemHitSliderId = AddSliderOption("Looks Change - self-esteem", SdLooksChangeSelfEsteemPercentageHit, "Decrease {1}%")        
	ElseIf (page == AttributesPageName) 
        float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId)
        float selfEsteem = Attributes.GetPlayerAttribute(Constants.SelfEsteemAttributeId)
        float pride = Attributes.GetPlayerAttribute(Constants.PrideAttributeId)
        float obedience = Attributes.GetPlayerAttribute(Constants.ObedienceAttributeId)

        int soulState = Attributes.GetPlayerSoulState()

        If(soulState == 0)
            AddTextOption("Soul State", "Free(0)",1)
        ElseIf(soulState == 1)
            AddTextOption("Soul State", "Willing Sub(1)",1)
        ElseIf(soulState == 2)
            AddTextOption("Soul State", "Forced Slave(2)",1)
        EndIf

        AddHeaderOption("Stats")
    	AddTextOption("Willpower", willpower, 1)
    	AddTextOption("Self-Esteem", selfEsteem, 1)
    	AddTextOption("Pride", pride, 1)
    	AddTextOption("Obedience", obedience, 1)
        ;since submissiveness is calculated between 0.0 and 1.0, display it as 0.0 -> 100.0
        ;for conformity's sake
    	AddTextOption("Submissiveness", Attributes.GetPlayerSubmissiveness() * 100.0, 1)

        AddHeaderOption("Traits")
        AddTextOption("Humiliation Lover", Attributes.GetPlayerFetish(Constants.HumiliationLoverAttributeId), 1)
        AddTextOption("Exhibitionist", Attributes.GetPlayerFetish(Constants.ExhibitionistAttributeId), 1)
        AddTextOption("Masochist", Attributes.GetPlayerFetish(Constants.MasochistAttributeId), 1)
        AddTextOption("Nympho", Attributes.GetPlayerFetish(Constants.NymphomaniacAttributeId), 1)

        AddHeaderOption("Optional Mods")

        If (IsRealisticNeedsInstalled)
            AddTextOption("Realistic Needs and Diseases", "Installed", 1)    
        Else
            AddTextOption("Realistic Needs and Diseases", "Not Installed", 1)    
        EndIf
        If (IsSexlabSexualFameInstalled)
            AddTextOption("SexLab - Sexual Fame [SLSF]", "Installed", 1)    
        Else
            AddTextOption("SexLab - Sexual Fame [SLSF]", "Not Installed", 1)    
        EndIf
        If (IsSkoomaWhoreInstalled)
            AddTextOption("Skooma Whore", "Installed", 1)    
        Else
            AddTextOption("Skooma Whore", "Not Installed", 1)    
        EndIf  
        If (IsSanguinesDebaucheryInstalled)
            AddTextOption("Sanguine's Debauchery", "Installed", 1)    
        Else
            AddTextOption("Sanguine's Debauchery", "Not Installed", 1)    
        EndIf        
    ElseIf (page == DebugPageName)  
        AddHeaderOption("Misc")
        manualSoulStateSliderId = AddSliderOption("Soul State", Attributes.GetPlayerSoulState() as float, "{0}")

        AddHeaderOption("Stats")
    	resetStatsToggleId = AddToggleOption("Reset stats", false)
        simulateRapeToggleId = AddToggleOption("Simulate player victim", false)
        showDebugMessagesToggleId = AddToggleOption("Show debug messages", ShowDebugMessages)
        simulateRapeActorCountSliderId = AddSliderOption("Simulate victim actor count", SimulateRapeActorCount, "{0} actors")

        AddHeaderOption("Player Decision")
        debugPlayerResponseTypeSliderId = AddSliderOption("Response type", DebugPlayerResponseType, "{0}")
        debugPlayerDecisionTypeSliderId = AddSliderOption("Decision type", DebugPlayerDecisionType, "{0}")
        debugExtraPrideChangeSliderId = AddSliderOption("Extra pride change", DebugExtraPrideChange, "{0}")
        debugExtraSelfEsteemChangeSliderId = AddSliderOption("Extra self-esteem change", DebugExtraSelfEsteemChange, "{0}")
        debugPlayerDecisionToggleId = AddToggleOption("Simulate player decision", false)
        debugPlayerDecisionWithExtraChangesToggleId = AddToggleOption("Simulate player decision(extra changes)", false)
    EndIf
EndEvent

Event OnOptionSliderOpen(int option)
    If (option == refreshRateSliderId)
        SetSliderDialogStartValue(RefreshRate)
        SetSliderDialogDefaultValue(DefaultRefreshRate)
        SetSliderDialogRange(MinRefreshRate, MaxRefreshRate) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == simulateRapeActorCountSliderId)
        SetSliderDialogStartValue(SimulateRapeActorCount)
        SetSliderDialogDefaultValue(2)
        SetSliderDialogRange(2, 10)  
        SetSliderDialogInterval(1.0)
    ElseIf (option == prideHitPercentagePerRapeSliderId)
        SetSliderDialogStartValue(PrideHitPercentagePerRape)
        SetSliderDialogDefaultValue(DefaultPrideHitPercentagePerRape)
        SetSliderDialogRange(0, 100.0) 
        SetSliderDialogInterval(0.5)
    ElseIf (option == selfesteemHitPercentagePerRapeSliderId)
        SetSliderDialogStartValue(SelfesteemHitPercentagePerRape)
        SetSliderDialogDefaultValue(DefaultSelfesteemHitPercentagePerRape)
        SetSliderDialogRange(0, 100.0) 
        SetSliderDialogInterval(0.5)        
    ElseIf (option == prideIncreasePercentagePerSpellCastSliderId)
        SetSliderDialogStartValue(PrideIncreasePercentagePerSpellCast)
        SetSliderDialogDefaultValue(DefaultPrideIncreasePercentagePerSpellCast)
        SetSliderDialogRange(0.0, 100.0) 
        SetSliderDialogInterval(0.5) 
    ElseIf (option == prideIncreasePercentagePerEnemyKillSliderId)
        SetSliderDialogStartValue(PrideIncreasePercentagePerEnemyKill) 
        SetSliderDialogDefaultValue(DefaultPrideIncreasePercentagePerEnemyKill)
        SetSliderDialogRange(0.0, 100.0)
        SetSliderDialogInterval(0.5)         
    ElseIf (option == willpowerHitPercentagePerRapeSliderId)        
        SetSliderDialogStartValue(WillpowerHitPercentagePerRape)
        SetSliderDialogDefaultValue(DefaultWillpowerHitPercentagePerRape)
        SetSliderDialogRange(0, 100.0) 
        SetSliderDialogInterval(0.5)
    ElseIf (option == selfEsteemPeriodicIncreasePerDaySliderId)
        SetSliderDialogStartValue(SelfEsteemPeriodicIncreasePerDay)
        SetSliderDialogDefaultValue(DefaultSelfEsteemPeriodicIncreasePerDay)
        SetSliderDialogRange(0, 100.0) 
        SetSliderDialogInterval(0.5)
    ElseIf (option == statIncreasePercentagePerStealingSliderId)
        SetSliderDialogStartValue(StatIncreasePercentagePerStealing)
        SetSliderDialogDefaultValue(DefaultStatIncreasePercentagePerStealing)
        SetSliderDialogRange(0, 100.0) 
        SetSliderDialogInterval(0.5)
    ElseIf (option == arousalThresholdToIncreaseFetishSliderId)
        SetSliderDialogStartValue(ArousalThresholdToIncreaseFetish)
        SetSliderDialogDefaultValue(DefaultArousalThresholdToIncreaseFetish)
        SetSliderDialogRange(0, 100.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == obedienceDailyDecreaseSliderId)
        SetSliderDialogStartValue(ObedienceDailyDecrease)
        SetSliderDialogDefaultValue(DefaultObedienceDailyDecrease)
        SetSliderDialogRange(0, 100.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == fetishIncrementPerDecisionSliderId)
        SetSliderDialogStartValue(FetishIncrementPerDecision)
        SetSliderDialogDefaultValue(DefaultFetishIncrementPerDecision)
        SetSliderDialogRange(0, 100.0) 
        SetSliderDialogInterval(0.5)
    ElseIf (option == willpowerBaseDecisionCostSliderId)
        SetSliderDialogStartValue(WillpowerBaseDecisionCost)
        SetSliderDialogDefaultValue(DefaultWillpowerBaseDecisionCost)
        SetSliderDialogRange(0, 100.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == debugPlayerResponseTypeSliderId)
        SetSliderDialogStartValue(DebugPlayerResponseType)
        SetSliderDialogDefaultValue(0.0)
        SetSliderDialogRange(-2.0, 2.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == debugPlayerDecisionTypeSliderId)
        SetSliderDialogStartValue(DebugPlayerDecisionType)
        SetSliderDialogDefaultValue(0.0)
        SetSliderDialogRange(0, 4.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == debugExtraPrideChangeSliderId)
        SetSliderDialogStartValue(DebugExtraPrideChange)
        SetSliderDialogDefaultValue(0.0)
        SetSliderDialogRange(-100.0, 100.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == debugExtraSelfEsteemChangeSliderId)
        SetSliderDialogStartValue(DebugExtraSelfEsteemChange)
        SetSliderDialogDefaultValue(0.0)
        SetSliderDialogRange(-100.0, 100.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == manualSoulStateSliderId)
        SetSliderDialogStartValue(Attributes.GetPlayerSoulState())
        SetSliderDialogDefaultValue(0.0)
        SetSliderDialogRange(0, 2.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == sdLooksChangePrideHitSliderId)
        SetSliderDialogStartValue(SdLooksChangePridePercentageHit)
        SetSliderDialogDefaultValue(DefaultSdLooksChangePridePercentageHit)
        SetSliderDialogRange(0, 100.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == sdLooksChangeSelfEsteemHitSliderId)
        SetSliderDialogStartValue(SdLooksChangeSelfEsteemPercentageHit)
        SetSliderDialogDefaultValue(DefaultSdLooksChangeSelfEsteemPercentageHit)
        SetSliderDialogRange(0, 100.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == sdSubSexPrideChangePercentageSliderId)
        SetSliderDialogStartValue(SdSubSexPrideChangePercentage)
        SetSliderDialogDefaultValue(DefaultSdSubSexPrideChangePercentage)
        SetSliderDialogRange(0.0, 100.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == sdSubEntertainSelfEsteemChangePercentageSliderId)
        SetSliderDialogStartValue(SdSubEntertainSelfEsteemChangePercentage)
        SetSliderDialogDefaultValue(DefaultSdSubEntertainSelfEsteemChangePercentage)
        SetSliderDialogRange(0.0, 100.0) 
        SetSliderDialogInterval(1.0)
    ElseIf (option == selfesteemIncreasePercentagePerConsensualSexSliderId)
        SetSliderDialogStartValue(SelfesteemIncreasePercentagePerConsensualSex)
        SetSliderDialogDefaultValue(DefaultSelfesteemIncreasePercentagePerConsensualSex)
        SetSliderDialogRange(0.0, 100.0) 
        SetSliderDialogInterval(1.0)
    EndIf 
    
EndEvent


Event OnOptionSliderAccept(int option, float value)
    If (option == refreshRateSliderId)
        RefreshRate = value
        MonitorQuest.ToggleRefreshRunningState()
        MonitorQuest.ToggleRefreshRunningState()
        SetSliderOptionValue(refreshRateSliderId, value, "Every {0} Seconds")
    ElseIf (option == simulateRapeActorCountSliderId)   
        SimulateRapeActorCount = value
        SetSliderOptionValue(simulateRapeActorCountSliderId, value, "{0} actors")
    ElseIf (option == prideHitPercentagePerRapeSliderId)
        PrideHitPercentagePerRape = value
        SetSliderOptionValue(prideHitPercentagePerRapeSliderId, value, "Decrease {1}%")
    ElseIf (option == selfesteemHitPercentagePerRapeSliderId)
        SelfesteemHitPercentagePerRape = value
        SetSliderOptionValue(selfesteemHitPercentagePerRapeSliderId, value, "Decrease {1}%")
    ElseIf (option == prideIncreasePercentagePerEnemyKillSliderId)
        PrideIncreasePercentagePerEnemyKill = value
        SetSliderOptionValue(prideIncreasePercentagePerEnemyKillSliderId, value, "Increase {1}%")  
    ElseIf (option == prideIncreasePercentagePerSpellCastSliderId)
        PrideIncreasePercentagePerSpellCast = value
        SetSliderOptionValue(prideIncreasePercentagePerSpellCastSliderId, value, "Increase {1}%")  
    ElseIf (option == willpowerHitPercentagePerRapeSliderId) 
        WillpowerHitPercentagePerRape = value
        SetSliderOptionValue(willpowerHitPercentagePerRapeSliderId, value, "Decrease {1}%")
    ElseIf (option == selfEsteemPeriodicIncreasePerDaySliderId)
        SelfEsteemPeriodicIncreasePerDay = value as int
        SetSliderOptionValue(selfEsteemPeriodicIncreasePerDaySliderId, value, "Increase {0} per day")
    ElseIf (option == statIncreasePercentagePerStealingSliderId)
        StatIncreasePercentagePerStealing = value
        SetSliderOptionValue(statIncreasePercentagePerStealingSliderId, value, "Increase {1}%")
    ElseIf (option == arousalThresholdToIncreaseFetishSliderId)
        ArousalThresholdToIncreaseFetish = value as int
        SetSliderOptionValue(arousalThresholdToIncreaseFetishSliderId, value, "{0}")
    ElseIf (option == obedienceDailyDecreaseSliderId)
        ObedienceDailyDecrease = value as int
        SetSliderOptionValue(obedienceDailyDecreaseSliderId, value, "{0}")
    ElseIf (option == fetishIncrementPerDecisionSliderId)
        FetishIncrementPerDecision = value
        SetSliderOptionValue(fetishIncrementPerDecisionSliderId, value, "{1}")
    ElseIf (option == willpowerBaseDecisionCostSliderId)
        WillpowerBaseDecisionCost = value as int
        SetSliderOptionValue(willpowerBaseDecisionCostSliderId, value, "{0}")
    ElseIf (option == debugPlayerResponseTypeSliderId)
        DebugPlayerResponseType = value as int
        SetSliderOptionValue(debugPlayerResponseTypeSliderId, value, "{0}")
    ElseIf (option == debugPlayerDecisionTypeSliderId)
        DebugPlayerDecisionType = value as int
        SetSliderOptionValue(debugPlayerDecisionTypeSliderId, value, "{0}")
    ElseIf (option == debugExtraPrideChangeSliderId)
        DebugExtraPrideChange = value as int
        SetSliderOptionValue(debugExtraPrideChangeSliderId, value, "{0}")
    ElseIf (option == debugExtraSelfEsteemChangeSliderId)        
        DebugExtraSelfEsteemChange = value as int
        SetSliderOptionValue(debugExtraSelfEsteemChangeSliderId, value, "{0}")
    ElseIf (option == manualSoulStateSliderId)
        Attributes.SetPlayerSoulState(value as int)
        SetSliderOptionValue(manualSoulStateSliderId, value, "{0}")
    ElseIf (option == sdLooksChangePrideHitSliderId)
        SdLooksChangePridePercentageHit = value
        SetSliderOptionValue(sdLooksChangePrideHitSliderId, value, "Decrease {1}%")
    ElseIf (option == sdLooksChangeSelfEsteemHitSliderId)
        SdLooksChangeSelfEsteemPercentageHit = value
        SetSliderOptionValue(sdLooksChangeSelfEsteemHitSliderId, value, "Decrease {1}%")
    ElseIf (option == sdSubSexPrideChangePercentageSliderId)
        SdSubSexPrideChangePercentage = value
        SetSliderOptionValue(sdSubSexPrideChangePercentageSliderId, value, "Change {1}%")
    ElseIf (option == sdSubEntertainSelfEsteemChangePercentageSliderId)
        SdSubEntertainSelfEsteemChangePercentage = value
        SetSliderOptionValue(sdSubEntertainSelfEsteemChangePercentageSliderId, value, "Change {1}%")
    ElseIf (option == selfesteemIncreasePercentagePerConsensualSexSliderId)
        SelfesteemIncreasePercentagePerConsensualSex = value
        SetSliderOptionValue(selfesteemIncreasePercentagePerConsensualSexSliderId, value, "Increase {1}%")
    EndIf

EndEvent

Event OnOptionSelect(int option)
    If (option == resetStatsToggleId)
    	MonitorQuest.SetDefaultStats(false)    	
    ElseIf (option == pauseRefreshTimerToggleId)        
        MonitorQuest.ToggleRefreshRunningState()
        Debug.MessageBox("Exit the menu to apply this change")
        SetToggleOptionValue(pauseRefreshTimerToggleId, IsRunningRefresh)
    ElseIf (option == simulateRapeToggleId)
        Debug.MessageBox("OnPlayerRape() with " + (simulateRapeActorCount as int) + " actors")
        MonitorQuest.OnPlayerRape(simulateRapeActorCount as int)
    ElseIf (option == showDebugMessagesToggleId)
        ShowDebugMessages = !ShowDebugMessages
        SetToggleOptionValue(showDebugMessagesToggleId, ShowDebugMessages)
    ElseIf (option == debugPlayerDecisionToggleId)
        DebugSendPlayerDecision(DebugPlayerResponseType, DebugPlayerDecisionType)
        Debug.MessageBox("Sending player decision, DebugPlayerResponseType=" + DebugPlayerResponseType + ", DebugPlayerDecisionType=" + DebugPlayerDecisionType)
    ElseIf (option == debugPlayerDecisionWithExtraChangesToggleId)
        DebugSendPlayerDecisionWithExtraChanges(DebugPlayerResponseType, DebugPlayerDecisionType, DebugExtraPrideChange, DebugExtraSelfEsteemChange)
        Debug.MessageBox("Sending player decision (with extra changes), DebugPlayerResponseType=" + DebugPlayerResponseType + ", DebugPlayerDecisionType=" + DebugPlayerDecisionType)
    EndIf
EndEvent