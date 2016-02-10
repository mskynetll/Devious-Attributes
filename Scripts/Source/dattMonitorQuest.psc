Scriptname dattMonitorQuest extends Quest
{monitor player events and change stats accordingly}

;private fields
Float shortRefreshLastUpdateTime
Float periodicUpdatesRefreshLastUpdateTime

;private fields
int attributeChangedEventId
int fetishChangedEventId

;properties
Faction Property ThievesGuildFaction Auto
Faction Property DarkBrotherhoodFaction Auto
Faction Property CollegeOfWinterholdFaction Auto

Faction Property DattRapeTraumaFaction Auto

Spell Property RapeTraumaSpell Auto
Spell Property NewRapeTraumaSpell Auto
Spell Property WhippingConsequenceSpell Auto

Spell Property LowWillpower5Spell Auto
Spell Property LowWillpower10Spell Auto
Spell Property HighWillpower5Spell Auto
Spell Property HighWillpower10Spell Auto

Spell Property LowSelfesteem25Spell Auto
Spell Property LowSelfesteem50Spell Auto
Spell Property HighSelfesteem25Spell Auto
Spell Property HighSelfesteem50Spell Auto

Spell Property LowPride25Spell Auto
Spell Property LowPride50Spell Auto
Spell Property HighPride25Spell Auto
Spell Property HighPride50Spell Auto

dattLibraries Property Libs Auto
dattAttributes Property Attributes Auto
dattDecisions Property Decisions Auto
dattConstants Property Constants Auto
dattConfigMenu Property Config Auto

String Property ModVersion Auto

Float Property LastRapeTraumaChange Auto Hidden
Float Property LastRapeTraumaDurationDelta Auto Hidden

Event OnInit()
	Debug.Notification("Devious Attributes Initialized")
	RegisterForEvents()
	SetDefaultStats(true)	
	Libs.Config.IsRunningRefresh = true ;obviously run refreshes by default
	Libs.Config.VerifyConfigDefaults()
	Maintenance(true)	

	RegisterForSingleUpdate(3.0)
	RegisterForSingleUpdateGameTime(1.0)
	RegisterForSleep()	

	periodicUpdatesRefreshLastUpdateTime = Utility.GetCurrentGameTime()
EndEvent

;starts/stop refresh timer
Function ToggleRefreshRunningState()
	If Libs.Config.IsRunningRefresh
		If(Libs.Config.ShowDebugMessages)
			Debug.Notification("Devious Attributes -> periodic stat refresh stopped")
		EndIf
		Libs.Config.IsRunningRefresh = !Libs.Config.IsRunningRefresh		
		UnregisterForSleep()
		StorageUtil.SetIntValue(Libs.PlayerRef, Constants.IsRunningRefreshId, 0)
	Else
		If(Libs.Config.ShowDebugMessages)
			Debug.Notification("Devious Attributes -> periodic stat refresh started")
		EndIf
		Libs.Config.IsRunningRefresh = !Libs.Config.IsRunningRefresh
		RegisterForSingleUpdate(1.0)
		RegisterForSingleUpdateGameTime(1.0)
		RegisterForSleep()
		StorageUtil.SetIntValue(Libs.PlayerRef, Constants.IsRunningRefreshId, 1)

		int periodicRefreshStartedEventId = ModEvent.Create(Constants.OnPeriodicRefreshStartedEventName)
		If(periodicRefreshStartedEventId)
			ModEvent.Send(periodicRefreshStartedEventId)
		EndIf
	EndIf
EndFunction

;this runs on init and on game load
Function Maintenance(bool isInit = false)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> running maintenance...")
	EndIf

	DoVersionMigrationIfNeeded()

	RegisterForEvents()
	Config.CheckSoftDependencies()

	;on game load, make sure we do not go below minimum refresh rate
	If(Libs.Config.RefreshRate < Libs.Config.MinRefreshRate || Libs.Config.RefreshRate > Libs.Config.MaxRefreshRate)
		Libs.Config.RefreshRate = Libs.Config.DefaultRefreshRate
	EndIf

	;on game load if needed start refresh timers
	If(Libs.Config.IsRunningRefresh == true && isInit == false)
		RegisterForSingleUpdate(1.0)
		RegisterForSingleUpdateGameTime(1.0)
		RegisterForSleep()
	EndIf

	If(Libs.Config.PrideHitPercentagePerRape == 0)
		Libs.Config.PrideHitPercentagePerRape = Libs.Config.DefaultPrideHitPercentagePerRape
	EndIf
	If(Libs.Config.WillpowerHitPercentagePerRape == 0)
		Libs.Config.WillpowerHitPercentagePerRape = Libs.Config.DefaultWillpowerHitPercentagePerRape
	EndIf

	Attributes.Initialize()
	Decisions.Initialize()
	
	CheckReferenceFillings()
	If(Libs.Config.AttributeBuffsEnabled == true)		
		float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId)
		SetRelevantWillpowerSpell(willpower)

		float selfEsteem = Attributes.GetPlayerAttribute(Constants.SelfEsteemAttributeId)
		SetRelevantSelfesteemSpell(selfEsteem)

		float pride = Attributes.GetPlayerAttribute(Constants.PrideAttributeId)
		SetRelevantPrideSpell(pride)
	EndIf

	If(Libs.PlayerRef.HasSpell(NewRapeTraumaSpell) == false)
		Libs.PlayerRef.AddSpell(NewRapeTraumaSpell, false)
	EndIf

	int onMaintenanceEventId = ModEvent.Create(Constants.MaintenanceEventName)
	;send notification to consequences mods so they run maintenance as well
	If(onMaintenanceEventId) 
		ModEvent.Send(onMaintenanceEventId)
	Endif

	If(Config.ShowDebugMessages)
		StorageUtil.SetIntValue(Libs.PlayerRef, Constants.ShowDebugMessagesId, 1)
	Else
		StorageUtil.SetIntValue(Libs.PlayerRef, Constants.ShowDebugMessagesId, 0)
	EndIf

    If(Config.IsRunningRefresh)
        StorageUtil.SetIntValue(Libs.PlayerRef, Constants.IsRunningRefreshId, 1)
    Else
        StorageUtil.SetIntValue(Libs.PlayerRef, Constants.IsRunningRefreshId, 0)
    EndIf 
