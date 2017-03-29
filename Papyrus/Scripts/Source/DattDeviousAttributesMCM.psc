scriptname DattDeviousAttributesMCM extends SKI_ConfigBase

Event OnConfigInit()
	Pages = new String[3]
	Pages[0] = "Event Settings"
	Pages[1] = "Consequence Settings"
	Pages[2] = "Debug"	
EndEvent

event OnPageReset(string page)
    {Called when a new page is selected, including the initial empty page}
    	SetCursorFillMode(TOP_TO_BOTTOM) 
	If (page == "Event Settings")
		SetCursorPosition(0)
	endif
	If (page == "Consequence Settings")
		SetCursorPosition(0)				
	endif
	
	If (page == "Debug")
		AddToggleOptionST("ResetAttributesToDefaults_ToggleId", "Reset attribute values to defaults.", false)

		SetCursorPosition(0)
		AddHeaderOption("Attribute Values")
		AddTextOption("Willpower", DeviousAttributes.GetAttributeValue("willpower"), 1)
		AddTextOption("SelfEsteem", DeviousAttributes.GetAttributeValue("selfesteem"), 1)
		AddTextOption("Obedience", DeviousAttributes.GetAttributeValue("obedience"), 1)
		AddTextOption("Pride", DeviousAttributes.GetAttributeValue("pride"), 1)		
	endif
endEvent

state ResetAttributesToDefaults_ToggleId
	event OnSelectST()
		DeviousAttributes.ResetAttributeValues()
		Debug.MessageBox("Attribute values to default.")
	endEvent

	event OnDefaultST()
		SetToggleOptionValueST(true)
	endEvent

	event OnHighlightST()
		SetInfoText("Reset attribute values to defaults.")
	endEvent	
endState