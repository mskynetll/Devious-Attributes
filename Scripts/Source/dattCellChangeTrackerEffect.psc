Scriptname dattCellChangeTrackerEffect extends ActiveMagicEffect
{Taken from here http://www.creationkit.com/Detect_Player_Cell_Change_%28Without_Polling%29}

dattMonitorQuest Property MonitorQuest Auto
Actor Property PlayerRef Auto
ObjectReference Property InvisibleObject Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)
    InvisibleObject.MoveTo(PlayerRef)

    int retries = 3
    bool hasSent = false
    While retries > 0
    	If TrySendCellChangeNotification() == true
    		retries = 0
    		hasSent = true
    	Else
    		retries -= 1
    		Utility.Wait(0.5)
    	EndIf
    EndWhile

    If hasSent == false
    	Debug.Trace("[Datt] Was unable to send Datt_PlayerCellChange, even after 3 retries. This is something that is definitely not supposed to happen.",1)
        Debug.Notification("[Datt] Was unable to send Datt_PlayerCellChange, even after 3 retries. This is something that is definitely not supposed to happen.")
    EndIf
EndEvent

bool Function TrySendCellChangeNotification()
    int eventId = ModEvent.Create("Datt_PlayerCellChange")
    If eventId
    	ModEvent.PushForm(eventId,PlayerRef.GetParentCell() as Form)
    	return ModEvent.Send(eventId)
    Else
        Debug.Notification("CellChangeTrackerEffect -> failed to send Datt_PlayerCellChange")
    	return false
    EndIf
EndFunction