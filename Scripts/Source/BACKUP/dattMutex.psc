Scriptname dattMutex extends dattQuestBase

Bool Function TryLock(int timeoutCycles = 1500)
    GotoState("Locked")
    Return true
EndFunction

Function Unlock()
EndFunction

State Locked	
    Bool Function TryLock(int timeoutCycles = 1500) ;1500 cycles -> 15 sec - should be more than enough
    	int cycles = 0
        While GetState() != "" && cycles < timeoutCycles
            Utility.WaitMenuMode(0.01)
            cycles += 1
        EndWhile

        If(cycles >= timeoutCycles)
        	GotoState("") ;mutext timed-out, so unlock for the next time
        	Return false
        Else
        	Return true
        EndIf
    EndFunction

    Function Unlock()
        GotoState("")
    EndFunction
EndState