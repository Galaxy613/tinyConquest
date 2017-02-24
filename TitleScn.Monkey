Strict
Import Conquest
Import Units

Class TitleScreen Extends CustomScreen
	Field SoundButton:BasicButton = Null
	Field TwitterButton:BasicButton = Null
	Field TutorialButton:BasicButton = Null
	
'	Field Play0Button:BasicButton = Null	
'	Field Play1Button:BasicButton = Null
	
	Field Play0Button:BasicButton = Null	
	Field Play1Button:BasicButton = Null	
	Field Play2Button:BasicButton = Null	
	
	Field lastSpawnMS:Int = 0
	
	Field lastHitMS:Int = 0
	Field ESCHits:Int = 0
	
	Field isTutorial:Bool = False
	
	Method New(name$)
		self.name = name
		SoundButton = New BasicButton(SCREEN_WIDTH - 60, 60, 48, "Sound~nON")
		If Not isSoundOn then SoundButton.text.Replace("ON", "OFF")
		#if TARGET = "flash"
		TwitterButton = New BasicButton(SCREEN_WIDTH-60,SCREEN_HEIGHT-60,48,"Twitter")
		#end
		TutorialButton = New BasicButton(60, SCREEN_HEIGHT - 60, 48, "Help")
'		Play0Button = New BasicButton(SCREEN_WIDTH2-175,(SCREEN_HEIGHT*2)/3,64,"Play~nEasy")
'		Play1Button = New BasicButton(SCREEN_WIDTH2,(SCREEN_HEIGHT*2)/3,64,"Play~nNormal")
'		Play2Button = New BasicButton(SCREEN_WIDTH2 + 175, (SCREEN_HEIGHT * 2) / 3, 64, "Play~nHard")
		
		Play0Button = New BasicButton(SCREEN_WIDTH2 - 175, (SCREEN_HEIGHT) - 84, 64, "Play~nEasy")
		Play1Button = New BasicButton(SCREEN_WIDTH2, (SCREEN_HEIGHT) - 84, 64, "Play~nNormal")
		Play2Button = New BasicButton(SCREEN_WIDTH2 + 175, (SCREEN_HEIGHT) - 84, 64, "Play~nHard")
	End
	
	Method Start:Void()
		''' Create/Load Stuff
		If isSoundOn Then SoundButton.selected = true
		backgroundObjects.Clear()
		if Lazor.LazorList then
			Lazor.LazorList.Clear()
		Else
			Lazor.LazorList = New List<Lazor>()
		End
	End
	
	Method PostFadeOut:Void()
		Super.PostFadeOut()
		''' Unload Stuff
	End
	
	Method Render:Void()
