Strict
Import Conquest
Import Units

Global Scroll:Point = Null
Global RealMouseX% = 0, RealMouseY% = 0
Class GameplayScreen Extends CustomScreen
	Field SoundButton:BasicButton = Null
	Field objects:List<CObject> = New List<CObject>()
	Field waypoints:List<WaypointNode> = New List<WaypointNode>()
	Field PlayersPlanet:Planet = Null
	Field lastSpawnMS% = 0, survivedFor% = 1
	Field credits:Int = 0, isPlayerDead:Bool = false
	
	Field updateTotalMSHigh:Int = 0
	Field renderTotalMSHigh:Int = 0
	Field unitUpdateMSHigh:Int = 0
'	Field unitUpdateMSHigh:Int = 0

	Field isPaused:Bool = False
	Field pausedMS:Int = 0
	Field PauseButton:BasicButton
	
	Field stats_totalCashGained%=0,stats_totalShipsDestroyed%=0,stats_yourShipsDestroyed%=0,stats_shipsBuilt%=0
	
	Field FighterButton:BasicButton, BomberButton:BasicButton, DestroyerButton:BasicButton, RepairButton:BasicButton, SkipButton:BasicButton
	
	Method New(name$)
		self.name = name
'		SoundButton = New BasicButton(SCREEN_WIDTH-48,48,24,"Pause~nGame")
	End
	
	Method Start:Void()
		Print "Game Scn Started"
		''' Create/Load Stuff
		if Lazor.LazorList then
			Lazor.LazorList.Clear()
		Else
			Lazor.LazorList = New List<Lazor>()
		End
		credits = 0
		isPlayerDead = False
		objects.Clear()
		waypoints.Clear()
		Scroll = new Point(0,0)
		Scroll.x = 0
		Scroll.y = 0
		Generate2PMap
		lastSpawnMS = Millisecs() + (15 * 1000)
		
		stats_totalCashGained=0
		stats_totalShipsDestroyed=0
		stats_yourShipsDestroyed=0
		stats_shipsBuilt=0
		
		IF FighterButton = Null Then
			FighterButton = New BasicButton(32,SCREEN_HEIGHT2-(42*3),32,"Fighter~n3cr")
			BomberButton = New BasicButton(32,SCREEN_HEIGHT2-(42*1),32,"Bomber~n10cr")
			DestroyerButton = New BasicButton(32,SCREEN_HEIGHT2+(42*1),32,"Frigate~n25cr")
			RepairButton = New BasicButton(32, SCREEN_HEIGHT2 + (42 * 3), 32, "Planet~nHeal 2cr")
			SkipButton = New BasicButton(SCREEN_WIDTH - 48, 38, 32, "Send Next~nWave")
			PauseButton = New BasicButton(48, 38, 32, "Pause~nGame")
		End
		Print "Game Scn Finished"
	End
	
	Method PostFadeOut:Void()
		Super.PostFadeOut()
		''' Unload Stuff
	End
	
	Method Render:Void()
		Local timeMS:Int = Millisecs()
		
		SetColor 4,10,4
		DrawRect 0,0,SCREEN_WIDTH,SCREEN_HEIGHT
		SetColor 255,255,255
		SetAlpha 0.5
		background.Draw(SCREEN_WIDTH2,SCREEN_HEIGHT2,0,SCREEN_WIDTH/32,SCREEN_WIDTH/32)
		SetAlpha 1.0
		
		PushMatrix ; Translate Scroll.x+SCREEN_WIDTH2,Scroll.y+SCREEN_HEIGHT2
		SetColor 32,32,32
		DrawLine -300,0,300,0
		DrawLine 0,-300,0,300
		SetColor 255,255,255
		
		SetBlend LightenBlend
		For Local tC:WaypointNode = eachin waypoints
			tC.Draw()
		Next
		For Local tC:CObject = eachin objects
			tC.Draw()
		Next
		For Local tL:Lazor = eachin Lazor.LazorList
			tL.Draw()
		Next
		
		FloatingText.DrawAll()
		PopMatrix
		
		SetFont(largeFont)
		If PlayersPlanet then
			If PlayersPlanet.hull < 10 Then SetColor 255,0,0
			DrawText("PLANET HP: "+PlayersPlanet.hull,SCREEN_WIDTH2,SCREEN_HEIGHT-32-16,0.5)
			SetColor 255,255,255
			
			SetFont(normalFont)
			'lastSpawnMS+((20+survivedFor)*1000)< Millisecs()
			DrawText("Next Wave in: "+Int((lastSpawnMS - Millisecs())*0.001)+" seconds",SCREEN_WIDTH2,SCREEN_HEIGHT-24,0.5)
		Else
			DrawText("Planet DESTROYED! Game Over Man, GAME OVER!!!",SCREEN_WIDTH2,SCREEN_HEIGHT-32,0.5)
		End
		SetFont(normalFont)
		DrawText("You have Survived for: "+survivedFor+" Waves",SCREEN_WIDTH2,8,0.5)
		SetAlpha 0.5
	'	FPSCounter.Draw(0,0)
		SetAlpha 1.0
		
		SetFont(largeFont)
		DrawText "CREDITS: "+credits,SCREEN_WIDTH2,24,0.5
		SetFont(normalFont)
		
		FighterButton.Draw()
		BomberButton.Draw()
		DestroyerButton.Draw()
		RepairButton.Draw()
		SkipButton.Draw()
