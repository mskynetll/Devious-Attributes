Scriptname dattMonitorQuest Extends dattQuestBase

dattAttributeTrackerQuest Property AttributeTracker Auto
dattPeriodicEventsQuest Property PeriodicEvents Auto 
dattNPCScannerQuest Property NPCScanner Auto
SexLabFramework Property SexLab Auto
dattAttributesAPIQuest Property AttributesAPI Auto
slaFrameworkScr Property SexLabAroused Auto
dattChoiceTrackerQuest Property ChoiceTracker Auto

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
	ChoiceTracker.Maintenance()
	 
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
			Debug.Notification("Devious Attributes initializes stuff... this should happen only once.")
			dattUtility.SendEventWithFormParam("Datt_SetDefaults",PlayerRef as Form)			
		    OneTimeInitialize = true
		EndIf
		ModVersion = "0.7.0"	
	EndIf
	If ModVersion == "0.7.0"
		dattUtility.SendEventWithFormParam("Datt_SetDefaults",PlayerRef as Form)
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
		dattUtility.SendEventWithFormParam("Datt_SetDefaults",PlayerRef as Form)   
        ModVersion = "0.7.3"        
	EndIf
	If ModVersion == "0.7.3"
		Config.WillpowerBaseChange = 10
		Config.FrequentEventUpdateLatency = 1;hours
		Config.WillpowerChangePerOrgasm = 5
		Config.WillpowerChangePerRape = 20
		StorageUtil.SetFloatValue(None, "_datt_periodic_event_last_frequent_update", Utility.GetCurrentGameTime())
		StorageUtil.SetFloatValue(None, "_datt_periodic_event_last_periodic_update", Utility.GetCurrentGameTime())
		ModVersion = "0.7.4"        
	EndIf
	If ModVersion == "0.7.4"
		;some more tweaks to defaults
		Config.WillpowerBaseChange = 10
		Config.WillpowerChangePerOrgasm = 8
		Config.WillpowerChangePerRape = 25
		Config.SelfEsteemChangePerRape = 2
		Config.PrideChangePerRape = 5
		StorageUtil.SetFloatValue(None, "_datt_periodic_event_last_frequent_update", Utility.GetCurrentGameTime())
		StorageUtil.SetFloatValue(None, "_datt_periodic_event_last_periodic_update", Utility.GetCurrentGameTime())
		ModVersion = "0.7.5"        
	EndIf	

	If ModVersion == "0.7.5"
		dattUtility.SendEventWithFormParam("Datt_SetDefaults",PlayerRef as Form)
		ModVersion = "0.7.51"
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
		OnRapeSex(victim,participants.Length - 1, argString)		
		UpdateNymphoValue(victim)
		int index = 0
		While index < participants.Length
			If participants[index] != victim
				int arousal = StorageUtil.GetIntValue(participants[index], "_datt_last_arousal")

				If arousal > 25 && arousal <= 50
					AttributesAPI.ModAttribute(participants[index],Config.SadistAttributeId,1)
				ElseIf arousal > 50 && arousal <= 75
					AttributesAPI.ModAttribute(participants[index],Config.SadistAttributeId,2)
				ElseIf arousal > 75
					AttributesAPI.ModAttribute(participants[index],Config.SadistAttributeId,4)
				EndIf
				UpdateNymphoValue(participants[index])
			EndIf
			index += 1
		EndWhile
	Else
		sslBaseAnimation animationUsed = SexLab.HookAnimation(argString)
		OnConsensualSex(participants, animationUsed)
	EndIf 
EndEvent

Function SetLastTimeHadSex(Actor[] participants)
		int index = 0
		float now = Utility.GetCurrentGameTime()
		While index < participants.Length
			PeriodicEvents.SetLastTimeHadSex(participants[index],now)
			index += 1
		EndWhile	
EndFunction

Event OnSimulateRapeSex(Form victim, int agressorCount)
	OnRapeSex(victim as Actor, agressorCount, "")
EndEvent

