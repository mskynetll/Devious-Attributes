Scriptname DattAttributesTracker extends Quest

Event OnInit()
	Maintenance()
EndEvent

float Property GameTickUpdateInHours = 1.0 AutoReadonly ;TODO: make configurable

Function Maintenance()
	Debug.Notification("Devious Attributes running...")

	RegisterForSingleUpdateGameTime(GameTickUpdateInHours)
EndFunction

Event OnUpdateGameTime()
	float currentTime = Utility.GetCurrentGameTime()
	float hoursPassed = 0

	if LastTimePassTick > 0 ;skip the calculation in the first time
		hoursPassed = Math.abs(LastTimePassTick - currentTime) * 24.0
	endif

	dattEventsDispatcher.OnGameTimePassed(currentTime, hoursPassed)
	LastTimePassTick = Utility.GetCurrentGameTime()

	RegisterForSingleUpdateGameTime(GameTickUpdateInHours)
EndEvent

float Property LastTimePassTick
	float Function Get()
		return StorageUtil.GetFloatValue(None, "_datt_LastTimePassTick", 0.0)
	EndFunction
    Function Set(float val)
    	StorageUtil.SetFloatValue(None, "_datt_LastTimePassTick", val)
    EndFunction
EndProperty

float Property LastSleepTime
	float Function Get()
		return StorageUtil.GetFloatValue(None, "_datt_LastSleepTime", 0.0)
	EndFunction
    Function Set(float val)
    	StorageUtil.SetFloatValue(None, "_datt_LastSleepTime", val)
    EndFunction
EndProperty