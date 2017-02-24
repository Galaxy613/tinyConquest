
#If TARGET="flash"
Import "urlopen.as"
#End

Private
Extern

Function URLOPEN__:Void(URL$)

Public

Function OpenURL(TargetURL$)
#If TARGET="flash"
	URLOPEN__(TargetURL)
#Else
	Print "Open URL doesn't support ${TARGET} Target!"
#End
End