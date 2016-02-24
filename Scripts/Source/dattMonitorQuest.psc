Scriptname dattMonitorQuest Extends dattQuestBase

dattAttributeTrackerQuest Property AttributeTracker Auto
dattPeriodicEventsQuest Property PeriodicEvents Auto 
dattNPCScannerQuest Property NPCScanner Auto
SexLabFramework Property SexLab Auto
dattAttributesAPIQuest Property AttributesAPI Auto
slaFrameworkScr Property SexLabAroused Auto

Faction Property dattRapeTraumaFaction Auto

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

	; 
	RegisterForModEvent("AnimationStart", "OnSexAnimationStart") 
	RegisterForModEvent("AnimationEnd", "OnSexAnimationEnd") 
	RegisterForModEvent("OrgasmEnd", "OnOrgasmEnd")
	RegisterForModEvent("Datt_Simulate_Rape", "OnSimulateRapeSex")
	Debug.Notification("Devious Attributes is loaded and tracking stuff...")	
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
		Config.FrequentEventUpdateLatencySec = 30
		Config.PeriodicEventUpdateLatencyHours = 12
		ModVersion = "0.7.1"	
	EndIf
	If ModVersion == "0.7.1"
		ModVersion = "0.7.2"
		Config.IsLogging = true
	EndIf

	Debug.Notification("Devious Attributes is running version " + ModVersion)
EndFunction

Function ForceNPCScan()
	dattUtility.SendParameterlessEvent("Datt_ForceNPCScan")
EndFunction

Function OnPlayerKill(Actor victimActor,int aiRelationshipRank)
	Log("OnPlayerKill, victim : " + victimActor.GetBaseObject().GetName())
	dattUtility.SendEventWithFormParam("Datt_PlayerKill", victimActor as Form)
EndFunction

Function OnPlayerStealOrPickpocket(int goldAmount)
	Log("OnPlayerStealOrPickpocket, gold amount : " + goldAmount)
	dattUtility.SendEventWithIntParam("Datt_PlayerSteal",goldAmount)
EndFunction

Function OnPlayerCastMagic(Form castSpell)
	Log("OnPlayerCastMagic, spell that was cast : " + castSpell.GetName())
	dattUtility.SendEventWithFormParam("Datt_PlayerCastSpell",castSpell)
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

   	AttributesAPI.ModAttribute(victim,Config.WillpowerAttributeId, (-1 * Config.WillpowerChangePerRape) - (10 * (agressorCount)) + nymphoBonus)
	AttributesAPI.ModAttribute(victim,Config.PrideAttributeId, (-1 * Config.PrideChangePerRape) - (5 * (agressorCount)) + (nymphoBonus / 2))
	AttributesAPI.ModAttribute(victim,Config.SelfEsteemAttributeId, (-1 * Config.SelfEsteemChangePerRape) - (2 * (agressorCount)))
EndEvent

Event OnConsensualSex(Actor[] participants,sslBaseAnimation animationUsed)
	int index = 0
	Log("OnConsensualSex, participant count =" + participants.Length)
	While index < participants.Length
		Actor currentParticipant = participants[index]
	   	float lastTimeHadSex = StorageUtil.GetFloatValue(currentParticipant, "_datt_last_time_had_sex", 0.0)
	   	StorageUtil.SetFloatValue(currentParticipant, "_datt_last_time_had_sex", Utility.GetCurrentGameTime())
	   	If(lastTimeHadSex > 0.0)	   		
	   		int arousal = StorageUtil.GetIntValue(currentParticipant, "_datt_last_arousal")
	   		If arousal >= 75 && Math.abs(Utility.GetCurrentGameTime() - lastTimeHadSex) * 24.0 >= Config.IntervalBetweenSexToIncreaseNymphoHours
	   			Log("Adjusting nympho value for " + currentParticipant.GetBaseObject().GetName() + ", adjusted by " + Config.NymphoIncreasePerConsensual)
	   			AttributesAPI.ModAttribute(currentParticipant,Config.NymphomaniacAttributeId, Config.NymphoIncreasePerConsensual)
	   		EndIf
	   	EndIf		
		int nymphoBonus = Math.floor(AttributesAPI.GetAttribute(currentParticipant, Config.NymphomaniacAttributeId) / 10)

		AttributesAPI.ModAttribute(currentParticipant,Config.SelfEsteemAttributeId, 25 + nymphoBonus)
		Log("Adjusting self-esteem value for " + currentParticipant.GetBaseObject().GetName() + ", adjusted by " + (25 + nymphoBonus))
		If currentParticipant == PlayerRef
			ApplyChangesToPlayer(animationUsed)
		EndIf
		index += 1
	EndWhile	
EndEvent

Function ApplyChangesToPlayer(sslBaseAnimation animationUsed)
	If animationUsed.HasTag("Oral")
		int oralLevel = dattUtility.LimitValueInt(SexLab.GetPlayerStatLevel("Oral"),0,6)

		If oralLevel > 0
			AttributesAPI.ModAttribute(PlayerRef,Config.SelfEsteemAttributeId, oralLevel * 10)
		EndIf
	ElseIf animationUsed.HasTag("Vaginal")
		int vaginalLevel = dattUtility.LimitValueInt(SexLab.GetPlayerStatLevel("Vaginal"),0,6)

		If vaginalLevel > 0
			AttributesAPI.ModAttribute(PlayerRef,Config.SelfEsteemAttributeId, vaginalLevel * 10)
		EndIf
	ElseIf animationUsed.HasTag("Anal")
		int analLevel = dattUtility.LimitValueInt(SexLab.GetPlayerStatLevel("Anal"),0,6)

		If analLevel > 0
			AttributesAPI.ModAttribute(PlayerRef,Config.SelfEsteemAttributeId, analLevel * 10)
		EndIf
	EndIf	
EndFunction

Event OnOrgasmEnd(string eventName, string argString, float argNum, form sender)
	Actor[] participants = Sexlab.HookActors(argString)
	sslThreadController controller = SexLab.HookController(argString)
	int index = 0
	While index < participants.Length
		Actor currentParticipant = participants[index]
		If !controller.IsVictim(currentParticipant) ;for this there is onRape event
			If currentParticipant == PlayerRef			 
				int purity = dattUtility.LimitValueInt(SexLab.GetPlayerPurityLevel(),-6,6)
				AttributesAPI.ModAttribute(PlayerRef,Config.WillpowerAttributeId, (-1 * Config.WillpowerChangePerOrgasm) - (10 * purity))
				Log("OnOrgasmEnd, Adjusting willpower value for " + currentParticipant.GetBaseObject().GetName() + ",purity = " +purity + " , adjusted by " + ((-1 * Config.WillpowerChangePerOrgasm) - (10 * purity)))
			Else
				int direction = -1
				If controller.IsAggressor(currentParticipant)
					direction = 1
				Endif
				Log("OnOrgasmEnd, Adjusting willpower value for " + currentParticipant.GetBaseObject().GetName()  + " , adjusted by " + (direction * Config.WillpowerChangePerOrgasm))
				AttributesAPI.ModAttribute(currentParticipant,Config.WillpowerAttributeId, direction * Config.WillpowerChangePerOrgasm)			
			EndIf
		EndIf
		index += 1
	EndWhile
EndEvent