'		SoundButton.Draw()
		
		'DrawText(game.mouseX+","+game.mouseY,game.mouseX,game.mouseY-16)
'		SetAlpha 0.1
'		DrawText(RealMouseX+","+RealMouseY,game.mouseX,game.mouseY-16)
'		SetAlpha 1.0
		SetBlend AlphaBlend
		
		If isPaused Then
			SetAlpha 0.5
			SetColor 0, 0, 0
			DrawRect 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT
			SetAlpha 1.0
			SetColor 255, 255, 255
			If (Millisecs() -pausedMS) Mod 1000 < 500 Then
				SetFont(largeFont)
				DrawText "- GAME PAUSED -", SCREEN_WIDTH2, SCREEN_HEIGHT2, 0.5
				SetFont(normalFont)
			End
		End
		PauseButton.Draw()
		
		timeMS = Millisecs() - timeMS
		If timeMS > renderTotalMSHigh Then renderTotalMSHigh = timeMS
'		DrawText "draw" + renderTotalMSHigh, 16, 32
'		DrawText "upda" + updateTotalMSHigh, 16, 48
'		DrawText "unit" + unitUpdateMSHigh, 16, 64
	End
			
	Method Generate2PMap:Void()
		survivedFor = 1
		PlayersPlanet = New Planet()
		objects.AddLast(PlayersPlanet)
	'	PlayersPlanet.x = -150
		PlayersPlanet.team = 1
		
		If isSoundOn then game.sounds.Find("New_Wave").Play()
		
		Local tmpCObj:CObject = null
		
		For Local astCount% = 0 until 12
			tmpCObj = New Asteroid()
			objects.AddLast(tmpCObj)
			GetOrbit(tmpCObj,Rnd(360),32+Rnd(400))
		Next
		For Local astCount% = 0 until 3
			tmpCObj = New LargeAsteroid()
			objects.AddLast(tmpCObj)
			GetOrbit(tmpCObj,Rnd(360),Rnd(350)+50)
		Next
		
		For Local astCount% = 0 until 4
			Local tmpWObj := New WaypointNode()
			waypoints.AddLast(tmpWObj)
			GetOrbit(tmpWObj,astCount*90,125)
			Select astCount
				Case 1
					tmpWObj.name = "Beta"
				Case 2
					tmpWObj.name = "Gamma"
				Case 3
					tmpWObj.name = "Delta"
				Default 
					tmpWObj.name = "Alpha"
			End
		Next
		
		For Local astCount% = 0 until 4
			tmpCObj = New Turret()
			objects.AddLast(tmpCObj)
			GetOrbit(tmpCObj,astCount*90,30)
			tmpCObj.team = 1
			tmpCObj.angle = Rnd(-90,90)
			tmpCObj.hull *= 2
			
			tmpCObj = New Turret()
			objects.AddLast(tmpCObj)
			GetOrbit(tmpCObj,astCount*90,150)
			tmpCObj.team = 1
			tmpCObj.angle = Rnd(-90,90)
			tmpCObj.hull *= 2
		Next
		
		For Local astCount% = 0 until 4
			tmpCObj = New Fighter()
			objects.AddLast(tmpCObj)
			GetOrbit(tmpCObj,astCount*90+45,150)',-150)
			tmpCObj.team = 1
		Next
		
		For Local astCount% = 0 until 6
			tmpCObj = New Fighter()
			objects.AddLast(tmpCObj)
			GetOrbit(tmpCObj,astCount*(360/6)+45,400)',-150)
			tmpCObj.team = 2
		Next
		
		MakeDestroyer(1,Rnd(360),Rnd(50))
	End
	
	Method MakeDestroyer:Destroyer(team%,angle#,dist#)
		Local destObj := New Destroyer()
		destObj.team = team
		GetOrbit(destObj, angle,dist)
		objects.AddLast(destObj)
				
		Local tmpTurret:Turret = new Turret()
		tmpTurret.Attach(destObj,0,16)
		objects.AddLast(tmpTurret)
		
		tmpTurret = new Turret()
		tmpTurret.Attach(destObj,0,0)
		objects.AddLast(tmpTurret)
		
		tmpTurret = new Turret()
		tmpTurret.Attach(destObj,180,16)
		objects.AddLast(tmpTurret)
		
		Return destObj
	End
	
	Method MakeBomber:Fighter(team%,angle#,dist#)
		Local destObj := New Fighter()
		destObj.image = game.images.Find("bomber")
		destObj.speed -= 0.3
		destObj.hull += 2
		destObj.team = team
		GetOrbit(destObj, angle,dist)
		objects.AddLast(destObj)
				
		Local tmpTurret:Turret = new Turret()
		tmpTurret.Attach(destObj,0,0)
		objects.AddLast(tmpTurret)
		
		Return destObj
	End
	
	Method SpawnNewWave:Void() ' difficulty
		Local tmpCObj:CObject = null
		Local fighterCount:Int = 0, bomberCount:Int = 0, destroyerCount:Int = 0
		
		fighterCount = (4 + difficulty + (survivedFor / 2))
		
		bomberCount = (difficulty + Int(survivedFor / 3)) - 2
		If bomberCount < 1 Then
			bomberCount = 0
		Else
			fighterCount -= bomberCount
		End
		
		destroyerCount = (difficulty + Int(survivedFor / 5)) - 3
		If destroyerCount < 1 Then
			destroyerCount = 0
		Else
			bomberCount -= destroyerCount '* 5
			fighterCount -= destroyerCount * 3
		End
		
		If fighterCount < 1 Then fighterCount = 0
		
		''' Actually spawn them
		For Local astCount% = 0 until fighterCount
			tmpCObj = New Fighter()
			objects.AddLast(tmpCObj)
			GetOrbit(tmpCObj, Rnd(360), 300 + Rnd(700 - (difficulty * 100)))
			tmpCObj.team = 2
		Next
		For Local astCount:Int = 0 until bomberCount'((survivedFor-4)/2)
			MakeBomber(2, Rnd(360), 300 + Rnd(600 - (difficulty * 100)))
		Next
		For Local astCount:Int = 0 until destroyerCount'((survivedFor-9)/3)
			MakeDestroyer(2, Rnd(360), 300 + Rnd(500 - (difficulty * 100)))
		Next
		
		''' Credits and Crap
		credits += survivedFor * 2
		FloatingText.Create("+" + (survivedFor * 2) + "c", 0, 0, 0, 255, 0)
	'	if difficulty = 0 Then credits += survivedFor * 2
		stats_totalCashGained += survivedFor*2
	'	if difficulty = 0 Then stats_totalCashGained += survivedFor * 2
		
		survivedFor += 1
		If survivedFor > StrToInt(GameData.Get("maxSurvived" + difficulty)) Then GameData.Set("maxSurvived" + difficulty, survivedFor)
		GameData.Save()
		
#If TARGET = "Flash"
		If Kongregate.IsConnected() Then
			Select difficulty
				Case 2
					Kongregate.SubmitStat("HardLevel", survivedFor)
				Case 1
					Kongregate.SubmitStat("NormalLevel", survivedFor)
				Default
					Kongregate.SubmitStat("EasyLevel", survivedFor)
			End
		End
#ENd
		
'		if difficulty = 2 Then 
'			lastSpawnMS = Millisecs()+((15+survivedFor)*900)
'		Else
'			lastSpawnMS = Millisecs()+((20+survivedFor)*1000)
'		End
		if difficulty = 2 Then 
			lastSpawnMS = Millisecs()+(15*1000)'+((survivedFor)*100)
		Else
			lastSpawnMS = Millisecs()+(20*1000)'+((survivedFor)*100)
		End
		If isSoundOn Then game.sounds.Find("New_Wave").Play()
	End

	Method Update:Void()
		Local timeMS:Int = Millisecs()
		RealMouseX = (game.mouseX-(Scroll.x+SCREEN_WIDTH2))
		RealMouseY = (game.mouseY-(Scroll.y+SCREEN_HEIGHT2))
		
		If paused Then Return
		
		PauseButton.Update()
		If PauseButton.hit Then
			If isPaused Then
				isPaused = False
			Else
				isPaused = True
				pausedMS = Millisecs()
			End
		Else
			If isPaused And MouseHit() Then isPaused = False
		End
		If isPaused Then Return
		
		If Not isPlayerDead Then
			if PlayersPlanet = Null Then
				isPlayerDead = True
				SwitchToScreen("GameOverScreen",50)
			End
		End
		
'		If isMouseUp Then
'			If game.mouseY < 32 And game.mouseX < 32 Then SwitchToScreen("GameOverScreen")
'		End
		If KeyHit(KEY_ESCAPE) Then SwitchToScreen("GameOverScreen")		
		
		If lastSpawnMS < Millisecs() And PlayersPlanet Then
			SpawnNewWave()
		End
		
		Local tmpPlyHull:Int = 0
		Local unittimeMS:Int = Millisecs()
		If PlayersPlanet Then tmpPlyHull = PlayersPlanet.hull
		For Local tC:CObject = eachin objects
			tC.Update()
			If tC.team > 0 Then
				For Local tC2:CObject = eachin objects
					If tC2 <> tC Then
						If tC.UpdateTarget(tC2) Then Exit
					End
				Next
				
				If tC.Waypoint = null And tC.team = 1
					Local closestDist# = 999, closestWay:CObject=Null, tmpDist# = 0
					
					For Local tw:CObject = eachin waypoints
						tmpDist = tC.DistanceFrom(tw)
						If tmpDist < closestDist Then 
							closestDist=tmpDist
							closestWay = tw
						End
					Next
					
					tC.Waypoint = closestWay
				End
			End
			If tC.hull < 1 Then
				For Local effCount% = 0 until 10
					Lazor.LazorList.AddLast(New Lazor(tC.x,tC.y,tC.x+Rnd(-50,50),tC.y+Rnd(-50,50),Rnd(255),Rnd(255),Rnd(255)))
				Next
				If tC.team <> 1 Then
					credits += 3 - difficulty
					FloatingText.Create("+" + (3 - difficulty) + "c", tC.x, tC.y, 0, 255, 0)
					stats_totalShipsDestroyed += 1
				ElseIf tC.team = 1
					stats_yourShipsDestroyed += 1
				End 
				objects.Remove(tC)
				If isSoundOn then game.sounds.Find("Explosion").Play()
			End
		Next
		unittimeMS = Millisecs() -unittimeMS
		If unittimeMS > unitUpdateMSHigh Then unitUpdateMSHigh = unittimeMS
		
		If PlayersPlanet then
			If PlayersPlanet.hull < 1 Then
				For Local effCount% = 0 until 50
					Lazor.LazorList.AddLast(New Lazor(PlayersPlanet.x+Rnd(-25,25),PlayersPlanet.y+Rnd(-25,25),PlayersPlanet.x+Rnd(-75,75),PlayersPlanet.y+Rnd(-75,75),Rnd(255),Rnd(255),Rnd(255),Rnd(0.75,5.0)))
				Next
				PlayersPlanet = Null
				If isSoundOn then game.sounds.Find("GameOver").Play()
			ElseIf tmpPlyHull <> PlayersPlanet.hull And tmpPlyHull >= 10 And PlayersPlanet.hull < 10 Then 
				If isSoundOn then game.sounds.Find("Warning").Play()
			End
		End
		
		For Local tL:Lazor = eachin Lazor.LazorList
			tL.Update()
			If tL.opacity = 0.0 Then Lazor.LazorList.Remove(tL)
		Next
		Local count% = 0
		For Local way:WaypointNode = eachin waypoints
			way.Update()
			Select way.name.ToLower()
				Case "alpha"
					If KeyHit(KEY_RIGHT) or KeyHit(KEY_D) Then WaypointCurrent = way
				Case "beta"
					If KeyHit(KEY_DOWN) or KeyHit(KEY_S) Then WaypointCurrent = way
				Case "gamma"
					If KeyHit(KEY_LEFT) or KeyHit(KEY_A) Then WaypointCurrent = way
				Case "delta"
					If KeyHit(KEY_UP) or KeyHit(KEY_W) Then WaypointCurrent = way			
			End
			count += 1
		Next
		If PlayersPlanet then PlayersPlanet.Waypoint = WaypointCurrent
		
'		If game.mouseX > SCREEN_WIDTH2 Then
'			FighterButton.x = SCREEN_WIDTH-48
'			BomberButton.x = SCREEN_WIDTH-48
'			DestroyerButton.x = SCREEN_WIDTH-48
'			RepairButton.x = SCREEN_WIDTH-48
'		Else
			FighterButton.x = 48
			BomberButton.x = 48
			DestroyerButton.x = 48
			RepairButton.x = 48
'		End
		
		FighterButton.Update()
		BomberButton.Update()
		DestroyerButton.Update()
		RepairButton.Update()
		SkipButton.Update()
	'	SoundButton.Update()
	
		FloatingText.UpdateAll()
		
		SkipButton.active = False
		If Int( (lastSpawnMS - Millisecs()) * 0.001) < 10 Then SkipButton.active = True
		If SkipButton.hit And PlayersPlanet Then
			SpawnNewWave()
		'	credits += Int( (lastSpawnMS - Millisecs()) * 0.0005)
		Else
			'Int((lastSpawnMS - Millisecs())*0.001)
			SkipButton.text = "Send Next~nWave"' +" + Int( (lastSpawnMS - Millisecs()) * 0.0005) + "c"
		End
		
		Local oAngle# = Rnd(360)
		If WaypointCurrent Then oAngle = GetAngle(0,0,WaypointCurrent.x,WaypointCurrent.y)		
		
		If FighterButton.hit or KeyHit(KEY_1) Then
			If credits > 2 Then
				credits -= 3
				Local tmpCObj:CObject = New Fighter()
				tmpCObj.team = 1
				GetOrbit(tmpCObj,oAngle,Rnd(16,50))
				tmpCObj.angle = oAngle
				objects.AddLast(tmpCObj)
				tmpCObj.Waypoint = WaypointCurrent
				FighterButton.drawHit = True
				If isSoundOn then game.sounds.Find("Build").Play()
				stats_shipsBuilt += 1
				FloatingText.Create("-" + (3) + "c", WaypointCurrent.x, WaypointCurrent.y, 255, 0, 0)
			End
		ElseIf BomberButton.hit or KeyHit(KEY_2) Then
			If credits > 9 Then
				credits -= 10
				Local tmp:Fighter = MakeBomber(1,oAngle,Rnd(16,50))
				tmp.Waypoint = WaypointCurrent
				tmp.angle = oAngle
				If isSoundOn then game.sounds.Find("Build").Play()
				stats_shipsBuilt += 1
				FloatingText.Create("-" + (10) + "c", WaypointCurrent.x, WaypointCurrent.y, 255, 0, 0)
			End
		ElseIf DestroyerButton.hit or KeyHit(KEY_3) Then
			If credits > 24 Then
				credits -= 25
				Local tmp:Destroyer = MakeDestroyer(1,oAngle,Rnd(16,50))
				tmp.Waypoint = WaypointCurrent
				tmp.angle = oAngle
				If isSoundOn then game.sounds.Find("Build").Play()
				stats_shipsBuilt += 1
				FloatingText.Create("-" + (25) + "c", WaypointCurrent.x, WaypointCurrent.y, 255, 0, 0)
			End
		ElseIf (RepairButton.hit or KeyHit(KEY_4)) And PlayersPlanet Then
			If credits > 1 And PlayersPlanet.hull < 25 Then
				credits -= 2
				PlayersPlanet.hull += 1
				If isSoundOn then game.sounds.Find("Build").Play()
				stats_shipsBuilt += 1
				FloatingText.Create("-" + (2) + "c", 0, 0, 255, 0, 0)
			End
		End
		
		timeMS = Millisecs() -timeMS - unittimeMS
		If timeMS > updateTotalMSHigh Then updateTotalMSHigh = timeMS
	End
End

Class FloatingText Extends FPoint
	Global currentText:List<FloatingText> = New List<FloatingText>()
	Global cacheText:List<FloatingText> = New List<FloatingText>()
	Field text:String, fade:Float = 1.0, r:Int, g:Int, b:Int
	
	Function Create:Void(txt:String, xx:Int, yy:Int, rr:Int, gg:Int, bb:Int)
		Local tmp:FloatingText = null
		If cacheText.Count() > 0	'cacheText.First() <> Null Then
			tmp = cacheText.RemoveFirst()
			tmp.text = txt
			tmp.x = xx
			tmp.y = yy
			tmp.r = rr
			tmp.g = gg
			tmp.b = bb
			tmp.fade = 1.0
		Else
			tmp = New FloatingText(txt, xx, yy, rr, gg, bb)
		End
		currentText.AddLast tmp
	End
	
	Function DrawAll:Void()
		For Local tC:FloatingText = eachin currentText
			tC.Draw()
		Next
	End
	
	Function UpdateAll:Void()
		For Local tC:FloatingText = eachin currentText
			tC.Update()
		Next
	End
	
	Method New(txt:String, xx:Int, yy:Int)
		text = txt
		x = xx
		y = yy
		r = 255
		g = 255
		b = 255
	End
	
	Method New(txt:String, xx:Int, yy:Int, rr:Int, gg:Int, bb:Int)
		text = txt
		x = xx
		y = yy
		r = rr
		g = gg
		b = bb
	End
	
	Method Update:Void()
		fade -= dt.delta * 0.01
		If fade < 0.0 Then
			fade = 0.0
			currentText.Remove Self
			cacheText.AddLast Self
		End
	End
	
	Method Draw:Void()
		If fade = 0.0 Then Return
		SetColor r, g, b
		DrawText(text, x, y, 0, (fade * -2.0) + 1)
		SetColor 255, 255, 255
	End
End