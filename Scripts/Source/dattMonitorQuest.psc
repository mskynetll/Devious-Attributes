Scriptname dattMonitorQuest Extends dattQuestBase

dattAttributeTrackerQuest Property AttributeTracker Auto
dattPeriodicEventsQuest Property PeriodicEvents Auto 
dattNPCScannerQuest Property NPCScanner Auto
SexLabFramework Property SexLab Auto
dattAttributesAPIQuest Property AttributesAPI Auto
slaFrameworkScr Property SexLabAroused Auto
Spell Property AfterOrgasmSpell Auto
Faction Property dattRapeTraumaFaction Auto
Faction Property ThievesGuildFaction Auto
Faction Property DarkBrotherhoodFaction Auto
Actor Property PlayerRef Auto

Bool Property OneTimeInitialize Auto Hidden
String Property ModVersion Auto Hidden

Event OnInit()
	Maintenance()
EndEvent

Function Maintenance()
	DoVersionUpgrade()

	AttributeTracker.Maintenance()
	PeriodicEvents.Maintenance()
	NPCScanner.Maintenance()
	 
	RegisterForModEvent("AnimationStart", "OnSexAnimationStart") 
	RegisterForModEvent("AnimationEnd", "OnSexAnimationEnd") 
	RegisterForModEvent("OrgasmStart ", "OnOrgasmStart")
	RegisterForModEvent("OrgasmEnd", "OnOrgasmEnd")
	RegisterForModEvent("Datt_Simulate_Rape", "OnSimulateRapeSex")
	Debug.Notification("Devious Attributes is loaded and tracking stuff...")	

	LastSpellCastTime = Utility.GetCurrentGameTime()
EndFunction

Function DoVersionUpgrade()
	If ModVersion == "" || ModVersion == "0.6.3"
		If !OneTimeInitialize
			int resetToDefaultsEventId = ModEvent.Create("Datt_SetDefaults")
		    If resetToDefaultsEventId
		        ModEvent.PushForm(resetToDefaultsEventId, PlayerRef as Form)
		        ModEvent.Send(resetToDefaultsEventId)
		    Else
		        ModEvent.Release(resetToDefaultsEventId)
		    EndIf	
		    OneTimeInitialize = true
		EndIf
		ModVersion = "0.7.0"	
	EndIf
	If ModVersion == "0.7.0"
		int resetToDefaultsEventId = ModEvent.Create("Datt_SetDefaults")
		If resetToDefaultsEventId
		    ModEvent.PushForm(resetToDefaultsEventId, PlayerRef as Form)
		    ModEvent.Send(resetToDefaultsEventId)
		Else
		    ModEvent.Release(resetToDefaultsEventId)
		EndIf	
		OneTimeInitialize = true
		Config.FrequentEventUpdateLatency = 30
		Config.PeriodicEventUpdateLatencyHours = 12
		ModVersion = "0.7.1"	
	EndIf
	If ModVersion == "0.7.1"
		ModVersion = "0.7.2"
		Config.IsLogging = true
	EndIf

	If ModVersion == "0.7.2"
		int resetToDefaultsEventId = ModEvent.Create("Datt_SetDefaults")
        If resetToDefaultsEventId
            ModEvent.PushForm(resetToDefaultsEventId, PlayerRef as Form)
            If ModEvent.Send(resetToDefaultsEventId) == true
                Log("Sending Datt_SetDefaults -> attributes reset to defaults..")
            Else
                Log("Sending Datt_SetDefaults, sending the event failed. Please try again. (Do you have script lag?)")
            EndIf
        Else
            ModEvent.Release(resetToDefaultsEventId)
            Log("Sending Datt_SetDefaults, ModEvent didn't create the event properly")
        EndIf         
        ModVersion = "0.7.3"        
	EndIf
	If ModVersion == "0.7.3"
		Config.WillpowerBaseChange = 10
		Config.FrequentEventUpdateLatency = 1
		Config.WillpowerChangePerOrgasm = 5
		Config.WillpowerChangePerRape = 20
		StorageUtil.SetFloatValue(None, "_datt_periodic_event_last_frequent_update", Utility.GetCurrentGameTime())
		StorageUtil.SetFloatValue(None, "_datt_periodic_event_last_periodic_update", Utility.GetCurrentGameTime())
		ModVersion = "0.7.4"        
	EndIf
	Debug.Notification("Devious Attributes is running version " + ModVersion)