EndFunction

Function DoVersionMigrationIfNeeded()
	If(ModVersion == "") ;this stuff started 
		Debug.Notification("Devious Attributes - upgrading to 0.5.1")
		Debug.Notification("Attribute buffs disabled. Enable them in MCM menu...")
		ModVersion = "0.5.1"
		Libs.Config.VerifyConfigDefaults()
		Libs.Config.AttributeBuffsEnabled = false
		Libs.Config.PrideEffectMagnitude = 1.0
	EndIf
	If(ModVersion == "0.5.1")
		Debug.Notification("Devious Attributes - upgrading 0.5.1 -> 0.5.2")
		ModVersion = "0.5.2"
		RemoveOldRapeTrauma(true) ;there is a new effect, so remove the old one if it is active

		Libs.PlayerRef.AddToFaction(DattRapeTraumaFaction)
		Libs.PlayerRef.SetFactionRank(DattRapeTraumaFaction, 0)
		Libs.PlayerRef.AddSpell(NewRapeTraumaSpell, false)
		LastRapeTraumaChange = Utility.GetCurrentGameTime()
		Libs.Config.VerifyConfigDefaults()
	EndIf
	If(ModVersion == "0.5.2")
		Debug.Notification("Devious Attributes - upgrading 0.5.2 -> 0.6.0")
		ModVersion = "0.6.0"
		;migrated from using storage util to global variables, so 
		;make sure we don't lose values that existed in previous version
		float willpower = StorageUtil.GetFloatValue(Libs.PlayerRef, Constants.WillpowerAttributeId)
		float pride = StorageUtil.GetFloatValue(Libs.PlayerRef, Constants.PrideAttributeId)
		float selfEsteem = StorageUtil.GetFloatValue(Libs.PlayerRef, Constants.SelfEsteemAttributeId)
		float obedience = StorageUtil.GetFloatValue(Libs.PlayerRef, Constants.ObedienceAttributeId)

		Attributes.SetPlayerAttribute(Constants.PrideAttributeId,pride)
		Attributes.SetPlayerAttribute(Constants.SelfEsteemAttributeId,selfEsteem)
		Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId,willpower)
		Attributes.SetPlayerAttribute(Constants.ObedienceAttributeId,obedience)

		float humiliation = StorageUtil.GetFloatValue(Libs.PlayerRef, Constants.HumiliationLoverAttributeId)
		float masochist = StorageUtil.GetFloatValue(Libs.PlayerRef, Constants.MasochistAttributeId)
		float exhibitionist = StorageUtil.GetFloatValue(Libs.PlayerRef, Constants.ExhibitionistAttributeId)
		float nympho = StorageUtil.GetFloatValue(Libs.PlayerRef, Constants.NymphomaniacAttributeId)

		Attributes.SetPlayerFetish(Constants.HumiliationLoverAttributeId,humiliation)
		Attributes.SetPlayerFetish(Constants.MasochistAttributeId,masochist)
		Attributes.SetPlayerFetish(Constants.ExhibitionistAttributeId, exhibitionist)
		Attributes.SetPlayerFetish(Constants.NymphomaniacAttributeId, nympho)

		int soulState = StorageUtil.GetIntValue(Libs.PlayerRef, Constants.SoulStateAttributeId)
		Attributes.SetPlayerSoulState(soulState)
	EndIf
	If(ModVersion == "0.6.0")
		Debug.Notification("Devious Attributes - upgrading 0.6.0 -> 0.6.1")
		ModVersion = "0.6.1"
		Config.GagPrideReduceTick = Config.DefaultGagPrideReduceTick
		Config.BaseDDTick = Config.DefaultBaseDDTick ;devious devices tick
		Config.CollarSelfEsteemChangeTick = Config.DefaultCollarSelfEsteemChangeTick
		StorageUtil.SetFloatValue(Libs.PlayerRef, Constants.GagPrideReduceTickId, Config.DefaultGagPrideReduceTick)
		StorageUtil.SetFloatValue(Libs.PlayerRef, Constants.BaseDDTickId, Config.DefaultBaseDDTick)
		StorageUtil.SetFloatValue(Libs.PlayerRef, Constants.CollarSelfEsteemChangeTickId, Config.DefaultCollarSelfEsteemChangeTick)
		If(Config.ShowDebugMessages)
			StorageUtil.SetIntValue(Libs.PlayerRef, Constants.ShowDebugMessagesId, 1)
		Else
			StorageUtil.SetIntValue(Libs.PlayerRef, Constants.ShowDebugMessagesId, 0)
		EndIf
	EndIf
	;
