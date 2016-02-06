Scriptname dattAttributes extends Quest

dattConstants Property Constants Auto
dattConfigMenu Property Config Auto
dattLibraries Property Libs Auto

GlobalVariable Property dattWillpower Auto
GlobalVariable Property dattPride Auto
GlobalVariable Property dattSelfEsteem Auto
GlobalVariable Property dattObedience Auto

GlobalVariable Property dattNymphomaniac Auto
GlobalVariable Property dattHumiliationLover Auto
GlobalVariable Property dattExhibitionist Auto
GlobalVariable Property dattMasochist Auto

GlobalVariable Property dattSoulState Auto
Function Initialize()	
	If(Libs.PlayerRef == None)
		Debug.MessageBox("Player reference at dattAttributes equals to None. This is something that is not supposed to happen and needs to be reported.")
	EndIf
EndFunction

; 0 -> Free Spirit
; 1 -> Willing Slave
; 2 -> Forced Slave
Int Function GetSoulState(Actor akActor)
	int value = dattSoulState.GetValue() as int
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
	If(value >= 0 && value < 3) ;simple guard against invalid values
		dattSoulState.SetValueInt(value)
		StorageUtil.SetIntValue(akActor, Constants.SoulStateAttributeId, value)
		int soulStateChangedEventId = ModEvent.Create(Constants.SoulStateChangedEventName)
		If(soulStateChangedEventId)
			ModEvent.PushForm(soulStateChangedEventId, akActor as Form)
			ModEvent.PushInt(soulStateChangedEventId, value)
			ModEvent.Send(soulStateChangedEventId)
		EndIf
	Else
		Debug.MessageBox("received invalid value for SetSoulState() -> value ="+value)
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
	GlobalVariable variable = GetFetishVariableFor(fetishAttributeId)
	If(variable == None)
		return -1.0
	EndIf
	float value = variable.GetValue()
	If(value < 0 || value > 100.0)
		Debug.MessageBox("Out-of-range value for fetishAttributeId=" + fetishAttributeId + " -> value="+value+". The value should be 0 or more.")
		StorageUtil.SetFloatValue(akActor,fetishAttributeId, 0.0) ;in this case, set the default value
		variable.SetValue(0.0)
		return 0.0
	EndIf
	return value
EndFunction