'		SetColor 4,4,10
'		DrawRect 0,0,SCREEN_WIDTH,SCREEN_HEIGHT
		SetAlpha 0.5
		background.Draw(SCREEN_WIDTH2,SCREEN_HEIGHT2,0,SCREEN_WIDTH/32,SCREEN_WIDTH/32)
		SetAlpha 1.0
		
		PushMatrix ; Translate SCREEN_WIDTH2,SCREEN_HEIGHT2
		For Local tC:CObject = EachIn backgroundObjects
			tC.Draw()
		Next
		For Local tL:Lazor = eachin Lazor.LazorList
			tL.Draw()
		Next
		PopMatrix
		
		SetColor 64,64,72
		SetAlpha 0.8
		DrawRect 0,0,SCREEN_WIDTH,SCREEN_HEIGHT/8
		DrawRect 0,SCREEN_HEIGHT-(SCREEN_HEIGHT/8),SCREEN_WIDTH,SCREEN_HEIGHT/8
		SetColor 255,255,255
		SetAlpha 1.0
		
		'SetBlend LightenBlend
		SetAlpha 0.75
		DrawText("Created by Karl 'Galaxy613' Nyborg - ver1.3", 0, 0)
		SetAlpha 1.0
	'	PushMatrix ; Scale 2.0,2.0
		SetFont(largeFont)
		SetAlpha 0.25
		
		If Not isTutorial Then
			DrawText(GameName, SCREEN_WIDTH2 - 2, SCREEN_HEIGHT2 - 2 - 56, 0.5, 0.5)
			DrawText(GameName, SCREEN_WIDTH2 - 2, SCREEN_HEIGHT2 + 2 - 56, 0.5, 0.5)
			DrawText(GameName, SCREEN_WIDTH2 + 2, SCREEN_HEIGHT2 - 2 - 56, 0.5, 0.5)
			DrawText(GameName, SCREEN_WIDTH2 + 2, SCREEN_HEIGHT2 + 2 - 56, 0.5, 0.5)
			
			DrawText(GameName, SCREEN_WIDTH2 - 1, SCREEN_HEIGHT2 - 1 - 56, 0.5, 0.5)
			DrawText(GameName, SCREEN_WIDTH2 - 1, SCREEN_HEIGHT2 + 1 - 56, 0.5, 0.5)
			DrawText(GameName, SCREEN_WIDTH2 + 1, SCREEN_HEIGHT2 - 1 - 56, 0.5, 0.5)
			DrawText(GameName, SCREEN_WIDTH2 + 1, SCREEN_HEIGHT2 + 1 - 56, 0.5, 0.5)
			
			DrawText(GameName, SCREEN_WIDTH2 - 1, SCREEN_HEIGHT2 - 56, 0.5, 0.5)
			DrawText(GameName, SCREEN_WIDTH2, SCREEN_HEIGHT2 + 1 - 56, 0.5, 0.5)
			DrawText(GameName, SCREEN_WIDTH2 + 1, SCREEN_HEIGHT2 - 56, 0.5, 0.5)
			DrawText(GameName, SCREEN_WIDTH2, SCREEN_HEIGHT2 - 1 - 56, 0.5, 0.5)
	'		SetColor 255,100,100
	'		DrawText(GameName,SCREEN_WIDTH2-2,SCREEN_HEIGHT2-2-32,0.5,0.5)
	'		SetColor 100,100,255
	'		DrawText(GameName,SCREEN_WIDTH2+2,SCREEN_HEIGHT2+2-32,0.5,0.5)
			SetColor 255,255,255
			SetAlpha 1.0
			DrawText(GameName, SCREEN_WIDTH2, SCREEN_HEIGHT2 - 56, 0.5, 0.5)
			
			DrawText("Highscores:", SCREEN_WIDTH2, SCREEN_HEIGHT2 - 18, 0.5, 0.5)
			If GameData.data.Contains("maxSurvived0") Then DrawText("Easy : " + StrToInt(GameData.Get("maxSurvived0")) + " Waves", SCREEN_WIDTH2, SCREEN_HEIGHT2 - 16 + (24 * 1), 0.5, 0.5)
			If GameData.data.Contains("maxSurvived1") Then DrawText("Normal : " + StrToInt(GameData.Get("maxSurvived1")) + " Waves", SCREEN_WIDTH2, SCREEN_HEIGHT2 - 16 + (24 * 2), 0.5, 0.5)
			If GameData.data.Contains("maxSurvived2") Then DrawText("Hard : " + StrToInt(GameData.Get("maxSurvived2")) + " Waves", SCREEN_WIDTH2, SCREEN_HEIGHT2 - 16 + (24 * 3), 0.5, 0.5)
		'	DrawText("Click the screen to continue..",SCREEN_WIDTH2,SCREEN_HEIGHT2+32,0.5,0.5)
			
			If not Play0Button.empty Then
				DrawText("More Credits per Round/Kill.", SCREEN_WIDTH2, SCREEN_HEIGHT - 32, 0.5, 0.5)
			ElseIf not Play1Button.empty Then
				DrawText("Standard Difficulty.", SCREEN_WIDTH2, SCREEN_HEIGHT - 32, 0.5, 0.5)
			ElseIf not Play2Button.empty Then
				DrawText("Waves start faster & Less Credits.", SCREEN_WIDTH2, SCREEN_HEIGHT - 32, 0.5, 0.5)
			End
			
			SetFont(largeFont)
			Play0Button.Draw()
			Play1Button.Draw()
			Play2Button.Draw()
			if TwitterButton Then TwitterButton.Draw()
			SetFont(normalFont)
		Else
