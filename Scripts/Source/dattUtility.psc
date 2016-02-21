Scriptname dattUtility Extends Form Hidden

Float Function Max(Float A, Float B) global
	If (A > B)
		Return A
	Else
		Return B
	EndIf
EndFunction

Float Function Min(Float A, Float B) global
	If (A < B)
		Return A
	Else
		Return B
	EndIf
EndFunction

int Function MaxInt(int A, int B) global
	If (A > B)
		Return A
	Else
		Return B
	EndIf
EndFunction

int Function MinInt(int A, int B) global
	If (A < B)
		Return A
	Else
		Return B
	EndIf
EndFunction