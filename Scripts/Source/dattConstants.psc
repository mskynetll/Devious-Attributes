Scriptname dattConstants extends Quest

Float Property MaxStatValue = 100.0 AutoReadonly Hidden
Float Property MinStatValue = 0.0 AutoReadonly Hidden


String Property SoulStateAttributeId = "_Datt_Soul_State" AutoReadonly Hidden

;misc value keys for StorageUtil
String Property RapeTraumaLevelId = "_Datt_RapeTraumaLevel" AutoReadonly Hidden

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
String Property NymphomaniacAttributeId = "_Datt_Nymphomaniac" AutoReadonly Hidden

;event names -> out
String Property AttributeChangedEventName = "Datt_AttributeChanged" AutoReadonly Hidden
String Property FetishChangedEventName = "Datt_FetishChanged" AutoReadonly Hidden
String Property SoulStateChangedEventName = "Datt_SoulStateChanged" AutoReadonly Hidden

;event names -> in
String Property PlayerDecisionEventName1 = "Datt_PlayerDecision1" AutoReadonly Hidden
String Property PlayerDecisionEventName2 = "Datt_PlayerDecision2" AutoReadonly Hidden
String Property PlayerDecisionEventName3 = "Datt_PlayerDecision3" AutoReadonly Hidden
String Property PlayerDecisionEventName4 = "Datt_PlayerDecision4" AutoReadonly Hidden

String Property PlayerDecisionWithExtraEventName1 = "Datt_PlayerDecision1WithExtra" AutoReadonly Hidden
String Property PlayerDecisionWithExtraEventName2 = "Datt_PlayerDecision2WithExtra" AutoReadonly Hidden
String Property PlayerDecisionWithExtraEventName3 = "Datt_PlayerDecision3WithExtra" AutoReadonly Hidden
String Property PlayerDecisionWithExtraEventName4 = "Datt_PlayerDecision4WithExtra" AutoReadonly Hidden

String Property PlayerSoulStateChangeEventName = "Datt_PlayerSoulStateChange" AutoReadonly Hidden

String Property WillpowerEffectEndEventName = "Datt_WillpowerEffectEnd" AutoReadonly Hidden
String Property SelfEsteemEffectEndEventName = "Datt_SelfEsteemEffectEnd" AutoReadonly Hidden
String Property PrideEffectEndEventName = "Datt_PrideEffectEnd" AutoReadonly Hidden
String Property RapeTraumaEffectEndEventName = "Datt_RapeTraumaEffectEnd" AutoReadonly Hidden

String Property EnableAllBuffsEventName = "Datt_EnableAllBuffsEventName" AutoReadonly Hidden
String Property DisableAllBuffsEventName = "Datt_DisableAllBuffsEventName" AutoReadonly Hidden

String Property MaintenanceEventName = "Datt_MaintenanceEventName" AutoReadonly Hidden
String Property SetAttributeEventName = "Datt_SetAttribute" AutoReadonly Hidden
String Property ModAttributeEventName = "Datt_ModAttribute" AutoReadonly Hidden
String Property OnPeriodicUpdateEventName = "Datt_OnPeriodicUpdateEventName" AutoReadonly Hidden
String Property OnPeriodicRefreshStartedEventName = "Datt_PeriodicRefreshStarted" AutoReadonly Hidden
String Property RemoveArmbinderRemovedDebuffEventName = "Datt_RemoveArmbinderRemovedDebuffEventName" AutoReadonly Hidden

;TODO : make defaults configurable
;also, consider making those configurable by profiles to allow roleplaying
; i.e. soldier has more pride (at least initially) than a beggar
; prehaps do it as pre-defined profiles?
Float Property DefaultWillpower = 100.0 AutoReadonly Hidden
Float Property DefaultSelfEsteem = 100.0 AutoReadonly Hidden
Float Property DefaultPride = 50.0 AutoReadonly Hidden
Float Property DefaultObedience = 0.0 AutoReadonly Hidden

Int Property State_FreeSpirit = 0 AutoReadonly Hidden
Int Property State_WillingSlave = 1 AutoReadonly Hidden
Int Property State_ForcedSlave = 2 AutoReadonly Hidden

String Property RapeTraumaDurationId = "Datt_RapeTraumaDurationId" AutoReadonly Hidden

;keys for external access
String Property GagPrideReduceTickId = "Datt_GagPrideReduceTick" AutoReadonly Hidden
String Property BaseDDTickId = "Datt_BaseDDTick" AutoReadonly Hidden
String Property IsRunningRefreshId = "Datt_IsRunningRefresh" AutoReadonly Hidden
