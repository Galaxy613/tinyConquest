Private

Import "native/kongregate.as"

Extern Private

Class NativeKong="Kong"
	Method KongInit()
	Method KongSubmitStat(stat$,value%)
	Method KongGetUsername$()
	Method KongIsGuest?()
	Method KongIsConnected?()
	Method KongGetUserId%()
	Method KongPrivateMessage(pm$)
	Method KongShowSignInBox()
	Method KongGetGameAuthToken$()
	Method KongShowRegisterBox()
End

Private
Global device:NativeKong = new NativeKong()

Public

Class Kongregate
	Function Connect()
		#If TARGET="flash"
			Return device.KongInit()
		#EndIf
	End
	
	Function SubmitStat(stat$,value%)
		#If TARGET="flash"
			Return device.KongSubmitStat(stat,value)
		#EndIf
	End
	
	Function GetUsername$()
		#If TARGET="flash"
			Return device.KongGetUsername()
		#EndIf
		Return ""
	End
	
	Function IsGuest?()
		#If TARGET="flash"
			Return device.KongIsGuest()
		#EndIf
		Return False
	End
	
	Function IsConnected?()
		#If TARGET="flash"
			Return device.KongIsConnected()
		#EndIf
		Return False
	End
	
	Function GetUserId%()
		#If TARGET="flash"
			Return device.KongGetUserId()
		#EndIf
		Return 0
	End
	
	Function PrivateMessage(pm$)
		#If TARGET="flash"
			Return device.KongPrivateMessage(pm)
		#EndIf
	End
	
	Function ShowSignInBox()
		#If TARGET="flash"
			Return device.KongShowSignInBox()
		#EndIf
	End
	
	Function GetGameAuthToken$()
		#If TARGET="flash"
			Return device.KongGetGameAuthToken()
		#EndIf
		Return ""
	End
	
	Function ShowRegisterBox()
		#If TARGET="flash"
			Return device.KongShowRegisterBox()
		#EndIf
	End
End

Class Kong extends Kongregate

End