Scriptname dattAttributes extends Quest

dattConstants Property Constants Auto
dattConfigMenu Property Config Auto
dattLibraries Property Libs Auto

int attributeChangedEventId
int fetishChangedEventId

Function Initialize()
	attributeChangedEventId = ModEvent.Create(Constants.AttributeChangedEventName)
	fetishChangedEventId = ModEvent.Create(Constants.FetishChangedEventName)
EndFunction

; 0 -> Free Spirit
; 1 -> Willing Slave
; 2 -> Forced Slave
Int Function GetSoulState(Actor akActor)
	int value = StorageUtil.GetIntValue(akActor,Constants.SoulStateAttributeId)
	If(value < 0 || value > 3) 
		;simple guard against invalid values
		;since this is stored in storageUtil and other mods can access it, 
		;this will prevent invalid values to be used
		Debug.MessageBox("Invalid soul state detected, expected it to be between 0 and 3, but it's value is " + value)
		return 0
	EndIf

	return value
EndFunction

Int Function GetPlayerSoulState()
	return GetSoulState(Libs.PlayerRef)
EndFunction

Function SetSoulState(Actor akActor, int value)
	If(value > 0 && value <= 3) ;simple guard against invalid values
		StorageUtil.SetIntValue(akActor, Constants.SoulStateAttributeId, value)
	EndIf
EndFunction

Function SetPlayerSoulState(int value)
	SetSoulState(Libs.PlayerRef,value)
EndFunction

Function SetPlayerFetish(string fetishAttributeId, float value)
	SetFetish(Libs.PlayerRef, fetishAttributeId, value)
EndFunction

float Function GetPlayerFetish(string fetishAttributeId)
	return GetFetish(Libs.PlayerRef, fetishAttributeId)
EndFunction

float Function GetFetish(Actor akActor, string fetishAttributeId)
	float value = StorageUtil.GetFloatValue(akActor,fetishAttributeId)
	If(value < 0)
		Debug.MessageBox("Out-of-range value for fetishAttributeId=" + fetishAttributeId + " -> value="+value+". The value should be 0 or more.")
		StorageUtil.SetFloatValue(akActor,fetishAttributeId, 0.0) ;in this case, set the default value
	EndIf
EndFunction

Function SetFetish(Actor akActor, string fetishAttributeId, float value)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> SetFetishValue(), fetishAttributeId=" + fetishAttributeId +", value=" + value)
	EndIf

	StorageUtil.SetFloatValue(akActor,fetishAttributeId, value)
	If (fetishChangedEventId)
	    ModEvent.PushForm(fetishChangedEventId, Self) 
        ModEvent.PushString(fetishChangedEventId, fetishAttributeId)
        ModEvent.PushFloat(fetishChangedEventId, value)
        ModEvent.Send(fetishChangedEventId)
    EndIf
EndFunction

Function IncrementPlayerFetish(string fetishAttributeId, float increment)
	IncrementFetish(Libs.PlayerRef, fetishAttributeId, increment)
EndFunction

Function IncrementFetish(Actor akActor, string fetishAttributeId, float increment)
	If(Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> IncrementFetish(), fetishAttributeId=" + fetishAttributeId +", increment=" + increment)
	EndIf

	float value = StorageUtil.GetFloatValue(akActor, fetishAttributeId, 0)
	value += increment
	StorageUtil.SetFloatValue(akActor,fetishAttributeId, value)

	If (fetishChangedEventId)
	    ModEvent.PushForm(fetishChangedEventId, Self) 
        ModEvent.PushString(fetishChangedEventId, fetishAttributeId)
        ModEvent.PushFloat(fetishChangedEventId, value)
        ModEvent.Send(fetishChangedEventId)
    EndIf
EndFunction

float Function GetAttribute(Actor akActor, string attributeId)
	float value = StorageUtil.GetFloatValue(akActor,attributeId, -1.0)	
	If(value == -1.0)
		value = GetDefaultValue(attributeId)
		StorageUtil.SetFloatValue(akActor,attributeId, value)
	EndIf

	If (value < Constants.MinStatValue || value > Constants.MaxStatValue)
		;guard against other mods setting invalid values
		;this should never happen, but still - there are no fool-proof plans
		Debug.MessageBox("Out-of-range value for attributeId="+attributeId+" -> expected it to be between " + Constants.MinStatValue + " and " + Constants.MaxStatValue + ", but the value=" + value)
		StorageUtil.SetFloatValue(akActor,attributeId, Constants.MinStatValue)
		return Constants.MinStatValue
	EndIf
	return value
EndFunction

float Function GetPlayerAttribute(string attributeId)
	return GetAttribute(Libs.PlayerRef, attributeId)
EndFunction

Function SetPlayerAttribute(string attributeId, float value)
	SetAttribute(Libs.PlayerRef, attributeId, value)
EndFunction

Function SetAttribute(Actor akActor, string attributeId, float value)
	If(Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> SetAttribute(), attributeId=" + attributeId +", value=" + value)
	EndIf

	float valueToSet = Max(Constants.MinStatValue, Min(Constants.MaxStatValue, value))
	StorageUtil.SetFloatValue(akActor,attributeId, valueToSet)

	If (attributeChangedEventId)
        ModEvent.PushForm(attributeChangedEventId, Self) 
        ModEvent.PushString(attributeChangedEventId, attributeId)
        ModEvent.PushFloat(attributeChangedEventId, valueToSet)
        ModEvent.Send(attributeChangedEventId)
    EndIf
EndFunction

Float Function GetPlayerSubmissiveness()
	return GetSubmissiveness(Libs.PlayerRef)
EndFunction

Float Function GetSubmissiveness(Actor akActor)
	float selfEsteem = GetAttribute(akActor, Constants.SelfEsteemAttributeId)
	float pride = GetAttribute(akActor, Constants.PrideAttributeId)
	float willpower = GetAttribute(akActor, Constants.WillpowerAttributeId)
	Return 1 - (((0.5 * Max(0.1,selfEsteem)) + (0.5 * Max(pride,willpower))) / Constants.MaxStatValue)
EndFunction

Function SendPlayerSubmissivenessChanged()
	SendSubmissivenessChanged(Libs.PlayerRef)
EndFunction

Function SendSubmissivenessChanged(Actor akActor)
	float submissiveness = GetSubmissiveness(akActor)
	StorageUtil.SetFloatValue(akActor, Constants.SubmissivenessAttributeId, submissiveness)
	If (attributeChangedEventId)
        ModEvent.PushForm(attributeChangedEventId, Self) 
       	ModEvent.PushString(attributeChangedEventId, Constants.SubmissivenessAttributeId)
       	ModEvent.PushFloat(attributeChangedEventId, submissiveness)
       	ModEvent.Send(attributeChangedEventId)
   	EndIf
EndFunction

float Function GetDefaultValue(string attributeId)
	If(attributeId == Constants.PrideAttributeId)
		return Constants.DefaultPride
	ElseIf(attributeId == Constants.SelfEsteemAttributeId)
		return Constants.DefaultSelfEsteem
	ElseIf(attributeId == Constants.WillpowerAttributeId)
		return Constants.DefaultWillpower
	ElseIf(attributeId == Constants.ObedienceAttributeId)
		return Constants.DefaultObedience
	EndIf
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