EndFunction

Function ForceNPCScan()
	dattUtility.SendParameterlessEvent("Datt_ForceNPCScan")
EndFunction

Function OnPlayerKill(Actor victimActor,int aiRelationshipRank)		
	float bonusMultiplier = 1.0
	If PlayerRef.IsInFaction(DarkBrotherhoodFaction)
		bonusMultiplier = 1.5
	EndIf

	;increase pride only if you kill you own or one level below at minimum
	;this is in case the player has mods that modify/stop scaling installed
	If(PlayerRef.GetLevel() >= victimActor.GetLevel() - 1 && aiRelationshipRank <= 0)		
		float sadismLevel = AttributesAPI.GetAttribute(PlayerRef,Config.SadistAttributeId)
		int modPride = Math.floor(bonusMultiplier * Config.PrideChangePerPlayerKill * (1.0 + (sadismLevel * 0.1)))
		Log("OnPlayerKill - mod pride by " + modPride + ", Player lvl = " + PlayerRef.GetLevel() + ", victim lvl = " + victimActor.GetLevel() + ", relationship rank = " + aiRelationshipRank)
		AttributesAPI.ModAttribute(PlayerRef,Config.PrideAttributeId, modPride)
		float currentTime = Utility.GetCurrentGameTime()
		If LastSelfEsteemForKillUpdateTime == 0.0 || Math.abs(currentTime - LastSelfEsteemForKillUpdateTime) * 24.0 >= 24.0
			AttributesAPI.ModAttribute(PlayerRef,Config.SelfEsteemAttributeId, 2)
			LastSelfEsteemForKillUpdateTime = currentTime
		EndIf
	Else
		Log("OnPlayerKill, victim is " + victimActor.GetBaseObject().GetName())
		Log("OnPlayerKill - nothing to do, Player lvl = " + PlayerRef.GetLevel() + ", victim lvl = " + victimActor.GetLevel() + ", relationship rank = " + aiRelationshipRank)
	EndIf
	

	dattUtility.SendEventWithFormParam("Datt_PlayerKill", victimActor as Form)
EndFunction

Function OnPlayerStealOrPickpocket(int goldAmount)
	Log("OnPlayerStealOrPickpocket, gold amount : " + goldAmount)
	If PlayerRef.IsInFaction(ThievesGuildFaction)
		AttributesAPI.ModAttribute(PlayerRef,Config.PrideAttributeId, Config.AttributeChangePerStealOrPickpocket)
		AttributesAPI.ModAttribute(PlayerRef,Config.SelfEsteemAttributeId, Config.AttributeChangePerStealOrPickpocket)
	EndIf

	dattUtility.SendEventWithIntParam("Datt_PlayerSteal",goldAmount)
EndFunction

Function OnPlayerCastMagic(Form castSpell)
	Log("OnPlayerCastMagic, spell that was cast : " + castSpell.GetName())
	float currentTime = Utility.GetCurrentGameTime()

	;TODO : make pride increase configurable
	If Math.abs(currentTime - LastSpellCastTime) * 24 >= Config.PeriodicEventUpdateLatencyHours
		Log("OnPlayerCastMagic, modifying PC pride by 5")
		AttributesAPI.ModAttribute(PlayerRef,Config.PrideAttributeId, 5)
		dattUtility.SendEventWithFormParam("Datt_PlayerCastSpell",castSpell)
	Else
		Log("OnPlayerCastMagic in cooldown, no attributes modified..")		
	EndIf
	LastSpellCastTime = currentTime
EndFunction

Event OnSexAnimationStart(string eventName, string argString, float argNum, form sender)		
    Actor[] participants = Sexlab.HookActors(argString)
    int index = 0
	While index < participants.Length
		Actor currentParticipant = participants[index]
		int arousal = SexLabAroused.GetActorArousal(currentParticipant)
		Log("OnSexAnimationStart for " + currentParticipant.GetBaseObject().GetName() + ", arousal = " + arousal)    
		StorageUtil.SetIntValue(currentParticipant, "_datt_last_arousal", arousal)
		index += 1
	EndWhile
