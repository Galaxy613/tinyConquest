Strict
Import diddy

Global paused? = False
Global GameScreens:StringMap<CustomScreen> = New StringMap<CustomScreen>()

Function Main:Int()
	game = New ConquestApp()
	Return 0
End

Function SwitchToScreen:Void(targetScreen$)
	If GameScreens.Contains(targetScreen) Then
		game.screenFade.Start(15, True)
		game.nextScreen = GameScreens.Get(targetScreen)
	Else
		Print "<Warning> Can not find '"+targetScreen+"' ! Did you make sure the case is correct?"
	End
End

Class ConquestApp Extends DiddyApp
	
	Method OnCreate:Int()
		Super.OnCreate()
		
		if DEVICE_WIDTH < 800 Then SetScreenSize(800, (DEVICE_HEIGHT/DEVICE_WIDTH)*800)
		if DEVICE_WIDTH > 1280 Then SetScreenSize(1280, (DEVICE_HEIGHT/DEVICE_WIDTH)*1280)
		
		GameScreens.Insert("GameScreen", New GameplayScreen("GameScreen"))
		GameScreens.Insert("TitleScreen", New TitleScreen("TitleScreen"))
		GameScreens.Get("TitleScreen").PreStart()
		
		Return 0
	End
	
	Method OnLoading:Int()
		DrawText("Loading...",0,0)
		Return 0
	End
	
	Method OverrideUpdate:Void()
		'
	End
	
	Method OnSuspend:Int()
		paused = True
		SetUpdateRate 0
		Return 0
	End
	
	Method OnResume:Int()
		paused = False
		SetUpdateRate 60
		Return 0
	End
End

Class CustomScreen Extends Screen
	
End

Class TitleScreen Extends CustomScreen
	
	Method New(name$)
		self.name = name
	End
	
	Method Start:Void()
		''' Create/Load Stuff
	End
	
	Method PostFadeOut:Void()
		Super.PostFadeOut()
		''' Unload Stuff
	End
	
	Method Render:Void()
		SetColor 64,64,72
		DrawRect 0,0,SCREEN_WIDTH,SCREEN_HEIGHT
		SetColor 255,255,255
		
		SetBlend LightenBlend
		DrawText("Title Screen",0,0)
		FPSCounter.Draw(0,16)
		
		DrawText(game.mouseX+","+game.mouseY,game.mouseX,game.mouseY-16)
		SetBlend AlphaBlend
	End

	Method Update:Void()
		''' Use dt.delta to get the delta time
		
		If game.mouseHit Then SwitchToScreen("GameScreen")
	End
End

Class GameplayScreen Extends CustomScreen
	
	Method New(name$)
		self.name = name
	End
	
	Method Start:Void()
		''' Create/Load Stuff
	End
	
	Method PostFadeOut:Void()
		Super.PostFadeOut()
		''' Unload Stuff
	End
	
	Method Render:Void()
		SetColor 64,64,72
		DrawRect 0,0,SCREEN_WIDTH,SCREEN_HEIGHT
		SetColor 255,255,255
		
		SetBlend LightenBlend
		DrawText("Gameplay Screen",0,0)
		FPSCounter.Draw(0,16)
		
		DrawText(game.mouseX+","+game.mouseY,game.mouseX,game.mouseY-16)
		SetBlend AlphaBlend
	End

	Method Update:Void()
		''' Use dt.delta to get the delta time
		If game.mouseHit Then SwitchToScreen("TitleScreen")
	End
End