EndFunction

Function CheckReferenceFillings()
	If(RapeTraumaSpell == None)
		Debug.MessageBox("Rape trauma spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")
	EndIf

	If(HighWillpower5Spell == None)
		Debug.MessageBox("HighWillpower5Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf
	If(HighWillpower10Spell == None)
		Debug.MessageBox("HighWillpower10Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf
	If(LowWillpower5Spell == None)
		Debug.MessageBox("LowWillpower5Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf
	If(LowWillpower10Spell == None)
		Debug.MessageBox("LowWillpower10Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf

	If(HighSelfesteem25Spell == None)
		Debug.MessageBox("HighSelfesteem25Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf
	If(HighSelfesteem50Spell == None)
		Debug.MessageBox("HighSelfesteem50Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf
	If(LowSelfesteem25Spell == None)
		Debug.MessageBox("LowSelfesteem25Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf
	If(LowSelfesteem50Spell == None)
		Debug.MessageBox("LowSelfesteem50Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf
	If(HighPride25Spell == None)
		Debug.MessageBox("HighPride25Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf
	If(HighPride50Spell == None)
		Debug.MessageBox("HighPride50Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf
	If(LowPride25Spell == None)
		Debug.MessageBox("LowPride25Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf
	If(LowPride50Spell == None)
		Debug.MessageBox("LowPride50Spell spell reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")	
	EndIf

	If(DattRapeTraumaFaction == None)
		Debug.MessageBox("DattRapeTraumaFaction faction reference wasn't filled by the game. This is most likely a bug, and needs to be reported.")		
	EndIf
EndFunction

Function RegisterForEvents()
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> registering events")
	EndIf
	RegisterForModEvent("AnimationEnd", "OnSexAnimationEnd")	
	RegisterForModEvent("OrgasmEnd", "OnOrgasmEnd")
	RegisterForModEvent(Constants.AttributeChangedEventName, "OnAttributeChanged")
	RegisterForModEvent(Constants.EnableAllBuffsEventName, "OnEnableAllBuffs")
	RegisterForModEvent(Constants.DisableAllBuffsEventName, "OnDisableAllBuffs")

	RegisterForModEvent(Constants.SetAttributeEventName, "OnSetAttribute")
	RegisterForModEvent(Constants.ModAttributeEventName, "OnModAttribute")
EndFunction

Event OnSetAttribute(string attributeId, float value)
	Attributes.SetPlayerAttribute(attributeId,value)
EndEvent

Event OnModAttribute(string attributeId, float value)
	Attributes.ModPlayerAttribute(attributeId,value)
EndEvent

Event OnEnableAllBuffs()
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnEnableAllBuffs()")
	EndIf
	float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId)
	SetRelevantWillpowerSpell(willpower)

	float selfEsteem = Attributes.GetPlayerAttribute(Constants.SelfEsteemAttributeId)
	SetRelevantSelfesteemSpell(selfEsteem)

	float pride = Attributes.GetPlayerAttribute(Constants.PrideAttributeId)
	SetRelevantPrideSpell(pride)
EndEvent

Event OnDisableAllBuffs()
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnDisableAllBuffs()")
	EndIf
	RemovePrideSpellIfNeeded()
	RemoveSelfesteemSpellIfNeeded()
	RemoveWillpowerSpellIfNeeded()
EndEvent

Event OnOrgasmEnd(string eventName, string argString, float argNum, form sender)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnOrgasmEnd()")
	EndIf	
   float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId) 
   Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId, willpower * (1.0 - (Libs.Config.WillpowerDecreasePerOrgasmPercentage / 100.0)))
EndEvent

float lastWillpowerValue
Event OnAttributeChanged(Form akActor, string attributeId, float oldValue, float newValue)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnAttributeChanged(), attributeId=" + attributeId + ",value=" + newValue)
	EndIf

	DisplayAttributeChangeMessageIfNeeded(attributeId, oldValue, newValue)
	
	If(Libs.Config.AttributeBuffsEnabled == true)		
		If(attributeId == Constants.WillpowerAttributeId)
			SetRelevantWillpowerSpell(newValue)
		EndIf
		If(attributeId == Constants.SelfEsteemAttributeId)
			SetRelevantSelfesteemSpell(newValue)
		EndIf
		If(attributeId == Constants.PrideAttributeId)
			SetRelevantPrideSpell(newValue)
		EndIf
	EndIf
EndEvent

Function DisplayAttributeChangeMessageIfNeeded(string attributeId, float oldValue, float newValue)
	string msg = ""
	If(attributeId == Constants.WillpowerAttributeId)	
		If((oldValue <= 33 && newValue > 33) || (oldValue <= 66 && newValue > 66) || (oldValue <= 85 && newValue > 85))
			msg = "Your recent experiences make you mentally stronger..."
		ElseIf((oldValue > 25 && newValue <= 25) || (oldValue > 50 && newValue <= 50) || (oldValue > 75 && newValue <= 75))
			msg = "Your recent experiences make you more susceptible to suggestions..."
		EndIf
	ElseIf(attributeId == Constants.SelfEsteemAttributeId)
		If((oldValue <= 25 && newValue > 25) || (oldValue <= 50 && newValue > 50) || (oldValue <= 75 && newValue > 75))
			msg = "Your feel more confident and self-assured..."
		ElseIf((oldValue > 25 && newValue <= 25) || (oldValue > 50 && newValue <= 50) || (oldValue > 75 && newValue <= 75))
			msg = "Your feel less confidence, making you easier prey to predators..."
		EndIf
	ElseIf(attributeId == Constants.PrideAttributeId)
		If((oldValue <= 25 && newValue > 25) || (oldValue <= 50 && newValue > 50) || (oldValue <= 75 && newValue > 75))
			msg = "Your recent actions and experiences make you more pride..."
		ElseIf((oldValue > 25 && newValue <= 25) || (oldValue > 50 && newValue <= 50) || (oldValue > 75 && newValue <= 75))
			msg = "Your recent experiences make you less proud..."
		EndIf		
	EndIf

	If(msg != "")
		Debug.Notification(msg)
	EndIf
EndFunction

Function SetRelevantPrideSpell(float prideValue)	
	If(prideValue >= 75 && !Libs.PlayerRef.HasSpell(HighPride50Spell))
		RemovePrideSpellIfNeeded()
		Libs.PlayerRef.AddSpell(HighPride50Spell, false)
	ElseIf (prideValue >= 50 && prideValue < 75 && !Libs.PlayerRef.HasSpell(HighPride25Spell))
		RemovePrideSpellIfNeeded()
		Libs.PlayerRef.AddSpell(HighPride25Spell, false)
	ElseIf (prideValue < 50 && prideValue >= 25 && !Libs.PlayerRef.HasSpell(LowPride25Spell))
		RemovePrideSpellIfNeeded()
		Libs.PlayerRef.AddSpell(LowPride25Spell, false)			
	ElseIf (prideValue < 25 && !Libs.PlayerRef.HasSpell(LowPride50Spell))
		RemovePrideSpellIfNeeded()
		Libs.PlayerRef.AddSpell(LowPride50Spell, false)			
	EndIf
EndFunction

Function SetRelevantSelfesteemSpell(float selfesteemValue)	
	If(selfesteemValue >= 75 && !Libs.PlayerRef.HasSpell(HighSelfesteem50Spell))
		RemoveSelfesteemSpellIfNeeded()
		Libs.PlayerRef.AddSpell(HighSelfesteem50Spell, false)
	ElseIf (selfesteemValue >= 50 && selfesteemValue < 75 && !Libs.PlayerRef.HasSpell(HighSelfesteem25Spell))
		RemoveSelfesteemSpellIfNeeded()
		Libs.PlayerRef.AddSpell(HighSelfesteem25Spell, false)
	ElseIf (selfesteemValue < 50 && selfesteemValue >= 25 && !Libs.PlayerRef.HasSpell(LowSelfesteem25Spell))
		RemoveSelfesteemSpellIfNeeded()
		Libs.PlayerRef.AddSpell(LowSelfesteem25Spell, false)			
	ElseIf (selfesteemValue < 25 && !Libs.PlayerRef.HasSpell(LowSelfesteem50Spell))
		RemoveSelfesteemSpellIfNeeded()
		Libs.PlayerRef.AddSpell(LowSelfesteem50Spell, false)			
	EndIf
EndFunction

Function SetRelevantWillpowerSpell(float willpowerValue)	
	If(willpowerValue >= 85 && !Libs.PlayerRef.HasSpell(HighWillpower10Spell))
		RemoveWillpowerSpellIfNeeded()
		Libs.PlayerRef.AddSpell(HighWillpower10Spell, false)
	ElseIf (willpowerValue >= 50 && willpowerValue < 85 && !Libs.PlayerRef.HasSpell(HighWillpower5Spell))
		RemoveWillpowerSpellIfNeeded()
		Libs.PlayerRef.AddSpell(HighWillpower5Spell, false)
	ElseIf (willpowerValue < 50 && willpowerValue >= 25 && !Libs.PlayerRef.HasSpell(LowWillpower5Spell))
		RemoveWillpowerSpellIfNeeded()
		Libs.PlayerRef.AddSpell(LowWillpower5Spell, false)			
	ElseIf (willpowerValue < 25 && !Libs.PlayerRef.HasSpell(LowWillpower10Spell))
		RemoveWillpowerSpellIfNeeded()
		Libs.PlayerRef.AddSpell(LowWillpower10Spell, false)			
	EndIf
EndFunction

Function RemovePrideSpellIfNeeded()
	int dispelPrideEffectEventId = ModEvent.Create(Constants.PrideEffectEndEventName)
	If(dispelPrideEffectEventId)
		ModEvent.Send(dispelPrideEffectEventId)
	EndIf

	If(Libs.PlayerRef.HasSpell(HighPride25Spell))
		Libs.PlayerRef.DispelSpell(HighPride25Spell)
		Libs.PlayerRef.RemoveSpell(HighPride25Spell)
	EndIf
	If(Libs.PlayerRef.HasSpell(HighPride50Spell))
		Libs.PlayerRef.DispelSpell(HighPride50Spell)
		Libs.PlayerRef.RemoveSpell(HighPride50Spell)
	EndIf
	If(Libs.PlayerRef.HasSpell(LowPride25Spell))
		Libs.PlayerRef.DispelSpell(LowPride25Spell)
		Libs.PlayerRef.RemoveSpell(LowPride25Spell)
	EndIf
	If(Libs.PlayerRef.HasSpell(LowPride50Spell))
		Libs.PlayerRef.DispelSpell(LowPride50Spell)
		Libs.PlayerRef.RemoveSpell(LowPride50Spell)
	EndIf
EndFunction

Function RemoveSelfesteemSpellIfNeeded()
	int dispelSelfEsteemEffectEventId = ModEvent.Create(Constants.SelfEsteemEffectEndEventName)
	If(dispelSelfEsteemEffectEventId)
		ModEvent.Send(dispelSelfEsteemEffectEventId)
	EndIf

	If(Libs.PlayerRef.HasSpell(HighSelfesteem25Spell))
		Libs.PlayerRef.DispelSpell(HighSelfesteem25Spell)
		Libs.PlayerRef.RemoveSpell(HighSelfesteem25Spell)
	EndIf
	If(Libs.PlayerRef.HasSpell(HighSelfesteem50Spell))
		Libs.PlayerRef.DispelSpell(HighSelfesteem50Spell)
		Libs.PlayerRef.RemoveSpell(HighSelfesteem50Spell)
	EndIf
	If(Libs.PlayerRef.HasSpell(LowSelfesteem25Spell))
		Libs.PlayerRef.DispelSpell(LowSelfesteem25Spell)
		Libs.PlayerRef.RemoveSpell(LowSelfesteem25Spell)
	EndIf
	If(Libs.PlayerRef.HasSpell(LowSelfesteem50Spell))
		Libs.PlayerRef.DispelSpell(LowSelfesteem50Spell)
		Libs.PlayerRef.RemoveSpell(LowSelfesteem50Spell)
	EndIf
EndFunction

Function RemoveWillpowerSpellIfNeeded()
	int dispelWillpowerEffectEventId = ModEvent.Create(Constants.WillpowerEffectEndEventName)
	If(dispelWillpowerEffectEventId)
		ModEvent.Send(dispelWillpowerEffectEventId)
	EndIf

	If(Libs.PlayerRef.HasSpell(HighWillpower5Spell))
		Libs.PlayerRef.DispelSpell(HighWillpower5Spell)
		Libs.PlayerRef.RemoveSpell(HighWillpower5Spell)
	EndIf
	If(Libs.PlayerRef.HasSpell(HighWillpower10Spell))
		Libs.PlayerRef.DispelSpell(HighWillpower10Spell)
		Libs.PlayerRef.RemoveSpell(HighWillpower10Spell)
	EndIf
	If(Libs.PlayerRef.HasSpell(LowWillpower5Spell))
		Libs.PlayerRef.DispelSpell(LowWillpower5Spell)
		Libs.PlayerRef.RemoveSpell(LowWillpower5Spell)
	EndIf
	If(Libs.PlayerRef.HasSpell(LowWillpower10Spell))
		Libs.PlayerRef.DispelSpell(LowWillpower10Spell)
		Libs.PlayerRef.RemoveSpell(LowWillpower10Spell)
	EndIf
EndFunction

float sleepStartTime

Event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)	
	sleepStartTime = afSleepStartTime
EndEvent

Event OnSleepStop(bool abInterrupted)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnSleepStop()")
	EndIf

	float hoursPassed = Math.abs((sleepStartTime - Utility.GetCurrentGameTime()) * 24)
	OnPeriodicStatsUpdate(hoursPassed)

	float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId)
	willpower = Max(Constants.MaxStatValue, willpower + (hoursPassed * Libs.Config.WillpowerIncreasePerSleepHour))
	Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId, willpower)

	UpdateRapeTraumaLevelIfNeeded()
EndEvent

;do all sorts of calculations at the end of the day
;if one would be sleeping 
Event OnUpdateGameTime()
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnUpdateGameTime()")
	EndIf
	Float hoursPassed = (Utility.GetCurrentGameTime() - periodicUpdatesRefreshLastUpdateTime) * 24
	OnPeriodicStatsUpdate(hoursPassed)

	If Libs.Config.IsRunningRefresh
		;for now this is hardcoded, because it makes sense
		;that stats like self-esteem improve only once in a while -> i.e slowly
		RegisterForSingleUpdateGameTime(12.0)
	EndIf
	
	int onUpdateGameTimeEventId = ModEvent.Create("Datt_OnPeriodicUpdateEventName")	
	If(onUpdateGameTimeEventId)		
		ModEvent.PushFloat(onUpdateGameTimeEventId,hoursPassed)
		ModEvent.Send(onUpdateGameTimeEventId)	
	EndIf

	UpdateRapeTraumaLevelIfNeeded()	
EndEvent

Function UpdateRapeTraumaLevelIfNeeded()
	float hoursPassed = Math.abs(Utility.GetCurrentGameTime() - LastRapeTraumaChange) * 24.0
	float rapeTraumaLevel = Libs.PlayerRef.GetFactionRank(DattRapeTraumaFaction)
	If(hoursPassed >= LastRapeTraumaDurationDelta && rapeTraumaLevel > 0)
		Debug.Notification("Recent traumatic experience fades away, becoming more distant...")
		Libs.PlayerRef.ModFactionRank(DattRapeTraumaFaction, -1)

		Libs.PlayerRef.RemoveSpell(NewRapeTraumaSpell)	
		Libs.PlayerRef.AddSpell(NewRapeTraumaSpell, false)

		LastRapeTraumaChange = Utility.GetCurrentGameTime()

		float masochism = Attributes.GetPlayerFetish(Constants.MasochistAttributeId)
		float nympho = Attributes.GetPlayerFetish(Constants.NymphomaniacAttributeId)
		float lessTraumaMultiplier
		If(masochism >= 95.0 || nympho >= 95.0)
			;even if the fetishes are at max, there is still minimum damage from rape
			lessTraumaMultiplier = 0.05 
		Else
			lessTraumaMultiplier = 1.0 - (((0.5 * masochism) + (0.5 * nympho)) / 100.0)
		Endif
		LastRapeTraumaDurationDelta = Libs.Config.RapeTraumaDurationHours * lessTraumaMultiplier		

		If(Libs.PlayerRef.GetFactionRank(DattRapeTraumaFaction) > 0)			
   			float traumaDuration = StorageUtil.GetFloatValue(Libs.PlayerRef as Form, Constants.RapeTraumaDurationId, 0)   		
   			StorageUtil.SetFloatValue(Libs.PlayerRef as Form, Constants.RapeTraumaDurationId, traumaDuration - LastRapeTraumaDurationDelta)		
   		Else
   			StorageUtil.SetFloatValue(Libs.PlayerRef as Form, Constants.RapeTraumaDurationId, 0)
		EndIf

		RegisterForSingleUpdateGameTime(LastRapeTraumaDurationDelta)
	EndIf
EndFunction

Event OnUpdate()
	float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId)
	float selfEsteem = Attributes.GetPlayerAttribute(Constants.SelfEsteemAttributeId)
	if (willpower < Constants.MinStatValue)
		If(Libs.Config.ShowDebugMessages)
			Debug.Notification("Event -> OnUpdate(), Willpower < MinStatValue")
		EndIf
		willpower = Constants.MinStatValue		
	ElseIf (willpower > selfEsteem)
		If(Libs.Config.ShowDebugMessages)
			Debug.Notification("Event -> OnUpdate(), Willpower > SelfEsteem")
		EndIf
		willpower = selfEsteem		
	Else
		float pride = Attributes.GetPlayerAttribute(Constants.PrideAttributeId)
		float tickBonus = (0.05 * SelfEsteem) + (0.05 * pride)
		;if doing update for the first time, do nothing - will update stats next time		
		If (shortRefreshLastUpdateTime > 0.0)
			float hoursSinceLastUpdate = (Utility.GetCurrentGameTime() - shortRefreshLastUpdateTime) * 24
			willpower = Min(Constants.MaxStatValue,willpower + ((tickBonus + Libs.Config.WillpowerBaseTickPerTimeUnit) * hoursSinceLastUpdate))
			If(Libs.Config.ShowDebugMessages)
				Debug.Notification("Event -> OnUpdate(), Willpower =" + Willpower)
			EndIf
		EndIf
	EndIf
	Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId, willpower)
	If Libs.Config.IsRunningRefresh
		RegisterForSingleUpdate(Libs.Config.RefreshRate)
	EndIf

	shortRefreshLastUpdateTime = Utility.GetCurrentGameTime()
EndEvent

Function OnPeriodicStatsUpdate(Float hoursPassed)	
	;first time always do the update
	int playerSoulState = Attributes.GetPlayerSoulState()
	If(periodicUpdatesRefreshLastUpdateTime == 0 || hoursPassed >= 12)
		If(Libs.Config.ShowDebugMessages)
			Debug.Notification("OnPeriodicStatsUpdate(), hoursPassed >= 12")
		EndIf

		;self-esteem can't go up if player is not free
		;obedience is less only if player is free
		If(playerSoulState == Constants.State_FreeSpirit)
			float selfEsteem = Attributes.GetPlayerAttribute(Constants.SelfEsteemAttributeId)
			Attributes.SetPlayerAttribute(Constants.SelfEsteemAttributeId,selfEsteem + Libs.Config.SelfEsteemPeriodicIncreasePerDay)
	
		EndIf	

		;conditioning to obey needs to be constantly reinforced, otherwise...
		float obedience = Attributes.GetPlayerAttribute(Constants.ObedienceAttributeId)
		Attributes.SetPlayerAttribute(Constants.ObedienceAttributeId, obedience - Libs.Config.ObedienceDailyDecrease)
	Else
		If(Libs.Config.ShowDebugMessages)
			Debug.Notification("OnPeriodicStatsUpdate(), hoursPassed < 12")
		EndIf
	EndIf	

	float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId)
	float selfEsteem = Attributes.GetPlayerAttribute(Constants.SelfEsteemAttributeId)
	float pride = Attributes.GetPlayerAttribute(Constants.PrideAttributeId)
	float tickBonus = (0.01 * SelfEsteem) + (0.01 * pride)
	
	willpower = Min(Constants.MaxStatValue,willpower + ((tickBonus + Libs.Config.WillpowerBaseTickPerTimeUnit) * hoursPassed))
	Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId, willpower)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Event -> OnPeriodicStatsUpdate(), Willpower =" + Willpower)
	EndIf
	periodicUpdatesRefreshLastUpdateTime = Utility.GetCurrentGameTime()
EndFunction

float lastSpellCastTime
Function OnPlayerCastMagic(Form spell)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("OnPlayerCastMagic()")
	EndIf

	float hoursPassed = (Utility.GetCurrentGameTime() - lastSpellCastTime) * 24.0

	;increase pride for spells only once per hour
	If (lastSpellCastTime == 0 || hoursPassed >= 1)
		float pride = Attributes.GetPlayerAttribute(Constants.PrideAttributeId)
		float bonusMultiplier = 1.0
		If(Libs.PlayerRef.IsInFaction(CollegeOfWinterholdFaction))
			bonusMultiplier *= 2
		EndIf
		float prideMultiplier = 1.0 + ((Libs.Config.PrideIncreasePercentagePerSpellCast * bonusMultiplier) / 100.0)

		pride *= prideMultiplier
		Attributes.SetPlayerAttribute(Constants.PrideAttributeId,pride)
	EndIf

	lastSpellCastTime = Utility.GetCurrentGameTime()
EndFunction

Function OnPlayerKill(Actor victim, int relationshipRank)	
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("OnPlayerKill -> victim lvl=" + victim.GetLevel() + ",player lvl=" + Libs.PlayerRef.GetLevel())
	EndIf

	float bonusMultiplier = 1.0
	If(Libs.PlayerRef.IsInFaction(DarkBrotherhoodFaction))
		bonusMultiplier = 2.0
	EndIf
	float killPrideMultiplier = 1.0 + ((Libs.Config.PrideIncreasePercentagePerEnemyKill * bonusMultiplier) / 100.0)
	float pride = Attributes.GetPlayerAttribute(Constants.PrideAttributeId)

	;increase pride only if you kill you own or one level below at minimum
	;this is in case the player has mods that modify/stop scaling installed
	If(Libs.PlayerRef.GetLevel() >= victim.GetLevel() - 1 && relationshipRank <= 0)		
		pride *= killPrideMultiplier
		Attributes.SetPlayerAttribute(Constants.PrideAttributeId,pride)
	EndIf
EndFunction

Event OnSexAnimationEnd(string eventName, string argString, float argNum, form sender)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Event -> OnSexAnimationEnd()")
	EndIf
    sslThreadController controller = Libs.SexLab.HookController(argString)
    If (controller.IsVictim(Libs.PlayerRef))
		OnPlayerRape(controller.ActorCount)    	
    Else
    	float selfEsteem = Attributes.GetPlayerAttribute(Constants.SelfEsteemAttributeId)
    	float nymphoMultiplier = 1.0 + (Attributes.GetPlayerFetish(Constants.NymphomaniacAttributeId) / 100.0)
    	selfEsteem *= ((1.0 + (Config.SelfesteemIncreasePercentagePerConsensualSex / 100.0)) * nymphoMultiplier)
    	Attributes.SetPlayerAttribute(Constants.SelfEsteemAttributeId,selfEsteem)
    EndIf    
EndEvent

;helpers
Function OnPlayerStealOrPickpocket(int goldAmount)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("OnPlayerStealOrPickpocket(), goldAmount = " + goldAmount)
	EndIf
	float selfEsteem = Attributes.GetPlayerAttribute(Constants.SelfEsteemAttributeId)
	float pride = Attributes.GetPlayerAttribute(Constants.PrideAttributeId)

	If(Libs.PlayerRef.IsInFaction(ThievesGuildFaction))
		float multiplier = 1.0 + (Libs.Config.PrideIncreasePercentagePerEnemyKill / 100.0)
		pride *= multiplier
		selfEsteem *= multiplier
		If(goldAmount > 0)
			pride += Min(goldAmount / 1000, 10)
			selfEsteem += Min(goldAmount / 1000, 10)
		EndIf
		Attributes.SetPlayerAttribute(Constants.PrideAttributeId,pride)
		Attributes.SetPlayerAttribute(Constants.SelfEsteemAttributeId,selfEsteem)
	EndIf
EndFunction

Function RemoveOldRapeTrauma(bool resetTraumaDuration)
	If(Libs.PlayerRef.HasSpell(RapeTraumaSpell))
		Libs.PlayerRef.DispelSpell(RapeTraumaSpell)
		Libs.PlayerRef.RemoveSpell(RapeTraumaSpell)		
	
		int dispelEffectEventId = ModEvent.Create(Constants.RapeTraumaEffectEndEventName)
		If(dispelEffectEventId)
			ModEvent.Send(dispelEffectEventId)
		EndIf
	EndIf

	If(resetTraumaDuration == true)
		StorageUtil.SetFloatValue(Libs.PlayerRef as Form, Constants.RapeTraumaDurationId, 0.0)
		StorageUtil.SetIntValue(Libs.PlayerRef as Form, Constants.RapeTraumaLevelId, 0)
	EndIf
EndFunction


Function OnPlayerRape(int actorCount)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Mod Event -> OnPlayerRape(), actorCount = " + actorCount)
	EndIf

   	float humiliationMultiplier = 1.0
   	If (actorCount > 2)
   		;more than one agressor, add 10% for each aggressor to multiplier
   		humiliationMultiplier *= ((actorCount - 1) * 1.1)
   	EndIf

   	ApplyRapeTrauma()

   	int wornDeviceCount = StorageUtil.GetIntValue(Libs.PlayerRef, "_Datt_Device_Count")

   	;increase hit by 5% for each worn device
   	float deviceHumiliationMultiplier = 1.0 + (0.05 * wornDeviceCount)

;dealing with percentages makes changes non-linear
	float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId)
	float selfEsteem = Attributes.GetPlayerAttribute(Constants.SelfEsteemAttributeId)
	float pride = Attributes.GetPlayerAttribute(Constants.PrideAttributeId)

   	pride *= (1.0 - ((Libs.Config.PrideHitPercentagePerRape / 100.0) * humiliationMultiplier * deviceHumiliationMultiplier))
   	selfEsteem *=  (1.0 - ((Libs.Config.SelfesteemHitPercentagePerRape / 100.0) * humiliationMultiplier * deviceHumiliationMultiplier))
   	willpower *= (1.0 - ((Libs.Config.WillpowerHitPercentagePerRape / 100.0) * humiliationMultiplier * deviceHumiliationMultiplier))

	Attributes.SetPlayerAttribute(Constants.PrideAttributeId,pride)
	Attributes.SetPlayerAttribute(Constants.SelfEsteemAttributeId,selfEsteem)
	Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId,willpower)