EndEvent

Event OnSexAnimationEnd(string eventName, string argString, float argNum, form sender)	    
    Actor[] participants = Sexlab.HookActors(argString)
    Actor victim = Sexlab.HookVictim(argString)
	If victim != None ;non-consensual
		OnRapeSex(victim,participants.Length - 1)
	Else
		sslBaseAnimation animationUsed = SexLab.HookAnimation(argString)
		OnConsensualSex(participants, animationUsed)
	EndIf 
EndEvent

Event OnSimulateRapeSex(Form victim, int agressorCount)
	OnRapeSex(victim as Actor, agressorCount)
EndEvent

Event OnRapeSex(Actor victim, int agressorCount)
	Log("OnRapeSex, victim is " + victim.GetBaseObject().GetName() + ", agressors count = " + agressorCount)
	dattPeriodicEventsHelper.SetTrauma("Rape",victim,dattRapeTraumaFaction, agressorCount * 10)
   	int wornDeviceCount = dattUtility.MaxInt(1,StorageUtil.GetIntValue(victim, "_datt_worn_device_count"))
	int nymphoBonus = AttributesAPI.GetAttribute(victim, Config.NymphomaniacAttributeId) / (wornDeviceCount * 10)

   	AttributesAPI.ModAttribute(victim,Config.WillpowerAttributeId, (-1 * Config.WillpowerChangePerRape) - (2*agressorCount) + nymphoBonus)
	AttributesAPI.ModAttribute(victim,Config.PrideAttributeId, (-1 * Config.PrideChangePerRape) - agressorCount + (nymphoBonus / 2))
	AttributesAPI.ModAttribute(victim,Config.SelfEsteemAttributeId, (-1 * Config.SelfEsteemChangePerRape) - agressorCount)
EndEvent

Event OnConsensualSex(Actor[] participants,sslBaseAnimation animationUsed)
	int index = 0
	Log("OnConsensualSex, participant count =" + participants.Length)
	While index < participants.Length
		Actor currentParticipant = participants[index]

	   	float lastTimeHadSex = StorageUtil.GetFloatValue(currentParticipant, "_datt_last_time_had_sex", 0.0)
	   	StorageUtil.SetFloatValue(currentParticipant, "_datt_last_time_had_sex", Utility.GetCurrentGameTime())
	   	float hoursPassedSinceHadSex

	   	If lastTimeHadSex == 0.0
	   		hoursPassedSinceHadSex = 6.0
	   	Else
	   		hoursPassedSinceHadSex = Math.abs(Utility.GetCurrentGameTime() - lastTimeHadSex) * 24.0
	   	EndIf

	   	If lastTimeHadSex > 0.0
	   		int arousal = StorageUtil.GetIntValue(currentParticipant, "_datt_last_arousal")
	   		If arousal >= 75 && hoursPassedSinceHadSex >= Config.IntervalBetweenSexToIncreaseNymphoHours
	   			Log("Adjusting nympho value for " + currentParticipant.GetBaseObject().GetName() + ", adjusted by " + Config.NymphoIncreasePerConsensual)
	   			AttributesAPI.ModAttribute(currentParticipant,Config.NymphomaniacAttributeId, Config.NymphoIncreasePerConsensual)
	   		EndIf
	   	EndIf		

		int nymphoBonus = Math.floor(AttributesAPI.GetAttribute(currentParticipant, Config.NymphomaniacAttributeId) / 10)
		If currentParticipant == PlayerRef
			int soulState = AttributesAPI.GetAttribute(currentParticipant,Config.SoulStateAttributeId)

			;if forced slave, no self-esteem gains from sex
			If soulState != 1 && hoursPassedSinceHadSex >= 6.0
				ApplyChangesToPlayer(animationUsed)
			EndIf
	   	ElseIf hoursPassedSinceHadSex >= 6.0 ;perhaps make it configurable?
			AttributesAPI.ModAttribute(currentParticipant,Config.SelfEsteemAttributeId, 5 + nymphoBonus)
		EndIf

		If nymphoBonus / 2 > 0
			AttributesAPI.ModAttribute(currentParticipant,Config.PrideAttributeId, nymphoBonus / 2)
		EndIf

		index += 1
	EndWhile	
