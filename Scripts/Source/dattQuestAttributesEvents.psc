Scriptname dattQuestAttributesEvents Extends dattQuestAttributesAPI

Function Maintenance()
	;RegisterForModEvent("Datt_SetAttribute", "OnSetAttribute")
	;RegisterForModEvent("Datt_ModAttribute", "OnModAttribute")
	;RegisterForModEvent("Datt_SetDefaults", "OnSetDefaults")
	;RegisterForModEvent("Datt_ClearChangeQueue", "OnClearChangeQueue")
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

Event OnActorDecision(Form victim_actor_form, String[] decision_tags, Int[] decision_tags_magnitudes, Int decision, Form[] master_actor_form)
	Actor victim_actor = victim_actor_form as Actor
	;Actor[] master_actor = master_actor_form as Actor[]
	If victim_actor == None
		Warning("OnActorDecision() victim_actor_form is invalid or not an actor. aborting...")
		Return
	EndIf
	; TODO
EndEvent

Event OnActorVictim(Form[] victim_actor_form, String[] victim_tags, Int[] victim_magnitudes, Int victim_magnitude, Form[] master_actor_form, String[] master_tags, Int[] master_magnitudes, Int master_magnitude)
	ActorVictim(victim_actor_form, victim_tags, victim_magnitudes, victim_magnitude, master_actor_form, master_tags, master_magnitudes, master_magnitude)
EndEvent