Event OnRapeSex(Actor victim, int agressorCount, string argString)
	Log("OnRapeSex, victim is " + victim.GetBaseObject().GetName() + ", agressors count = " + agressorCount)
	dattPeriodicEventsHelper.ModTrauma("Rape",victim,dattRapeTraumaFaction, agressorCount * 10)
   	int wornDeviceCount = dattUtility.MaxInt(0,StorageUtil.GetIntValue(victim, "_datt_worn_device_count"))
	int nymphoBonus = AttributesAPI.GetAttribute(victim, Config.NymphomaniacAttributeId) / (wornDeviceCount * 10)

   	AttributesAPI.ModAttribute(victim,Config.WillpowerAttributeId, (-1 * Config.WillpowerChangePerRape) - (2*agressorCount) + nymphoBonus)
	AttributesAPI.ModAttribute(victim,Config.PrideAttributeId, (-1 * Config.PrideChangePerRape) - agressorCount + (nymphoBonus / 2))
	AttributesAPI.ModAttribute(victim,Config.SelfEsteemAttributeId, (-1 * Config.SelfEsteemChangePerRape) - agressorCount)
		
	
	int arousal = StorageUtil.GetIntValue(victim, "_datt_last_arousal")
	sslBaseAnimation animationUsed = None
	If argString != ""
		animationUsed = SexLab.HookAnimation(argString)
		DecreasePrideByAnalSkillsIfRelevant(animationUsed)
	EndIf	

	If arousal > 25 && arousal <= 50
		AttributesAPI.ModAttribute(victim,Config.MasochistAttributeId,1)
	ElseIf arousal > 50 && arousal <= 75
		AttributesAPI.ModAttribute(victim,Config.MasochistAttributeId,2)
		If animationUsed != None && (animationUsed.HasTag("Dirty") || animationUsed.HasTag("Rough"))
			AttributesAPI.ModAttribute(victim,Config.HumiliationLoverAttributeId,1)
		EndIf		
	ElseIf arousal > 75
		AttributesAPI.ModAttribute(victim,Config.MasochistAttributeId,4)
		If animationUsed != None && (animationUsed.HasTag("Dirty") || animationUsed.HasTag("Rough"))
			AttributesAPI.ModAttribute(victim,Config.HumiliationLoverAttributeId,2)
		EndIf			
	EndIf
EndEvent

Event OnConsensualSex(Actor[] participants,sslBaseAnimation animationUsed)
	int index = 0
	Log("OnConsensualSex, participant count =" + participants.Length)
	While index < participants.Length
		Actor currentParticipant = participants[index]
				
		float hoursPassedSinceHadSex = UpdateNymphoValue(currentParticipant)		

		int nymphoBonus = Math.floor(AttributesAPI.GetAttribute(currentParticipant, Config.NymphomaniacAttributeId) / 10)
		If currentParticipant == PlayerRef
			DecreasePrideByAnalSkillsIfRelevant(animationUsed)

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

Function DecreasePrideByAnalSkillsIfRelevant(sslBaseAnimation animationUsed)
	;applicable only to player since Sexlab stores proficiency only for PC
	;the idea here is that the less anal experince of PC, the more pride hit it will take
	; --> more anal sex, less hurtful 
	int analLevel = dattUtility.LimitValueInt(SexLab.GetPlayerStatLevel("Anal"),0,6)
	If animationUsed.HasTag("Anal") && analLevel < 6
		AttributesAPI.ModAttribute(PlayerRef,Config.PrideAttributeId, -1 * (6 - analLevel))
	EndIf
EndFunction

float Function UpdateNymphoValue(Actor akActor)
	float lastTimeHadSex = StorageUtil.GetFloatValue(akActor, "_datt_last_time_had_sex", 0.0)
	StorageUtil.SetFloatValue(akActor, "_datt_last_time_had_sex", Utility.GetCurrentGameTime())
	float hoursPassedSinceHadSex

	If lastTimeHadSex == 0.0
		hoursPassedSinceHadSex = 6.0
	Else
		hoursPassedSinceHadSex = Math.abs(Utility.GetCurrentGameTime() - lastTimeHadSex) * 24.0
	EndIf

	If lastTimeHadSex > 0.0
		int arousal = StorageUtil.GetIntValue(akActor, "_datt_last_arousal")
		If arousal >= 75 && hoursPassedSinceHadSex >= Config.IntervalBetweenSexToIncreaseNymphoHours
			Log("Adjusting nympho value for " + akActor.GetBaseObject().GetName() + ", adjusted by " + Config.NymphoIncreasePerConsensual)
			AttributesAPI.ModAttribute(akActor,Config.NymphomaniacAttributeId, Config.NymphoIncreasePerConsensual)
		EndIf
	EndIf	

	return hoursPassedSinceHadSex
EndFunction

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