EndEvent

Function ApplyChangesToPlayer(sslBaseAnimation animationUsed)
	If animationUsed.HasTag("Oral")
		int oralLevel = dattUtility.LimitValueInt(SexLab.GetPlayerStatLevel("Oral"),0,6)
		If oralLevel > 0
			Log("Animation with 'Oral' tag detected, oral proficiency = " + oralLevel + ",adjusting PC self-esteem by " + (oralLevel / 2))
			AttributesAPI.ModAttribute(PlayerRef,Config.SelfEsteemAttributeId, oralLevel / 2)
		EndIf
	ElseIf animationUsed.HasTag("Vaginal")
		int vaginalLevel = dattUtility.LimitValueInt(SexLab.GetPlayerStatLevel("Vaginal"),0,6)

		If vaginalLevel > 0
			Log("Animation with 'Vaginal' tag detected, Vaginal proficiency = " + vaginalLevel + ",adjusting PC self-esteem by " + (vaginalLevel / 2))
			AttributesAPI.ModAttribute(PlayerRef,Config.SelfEsteemAttributeId, vaginalLevel / 2)
		EndIf
	ElseIf animationUsed.HasTag("Anal")
		int analLevel = dattUtility.LimitValueInt(SexLab.GetPlayerStatLevel("Anal"),0,6)

		If analLevel > 0
			Log("Animation with 'Anal' tag detected, Anal proficiency = " + analLevel + ",adjusting PC self-esteem by " + (analLevel / 2))
			AttributesAPI.ModAttribute(PlayerRef,Config.SelfEsteemAttributeId, analLevel / 2)
		EndIf
	EndIf	
EndFunction


Event OnOrgasmEnd(string eventName, string argString, float argNum, form sender)
	Actor[] participants = Sexlab.HookActors(argString)
	sslThreadController controller = SexLab.HookController(argString)
	int index = 0
	While index < participants.Length
		Actor currentParticipant = participants[index]
		AfterOrgasmSpell.Cast(currentParticipant, None)	
		If !controller.IsVictim(currentParticipant) && currentParticipant == PlayerRef ;for this there is onRape event
			int purity = dattUtility.LimitValueInt(SexLab.GetPlayerPurityLevel(),-6,6)
			AttributesAPI.ModAttribute(PlayerRef,Config.WillpowerAttributeId, (-1 * Config.WillpowerChangePerOrgasm) - purity)
			Log("OnOrgasmEnd, Adjusting willpower value for " + currentParticipant.GetBaseObject().GetName() + ",purity = " +purity + " , adjusted by " + ((-1 * Config.WillpowerChangePerOrgasm) - purity))
		ElseIf currentParticipant != PlayerRef && !controller.IsAggressor(currentParticipant)
			int direction = -1
			If controller.IsAggressor(currentParticipant)
				direction = 1
			Endif
			Log("OnOrgasmEnd, Adjusting willpower value for " + currentParticipant.GetBaseObject().GetName()  + " , adjusted by " + (direction * Config.WillpowerChangePerOrgasm))
			AttributesAPI.ModAttribute(currentParticipant,Config.WillpowerAttributeId, direction * Config.WillpowerChangePerOrgasm)						
		EndIf		
		index += 1
	EndWhile
EndEvent

Float Property LastSelfEsteemForKillUpdateTime Hidden
	Float Function Get()
		return StorageUtil.GetFloatValue(None, "_datt_LastSelfEsteemForKillUpdateTime")
	EndFunction
	Function Set(float value)
		StorageUtil.SetFloatValue(None, "_datt_LastSelfEsteemForKillUpdateTime", value)
	EndFunction
EndProperty

Float Property LastSpellCastTime Hidden
	Float Function Get()
		float lastCastTime = StorageUtil.GetFloatValue(None, "_datt_last_cast_time")
		If lastCastTime == 0.0
			float currentTime = Utility.GetCurrentGameTime()
			StorageUtil.SetFloatValue(None, "_datt_last_cast_time", currentTime)
			return currentTime
		EndIf
		return lastCastTime
	EndFunction
	Function Set(float value)
		StorageUtil.SetFloatValue(None, "_datt_last_cast_time", value)
	EndFunction
EndProperty