EndFunction

Function RemoveRapeTrauma()
	Libs.PlayerRef.SetFactionRank(DattRapeTraumaFaction, 0)
EndFunction

float Function GetRapeTraumaLevel()
	return Libs.PlayerRef.GetFactionRank(DattRapeTraumaFaction)
EndFunction

Function ApplyRapeTrauma()
	float masochism = Attributes.GetPlayerFetish(Constants.MasochistAttributeId)
	float nympho = Attributes.GetPlayerFetish(Constants.NymphomaniacAttributeId)
	float lessTraumaMultiplier
	If(masochism >= 95.0 || nympho >= 95.0)
		;even if the fetishes are at max, there is still minimum damage from rape
		lessTraumaMultiplier = 0.05 
	Else
		lessTraumaMultiplier = 1.0 - (((0.5 * masochism) + (0.5 * nympho)) / 100.0)
	Endif
	float traumaDurationDelta
   	If(!Libs.PlayerRef.HasSpell(NewRapeTraumaSpell))
   		float traumaDuration = Libs.Config.RapeTraumaDurationHours * lessTraumaMultiplier
   		traumaDurationDelta = traumaDuration
   		StorageUtil.SetFloatValue(Libs.PlayerRef as Form, Constants.RapeTraumaDurationId, traumaDuration)   		
   	Else
   		float traumaDuration = StorageUtil.GetFloatValue(Libs.PlayerRef as Form, Constants.RapeTraumaDurationId, 0)   		
   		traumaDurationDelta = Libs.Config.RapeTraumaDurationHours * lessTraumaMultiplier
   		traumaDuration += traumaDurationDelta
   		StorageUtil.SetFloatValue(Libs.PlayerRef as Form, Constants.RapeTraumaDurationId, traumaDuration)		
   	EndIf	

	Libs.PlayerRef.ModFactionRank(DattRapeTraumaFaction, 1)
	Libs.PlayerRef.RemoveSpell(NewRapeTraumaSpell)	
	Libs.PlayerRef.AddSpell(NewRapeTraumaSpell, false)
	LastRapeTraumaChange = Utility.GetCurrentGameTime()
	RegisterForSingleUpdateGameTime(traumaDurationDelta)
	LastRapeTraumaDurationDelta = traumaDurationDelta
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

; Debugging functions
Function SetDefaultStats(bool isInit)
	If (!isInit)		
		Debug.MessageBox("Resetting Devious Attributes to default values")
	EndIf

	Attributes.SetPlayerAttribute(Constants.PrideAttributeId,Constants.DefaultPride)
	Attributes.SetPlayerAttribute(Constants.SelfEsteemAttributeId,Constants.DefaultSelfEsteem)
	Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId,Constants.DefaultWillpower)
	Attributes.SetPlayerAttribute(Constants.ObedienceAttributeId,Constants.DefaultObedience)

	Attributes.SetPlayerFetish(Constants.HumiliationLoverAttributeId,0.0)
	Attributes.SetPlayerFetish(Constants.MasochistAttributeId,0.0)
	Attributes.SetPlayerFetish(Constants.ExhibitionistAttributeId, 0.0)
	Attributes.SetPlayerFetish(Constants.NymphomaniacAttributeId, 0.0)

EndFunction