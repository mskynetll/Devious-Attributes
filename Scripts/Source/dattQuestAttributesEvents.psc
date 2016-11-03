Scriptname dattQuestAttributesEvents Extends dattQuestAttributesAPI

Function Maintenance()
	RegisterForModEvent("Datt_SetAttribute", "OnSetAttribute")
	RegisterForModEvent("Datt_ModAttribute", "OnModAttribute")
	RegisterForModEvent("Datt_SetDefaults", "OnSetDefaults")
	RegisterForModEvent("Datt_SetSoulState", "OnSetSoulState")
	RegisterForModEvent("Datt_ClearChangeQueue", "OnClearChangeQueue")
EndFunction

; Event to set an attribute to a specific value.
Event OnSetAttribute(Form target_actor_form, String target_attribute_name, Int attribute_value)
	SetAttributeByName(target_actor_form as Actor, target_attribute_name, attribute_value)
EndEvent

; Event to modify an attribute.
; It uses the same function as OnSetAttribute event as it will deliver the same result
Event OnModAttribute(Form target_actor_form, String target_attribute_name, Int attribute_value)
	ModAttributeByName(target_actor_form as Actor, target_attribute_name, attribute_value)
EndEvent

; Event to reset all attributes to default.
Event OnSetDefaults(Form target_actor_form)
	SetDefaults(target_actor_form as Actor)
EndEvent
