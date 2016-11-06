Scriptname dattConfigQuest Extends Quest ;SKI_ConfigBase

Actor Property PlayerRef Auto
Int Property LogLevel Auto Hidden



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
String Property NymphomaniaAttributeName = "Datt_Nymphomania" AutoReadonly Hidden
; Fetish Attributes States
String Property NymphomaniaAttributeStateName = "Datt_Nymphomaniac_State" AutoReadonly Hidden

; Calculated Attributes
String Property SubmissivenessAttributeName = "Datt_Submissiveness" AutoReadonly Hidden
; Calculated Attributes States
String Property SubmissivenessAttributeStateName = "Datt_Submissiveness_State" AutoReadonly Hidden

; Misc Attributes
String Property SlaveAbusivenessStateAttributeName = "Datt_Soul_State" AutoReadonly Hidden



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