Function SetFetish(Actor akActor, string fetishAttributeId, float value)
	If(Libs.Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> SetFetishValue(), fetishAttributeId=" + fetishAttributeId +", value=" + value)
	EndIf
	GlobalVariable variable = GetFetishVariableFor(fetishAttributeId)
	If(variable == None)
		return
	EndIf

	variable.SetValue(value)
	StorageUtil.SetFloatValue(akActor,fetishAttributeId, value)
	int fetishChangedEventId = ModEvent.Create(Constants.FetishChangedEventName)
	If (fetishChangedEventId)
	    ModEvent.PushForm(fetishChangedEventId, akActor as Form) 
        ModEvent.PushString(fetishChangedEventId, fetishAttributeId)
        ModEvent.PushFloat(fetishChangedEventId, value)
        ModEvent.Send(fetishChangedEventId)
    EndIf
EndFunction

Function IncrementPlayerFetish(string fetishAttributeId, float increment)
	If(Libs.PlayerRef == None)
		Debug.MessageBox("Libs.PlayerRef is none, the reference seems not to be filled. This is not something that is supposed to happen...")
	EndIf
	IncrementFetish(Libs.PlayerRef, fetishAttributeId, increment)
EndFunction

Function IncrementFetish(Actor akActor, string fetishAttributeId, float increment)
	If(Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> IncrementFetish(), fetishAttributeId=" + fetishAttributeId +", increment=" + increment)
	EndIf
	GlobalVariable variable = GetFetishVariableFor(fetishAttributeId)
	If(variable == None)
		return
	EndIf

	float value = variable.GetValue()
	value += increment
	If(value > 100.0 || value < 0)
		value = 100.0
	EndIf
	
	variable.SetValue(value)
	StorageUtil.SetFloatValue(akActor,fetishAttributeId, value)

	int fetishChangedEventId = ModEvent.Create(Constants.FetishChangedEventName)
	If (fetishChangedEventId)
	    ModEvent.PushForm(fetishChangedEventId, akActor as Form) 
        ModEvent.PushString(fetishChangedEventId, fetishAttributeId)
        ModEvent.PushFloat(fetishChangedEventId, value)
        ModEvent.Send(fetishChangedEventId)
    EndIf
EndFunction

float Function GetAttribute(Actor akActor, string attributeId)
	float value = StorageUtil.GetFloatValue(akActor,attributeId, -1.0)	
	GlobalVariable variable = GetAttributeVariableFor(attributeId)
	If(variable == None)
		return -1.0
	EndIf

	If(value == -1.0)
		value = GetDefaultValue(attributeId)
		StorageUtil.SetFloatValue(akActor,attributeId, value)		
		variable.SetValue(value)
	EndIf

	If (value < Constants.MinStatValue || value > Constants.MaxStatValue)
		;guard against other mods setting invalid values
		;this should never happen, but still - there are no fool-proof plans
		Debug.MessageBox("Out-of-range value for attributeId="+attributeId+" -> expected it to be between " + Constants.MinStatValue + " and " + Constants.MaxStatValue + ", but the value=" + value)
		StorageUtil.SetFloatValue(akActor,attributeId, Constants.MinStatValue)
		variable.SetValue(Constants.MinStatValue)
		return Constants.MinStatValue
	EndIf

	return variable.GetValue()
EndFunction

float Function GetPlayerAttribute(string attributeId)
	return GetAttribute(Libs.PlayerRef, attributeId)
EndFunction

Function SetPlayerAttribute(string attributeId, float value)
	SetAttribute(Libs.PlayerRef, attributeId, value)
EndFunction

Function SetAttribute(Actor akActor, string attributeId, float value)
	float valueToSet = Max(Constants.MinStatValue, Min(Constants.MaxStatValue, value))
	If(Config.ShowDebugMessages)
		Debug.Notification("Devious Attributes -> SetAttribute(), attributeId=" + attributeId +", value=" + value)
	EndIf
	
	GlobalVariable variable = GetAttributeVariableFor(attributeId)
	If(variable == None)
		return
	EndIf

	float oldValue = StorageUtil.GetFloatValue(akActor,attributeId)
	StorageUtil.SetFloatValue(akActor,attributeId, valueToSet)
	variable.SetValue(valueToSet)

	int attributeChangedEventId = ModEvent.Create(Constants.AttributeChangedEventName)
	If (attributeChangedEventId)		
        ModEvent.PushForm(attributeChangedEventId, akActor as Form) 
        ModEvent.PushString(attributeChangedEventId, attributeId)
        ModEvent.PushFloat(attributeChangedEventId, oldValue)
        ModEvent.PushFloat(attributeChangedEventId, valueToSet)
        ModEvent.Send(attributeChangedEventId)
    EndIf
EndFunction

Float Function GetPlayerSubmissiveness()
	return GetSubmissiveness(Libs.PlayerRef)
EndFunction

Float Function GetSubmissiveness(Actor akActor)
	int soulState = GetSoulState(akActor)
	If(soulState == 1) ;willing slave
		return 1.0
	EndIf
	
	float obedience = GetAttribute(akActor, Constants.ObedienceAttributeId)
	float willpower = GetAttribute(akActor, Constants.WillpowerAttributeId)	
	float selfEsteem = GetAttribute(akActor, Constants.SelfEsteemAttributeId)
	float pride = GetAttribute(akActor, Constants.PrideAttributeId)	

	Return Max(obedience / Constants.MaxStatValue, 1 - (((0.5 * Max(0.1,selfEsteem)) + (0.5 * Max(pride,willpower))) / Constants.MaxStatValue))
EndFunction

Function SendPlayerSubmissivenessChanged()
	SendSubmissivenessChanged(Libs.PlayerRef)
EndFunction

Function SendSubmissivenessChanged(Actor akActor)
	float submissiveness = GetSubmissiveness(akActor)
	StorageUtil.SetFloatValue(akActor, Constants.SubmissivenessAttributeId, submissiveness)
	int attributeChangedEventId = ModEvent.Create(Constants.AttributeChangedEventName)
	If (attributeChangedEventId)
        ModEvent.PushForm(attributeChangedEventId, akActor as Form) 
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

GlobalVariable Function GetAttributeVariableFor(string attributeId)
	If(attributeId == Constants.PrideAttributeId)
		return dattPride
	ElseIf(attributeId == Constants.SelfEsteemAttributeId)
		return dattSelfEsteem
	ElseIf(attributeId == Constants.WillpowerAttributeId)
		return dattWillpower
	ElseIf(attributeId == Constants.ObedienceAttributeId)
		return dattObedience
	Else
		return None
	EndIf
EndFunction

GlobalVariable Function GetFetishVariableFor(string attributeId)
	If(attributeId == Constants.HumiliationLoverAttributeId)
		return dattHumiliationLover
	ElseIf(attributeId == Constants.ExhibitionistAttributeId)
		return dattExhibitionist
	ElseIf(attributeId == Constants.MasochistAttributeId)
		return dattMasochist
	ElseIf(attributeId == Constants.NymphomaniacAttributeId)
		return dattNymphomaniac
	Else
		return None
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