#rem
	You can play 100% with the Mouse. Or:
	Arrow Keys – Select different waypoints
	Number Keys 1-4 – Build Fighter/Bomber/Frigate/Heal in that order.
#END
			SetColor 255,255,255
			SetAlpha 1.0
			SetFont(largeFont)
			DrawText("Tutorial:", SCREEN_WIDTH2 - 1, SCREEN_HEIGHT2 - 1 - 128, 0.5, 0.5)
			DrawText("Tutorial:", SCREEN_WIDTH2, SCREEN_HEIGHT2 - 128, 0.5, 0.5)
			DrawText("The goal of the game is to protect your homeworld for", SCREEN_WIDTH2, SCREEN_HEIGHT2 - 64, 0.5, 0.5)
			DrawText("as many turns as possible. You have four waypoints", SCREEN_WIDTH2, SCREEN_HEIGHT2 - 64 + (32 * 1), 0.5, 0.5)
			DrawText("to send ships to.", SCREEN_WIDTH2, SCREEN_HEIGHT2 - 64 + (32 * 2), 0.5, 0.5)
		'	DrawText("", SCREEN_WIDTH2, SCREEN_HEIGHT2 - 64 + (32 * 3), 0.5, 0.5)
			DrawText("Use the WASD or Arrow Keys to pick which one.", SCREEN_WIDTH2, SCREEN_HEIGHT2 - 64 + (32 * 4), 0.5, 0.5)
			DrawText("Use Numbers 1-4 to Build ships", SCREEN_WIDTH2, SCREEN_HEIGHT2 - 64 + (32 * 5), 0.5, 0.5)
			SetFont(normalFont)
		End
		SetFont(largeFont)
		SoundButton.Draw()
		TutorialButton.Draw()
		SetFont(normalFont)
	'	PopMatrix
	'	FPSCounter.Draw(0,16)
		If ESCHits > 0 Then DrawText("Tap Back " + (3 - ESCHits) + " more time(s) to Exit", SCREEN_WIDTH2, 24, 0.5, 0.5)
		
	'	SetAlpha 0.1
	'	DrawText(game.mouseX+","+game.mouseY,game.mouseX,game.mouseY-16)
		SetAlpha 1.0
		SetBlend AlphaBlend
	End

	Method Update:Void()
		If KeyHit(KEY_ESCAPE) Then
			lastHitMS = Millisecs()
			ESCHits += 1
		ElseIf Millisecs() -lastHitMS > 5000 Then
			ESCHits = 0
		ElseIf ESCHits > 2
			ExitApp
		End
	
		If lastSpawnMS < Millisecs() Then
			Local tmpCObj:CObject = Null
			For Local astCount% = 0 until Int(Rnd(1,3))
				tmpCObj = New Fighter()
				backgroundObjects.AddLast(tmpCObj)
				GetOrbit(tmpCObj,(astCount*15)+180-15,SCREEN_WIDTH2)
				tmpCObj.team = 1
			Next
			For Local astCount% = 0 until Int(Rnd(1,3))
				tmpCObj = New Fighter()
				backgroundObjects.AddLast(tmpCObj)
				GetOrbit(tmpCObj,(astCount*15)-15,SCREEN_WIDTH2)
				tmpCObj.team = 2
			Next
			lastSpawnMS = Millisecs() + 15*1000
		End
		
		For Local tC:CObject = EachIn backgroundObjects
			tC.Update()
			If tC.team > 0 Then
				For Local tC2:CObject = EachIn backgroundObjects
					If tC2 <> tC Then
						If tC.UpdateTarget(tC2) Then Exit
					End
				Next
			End
			If tC.hull < 1 Then
				For Local effCount% = 0 until 6
					Lazor.LazorList.AddLast(New Lazor(tC.x,tC.y,tC.x+Rnd(-50,50),tC.y+Rnd(-50,50),Rnd(255),Rnd(255),Rnd(255)))
				Next
				backgroundObjects.Remove(tC)
				If isSoundOn then game.sounds.Find("Explosion").Play()
			End
		Next
		For Local tL:Lazor = eachin Lazor.LazorList
			tL.Update()
			If tL.opacity = 0.0 Then Lazor.LazorList.Remove(tL)
		Next
		
		If Not isTutorial
			Play0Button.Update()
			Play1Button.Update()
			Play2Button.Update()
			If TwitterButton Then
				TwitterButton.Update()
				if TwitterButton.hit Then OpenURL("twitter.com/#!/Galaxy613")
			End
		End
		TutorialButton.Update()
		SoundButton.Update()
		If SoundButton.hit Then
			If isSoundOn Then
				isSoundOn = False
				GameData.Set("sound", "off")
				SoundButton.text = "Sound~nOFF"
				StopMusic()
				game.sounds.Find("music").Stop()
				game.sounds.Find("Shoot_Slow").Play()
			Else
				isSoundOn = True
				GameData.Set("sound", "on")
				SoundButton.text = "Sound~nON"
				game.sounds.Find("music").Play()
