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

Spell Property RapeTraumaSpell Auto
Spell Property WhippingConsequenceSpell Auto

Spell Property LowWillpower5Spell Auto
Spell Property LowWillpower10Spell Auto
Spell Property HighWillpower5Spell Auto
Spell Property HighWillpower10Spell Auto

dattLibraries Property Libs Auto
dattAttributes Property Attributes Auto
dattDecisions Property Decisions Auto
dattConstants Property Constants Auto
dattConfigMenu Property Config Auto

Event OnInit()
	Debug.Notification("Devious Attributes Initialized")
	RegisterForEvents()
	SetDefaultStats(true)	
	Libs.Config.IsRunningRefresh = true ;obviously run refreshes by default
	Maintenance()

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
	Else
		If(Libs.Config.ShowDebugMessages)
			Debug.Notification("Devious Attributes -> periodic stat refresh started")
		EndIf
		Libs.Config.IsRunningRefresh = !Libs.Config.IsRunningRefresh
		RegisterForSingleUpdate(1.0)
		RegisterForSingleUpdateGameTime(1.0)
		RegisterForSleep()
	EndIf
EndFunction

;this runs on init and on game load
Function Maintenance()
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> running maintenance...")
	EndIf
	
	RegisterForEvents()
	Libs.Config.CheckSoftDependencies()

	;on game load, make sure we do not go below minimum refresh rate
	If(Libs.Config.RefreshRate < Libs.Config.MinRefreshRate || Libs.Config.RefreshRate > Libs.Config.MaxRefreshRate)
		Libs.Config.RefreshRate = Libs.Config.DefaultRefreshRate
	EndIf

	;on game load if needed start refresh timers
	If(Libs.Config.IsRunningRefresh)
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

	float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId)
	SetRelevantWillpowerSpell(willpower)
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
EndFunction

Function RegisterForEvents()
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> registering events")
	EndIf
	RegisterForModEvent("AnimationEnd", "OnSexAnimationEnd")	
	RegisterForModEvent("OrgasmEnd", "OnOrgasmEnd")
	RegisterForModEvent(Constants.AttributeChangedEventName, "OnAttributeChanged")
	
EndFunction

Event OnOrgasmEnd(string eventName, string argString, float argNum, form sender)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnOrgasmEnd()")
	EndIf	
   float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId) 
   Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId, willpower * (1.0 - (Libs.Config.WillpowerDecreasePerOrgasmPercentage / 100.0)))
EndEvent

float lastWillpowerValue
Event OnAttributeChanged(Form akActor, string attributeId, float value)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> OnAttributeChanged(), attributeId=" + attributeId + ",value=" + value)
	EndIf

	If(attributeId == Constants.WillpowerAttributeId)
		SetRelevantWillpowerSpell(value)
	EndIf
EndEvent

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
EndEvent

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

Function OnPlayerRape(int actorCount)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Mod Event -> OnPlayerRape(), actorCount = " + actorCount)
	EndIf

   	float humiliationMultiplier = 1.0
   	If (actorCount > 2)
   		;more than one agressor, add 10% for each aggressor to multiplier
   		humiliationMultiplier *= ((actorCount - 1) * 1.1)
   	EndIf

   	If(!Libs.PlayerRef.HasSpell(RapeTraumaSpell))
   		StorageUtil.SetIntValue(Libs.PlayerRef as Form, Constants.RapeTraumaDurationId, 12)
   		Libs.PlayerRef.AddSpell(RapeTraumaSpell, false)
   	Else
   		int traumaDuration = StorageUtil.GetIntValue(Libs.PlayerRef, Constants.RapeTraumaDurationId, 0)
   		traumaDuration += 12
   		StorageUtil.SetIntValue(Libs.PlayerRef, Constants.RapeTraumaDurationId, traumaDuration)
   	EndIf

   	;TODO : add humiliation multiplier for each worn devious device by player

;dealing with percentages makes changes non-linear
	float willpower = Attributes.GetPlayerAttribute(Constants.WillpowerAttributeId)
	float selfEsteem = Attributes.GetPlayerAttribute(Constants.SelfEsteemAttributeId)
	float pride = Attributes.GetPlayerAttribute(Constants.PrideAttributeId)

   	pride *= (1.0 - ((Libs.Config.PrideHitPercentagePerRape / 100.0) * humiliationMultiplier))
   	selfEsteem *=  (1.0 - ((Libs.Config.SelfesteemHitPercentagePerRape / 100.0) * humiliationMultiplier))
   	willpower *= (1.0 - ((Libs.Config.WillpowerHitPercentagePerRape / 100.0) * humiliationMultiplier))

	Attributes.SetPlayerAttribute(Constants.PrideAttributeId,pride)
	Attributes.SetPlayerAttribute(Constants.SelfEsteemAttributeId,selfEsteem)
	Attributes.SetPlayerAttribute(Constants.WillpowerAttributeId,willpower)
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