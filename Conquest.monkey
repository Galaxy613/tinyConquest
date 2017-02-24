Strict
Import diddy
Import Toolbox
Import MenuScn
Import TitleScn
Import GameScn
Import urlopen

#If TARGET = "Flash"
Import kongregate
#ENd

#REm
	KONGREGATE FEEDBACK:
!- Needs Pause Button
- Another Gameplay aspect?
- Simple Tutorial - AT LEAST A HELP MENU before/during Wave 1
- Play as attacker after reaching wave 20?

	LUDUM DARE FEEDBACK:
! Make the Buttons not move
- Try to fix the performance slow down (Simplify the Math? Sprites taking too long to draw?)
! Lessen the difficulty ramp up while still providing a challege, no one can get past waves 11-15
! Add Floating +/- Credit Amounts where gained and spent.
! Get music working on Android
! Add saving/loading of basic settings..
! Try to add non-retarded angle vector
#END

Const GameName:String = "Stellar Defense"
Global paused? = False, maxSurvived% = 0, isMouseUp? = false, wasMouseDown? = false
Global GameScreens:StringMap<CustomScreen> = New StringMap<CustomScreen>()
Global background:GameImage = Null
Global difficulty:Int = 1, isSoundOn:Bool = True
Global backgroundObjects:List<CObject> = New List<CObject>()

Global normalFont:Image = Null, largeFont:Image = null

Function Main:Int()
	game = New ConquestApp()
	Return 0
End

Function SwitchToScreen:Void(targetScreen$,fadeOut%=15)
	If GameScreens.Contains(targetScreen) Then
		game.screenFade.Start(fadeOut, True)
		game.nextScreen = GameScreens.Get(targetScreen)
	Else
		Print "<Warning> Can not find '"+targetScreen+"' ! Did you make sure the case is correct?"
	End
End

Class GameData
	Global data:StringMap<String> = New StringMap<String>()
	
	Function Get:String(name:String)
		If Not data.Contains(name) Then Return ""
		Return data.Get(name)
	End
	
	Function Set:Void(name:String, value:String = "")
		data.Set(name,value)
	End
	
	Function LoadFromSave:Void()
		Local tmpData:String[] = LoadState().Split("|")
		
		If LoadState() = "" Then Return
		If Not LoadState().Contains(";") Then data.Set("maxSurvived1", LoadState()); Return
		
		For Local tmpStr:String = EachIn tmpData
			data.Set(tmpStr.Split(";")[0], tmpStr.Split(";")[1])
			Print "Loaded [" + tmpStr.Split(";")[0] + "] = [" + tmpStr.Split(";")[1] + "]"
		Next
	End
	
	Function Save:Void()
		Local saveString:String = ""
		For Local tmpStr:String = EachIn data.Keys()
			If saveString <> "" Then
				saveString += "|"
			End
			saveString += tmpStr + ";" + data.Get(tmpStr)
		Next
		SaveState(saveString)
	End
End

Class ConquestApp Extends DiddyApp
	
	Method OnCreate:Int()
		Super.OnCreate()
		SetUpdateRate 60
		
#If TARGET = "Flash"
		Kongregate.Connect()
#ENd
		Seed = RealMillisecs()
		
		if DEVICE_WIDTH < 800 Then SetScreenSize(800, (DEVICE_HEIGHT/DEVICE_WIDTH)*800)
		if DEVICE_WIDTH > 1280 Then SetScreenSize(1280, (DEVICE_HEIGHT / DEVICE_WIDTH) * 1280)
		
		GameData.LoadFromSave()
		
		GameScreens.Insert("GameScreen", New GameplayScreen("GameScreen"))
		GameScreens.Insert("TitleScreen", New TitleScreen("TitleScreen"))
		GameScreens.Insert("GameOverScreen", New GameOverScreen("GameOverScreen"))
		GameScreens.Get("TitleScreen").PreStart()
		
		background = images.Load("background.png")
		images.Load("asteroid.png")
		images.Load("bomber.png")
		images.Load("destroyer.png")
		images.Load("fighter.png")
		images.Load("turret.png")
		images.Load("large_asteroid.png")
		images.Load("planet.png")
		
		Local soundExt$ = ".wav"
#if TARGET = "flash" or TARGET = "android"
		soundExt = ".mp3"
#End
		sounds.Load("New_Wave"+soundExt)
		sounds.Load("Explosion"+soundExt)
		sounds.Load("Build"+soundExt)
		sounds.Load("GameOver"+soundExt)
		sounds.Load("Shoot_Fast"+soundExt)
		sounds.Load("Shoot_Slow"+soundExt)
		sounds.Load("Warning"+soundExt)
		sounds.Load("music" + soundExt)
		
		Select GameData.Get("sound")
			Case "off"
				isSoundOn = False
			Default
				isSoundOn = True
		End
		
		game.sounds.Find("music").loop = 1
		If isSoundOn Then
			game.sounds.Find("music").Play()
#if TARGET = "android"
			PlayMusic("sounds/music.mp3")
#End
		End

		normalFont = LoadImage("awsmfont.png",96)
		largeFont = LoadImage("awsmfont2x.png",96)
		
		SetFont(normalFont)
		
		GameData.LoadFromSave()
		'If LoadState() <> "" then maxSurvived = Int(LoadState())
		
		Return 0
	End
	
	Method OnLoading:Int()
		DrawText("Loading...",0,0)
		Return 0
	End
	
	Method OverrideUpdate:Void()
		isMouseUp = False
		If wasMouseDown
			If Not MouseDown()
				isMouseUp = True
				wasMouseDown = False
			End
		ElseIf MouseDown()
			wasMouseDown = True
		End
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