#if TARGET = "android"
				PlayMusic("sounds/music.mp3")
#End
			End
			GameData.Save()
			SoundButton.selected = isSoundOn
		'	If isSoundOn then game.sounds.Find("Shoot_Slow").Play()
		End
		If isSoundOn Then
			SoundButton.text = "Sound~nON"
		Else
			SoundButton.text = "Sound~nOFF"
		End
		
		If TutorialButton.hit Then
			If isTutorial Then
				isTutorial = False
				TutorialButton.text = "Help"
			Else
				isTutorial = True
				TutorialButton.text = "Back"
			End
		End
		
		If Play0Button.hit Then
			difficulty=0
			SwitchToScreen("GameScreen")
			If isSoundOn then game.sounds.Find("Warning").Play()
		ElseIf Play1Button.hit Then
			difficulty=1
			SwitchToScreen("GameScreen")
			If isSoundOn then game.sounds.Find("Warning").Play()
		ElseIf Play2Button.hit Then
			difficulty=2
			SwitchToScreen("GameScreen")
			If isSoundOn then game.sounds.Find("Warning").Play()
		End
		
		'If isMouseUp Then SwitchToScreen("GameScreen")
	End
End

Class GameOverScreen Extends CustomScreen
	Field SoundButton:BasicButton = Null
	Field TwitterButton:BasicButton = Null
	Field gameScn:GameplayScreen = Null
	
	Method New(name$)
		self.name = name
		SoundButton = New BasicButton(SCREEN_WIDTH2,SCREEN_HEIGHT*.75,100,"Return to~nMain Menu")
		#if TARGET = "flash"
		TwitterButton = New BasicButton(SCREEN_WIDTH-60,SCREEN_HEIGHT-60,48,"Tweet!")
		#end
	End
	
	Method Start:Void()
		''' Create/Load Stuff
		If isSoundOn Then SoundButton.selected = true
		gameScn = GameplayScreen(GameScreens.Get("GameScreen"))
		If gameScn.stats_totalShipsDestroyed > StrToInt(GameData.Get("totalShipKilled")) Then GameData.Set("totalShipKilled", gameScn.stats_totalShipsDestroyed)
		If gameScn.stats_totalCashGained > StrToInt(GameData.Get("totalCashEarned")) Then GameData.Set("totalCashEarned", gameScn.stats_totalCashGained)
		If gameScn.stats_shipsBuilt > StrToInt(GameData.Get("totalShipBuilt")) Then GameData.Set("totalShipBuilt", gameScn.stats_shipsBuilt)
		If gameScn.stats_yourShipsDestroyed > StrToInt(GameData.Get("totalShipLost")) Then GameData.Set("totalShipLost", gameScn.stats_yourShipsDestroyed)
		GameData.Save()
	End
	
	Method PostFadeOut:Void()
		Super.PostFadeOut()
		''' Unload Stuff
	End
	
	Method Render:Void()
'		SetColor 4,4,10
'		DrawRect 0,0,SCREEN_WIDTH,SCREEN_HEIGHT
		SetAlpha 0.5
		background.Draw(SCREEN_WIDTH2,SCREEN_HEIGHT2,0,SCREEN_WIDTH/32,SCREEN_WIDTH/32)
		SetAlpha 1.0
		SetColor 64,64,72
		SetAlpha 0.8
		DrawRect 0,0,SCREEN_WIDTH,SCREEN_HEIGHT/8
		DrawRect 0,SCREEN_HEIGHT-(SCREEN_HEIGHT/8),SCREEN_WIDTH,SCREEN_HEIGHT/8
		SetColor 255,255,255
		SetAlpha 1.0
		
		'SetBlend LightenBlend
		SetAlpha 1.0
	'	PushMatrix ; Scale 2.0,2.0
		SetFont(largeFont)
		SetColor 255,255,255
		SetAlpha 1.0
		DrawText("Waves Survived this Round: " + gameScn.survivedFor + " Highscore: " + StrToInt(GameData.Get("maxSurvived" + difficulty)), SCREEN_WIDTH2, SCREEN_HEIGHT2 - 48 - 64, 0.5, 0.5)
		DrawText("Total Ships Destroyed: " + gameScn.stats_totalShipsDestroyed + " High: " + StrToInt(GameData.Get("totalShipKilled")), SCREEN_WIDTH2, SCREEN_HEIGHT2 - 64, 0.5, 0.5)
		DrawText("Total Credits Earned: " + gameScn.stats_totalCashGained + " High: " + StrToInt(GameData.Get("totalCashEarned")), SCREEN_WIDTH2, SCREEN_HEIGHT2 + 32 - 64, 0.5, 0.5)
		DrawText("Total Ships Built: " + gameScn.stats_shipsBuilt + " High: " + StrToInt(GameData.Get("totalShipBuilt")), SCREEN_WIDTH2, SCREEN_HEIGHT2 + 64 - 64, 0.5, 0.5)
		DrawText("Total Ships Lost: " + gameScn.stats_yourShipsDestroyed + " High: " + StrToInt(GameData.Get("totalShipLost")), SCREEN_WIDTH2, SCREEN_HEIGHT2 + 96 - 64, 0.5, 0.5)
	'	DrawText("Click the screen to continue..",SCREEN_WIDTH2,SCREEN_HEIGHT2+32,0.5,0.5)
		
		SetFont(normalFont)
	'	PopMatrix
		FPSCounter.Draw(0,16)
		
		SetFont(largeFont)
		SoundButton.Draw()
		if TwitterButton Then TwitterButton.Draw()
		SetFont(normalFont)
		
		SetAlpha 0.1
		DrawText(game.mouseX+","+game.mouseY,game.mouseX,game.mouseY-16)
		SetAlpha 1.0
		SetBlend AlphaBlend
	End

	Method Update:Void()
		''' Use dt.delta to get the delta time
		
		SoundButton.Update()
		If SoundButton.hit Then
			SwitchToScreen("TitleScreen")
			If isSoundOn then game.sounds.Find("Shoot_Slow").Play()
		End
		
		If TwitterButton Then
			TwitterButton.Update()
			if TwitterButton.hit Then OpenURL("twitter.com/intent/tweet?hashtags=LD48&related=Galaxy613&source=tweetbutton&text=I%20got%20a%20highscore%20of%20"+maxSurvived+"%20in%20tinyCONQUEST%20by%20%40Galaxy613&via=Galaxy613")
		End
	End
End