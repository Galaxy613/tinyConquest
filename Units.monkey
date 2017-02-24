Strict
Import Conquest

'---------------------------------------------------------------------------
Class CObject Extends FPoint ' Abstract?
	Field Waypoint:CObject = Null
	Field Target:CObject = Null, tAngle# = 0.0
	Field angle# = 0.0, angleTarget# = 0.0, speed# = 1.0, team% = 0
	Field lastShotMS% = 0, lastHealMS% = 0, hull% = 1, preferedDirection#= 1.0
	Field rangeTarget% = 150, rangeAttack% = 100
	
	Field image:GameImage
	
	Method Draw:Void()
		SetColorFromTeam team
		if image then image.Draw(x,y,-angle)
		SetColor 255,255,255
	End
	
	Method Update:Void()
		angle += speed * GetAngleVector(angle,angleTarget,preferedDirection)
		
		if angle > 360 Then angle -= 360.0
		if angle < 0 Then angle += 360.0
	End
	
	Method UpdateTarget:Bool(possibleTarget:CObject) '' Return True to stop the loop
		Return True
	End
	
	Method UpdateTargetCombat:Bool(obj:CObject) '' Return True to stop the loop
		If Target <> Null Then Return True
		
		If obj.team <> team And obj.team > 0 Then
			If obj.DistanceFrom(Self) < rangeTarget Then
				Target = obj
				lastShotMS = Millisecs()
			End
		End
		
		Return False
	End
	
	Method FollowTargetAndWaypoint:Void()
		angleTarget = 0
		if Target = Null Then
			if Waypoint Then
				angleTarget = GetAngle(x,y,Waypoint.x,Waypoint.y)
			Else
				angleTarget = GetAngle(x,y,0,0)
			End
		Else
			angleTarget = GetAngle(x,y,Target.x,Target.y)
		End
		If angleTarget < 0 Then angleTarget += 360
	End
	
	Method AttackTarget:Void()
		If Target then
			If Target.hull < 1 Then
				Target = null
			ElseIf Millisecs() > lastShotMS+500
				Local TargetDist:Float = Target.DistanceFrom(Self)
				If TargetDist > rangeTarget Then
					Target = null
				'	Waypoint = Null
				ElseIf TargetDist < rangeAttack And angle-2.5 < angleTarget And angle+2.5 > angleTarget
					'' LASER BEAM
					If Lazor.LazorList then Lazor.LazorList.AddLast(New Lazor(x,y,Target.x,Target.y,255*(team=1),255*(team=2),255*(team*3)))
					Target.hull -= 1
					lastShotMS = Millisecs()
					If isSoundOn then game.sounds.Find("Shoot_Fast").Play()
				End
			End
		End
	End
	
	Method DistanceFrom:Float(Other:CObject)
		Return Distance(x,y,Other.x,Other.y)
	End
	
	Function SetColorFromTeam:Void(teamNum%)
		Select teamNum
			Case -1
				SetColor 255,255,255
			Case 1
				SetColor 100,100,255
			Case 2
				SetColor 255,100,100
			Case 3
				SetColor 100,255,100
			Default
				SetColor 192,192,192
		End
	End
End

'---------------------------------------------------------------------------
Class Fighter Extends CObject

	Method New()
		image = game.images.Find("fighter")
		angle = Rnd(0,360)
		speed = Rnd(1.4,1.6)
		hull = 3
		preferedDirection = Int(Rnd(3))
		if preferedDirection <> 1.0 Then preferedDirection = -1.0
	End
	
	Method Draw:Void()
		Super.Draw()
		If Target Then
			SetAlpha 0.1
			DrawLine x,y,Target.x,Target.y
			SetAlpha 1.0
		End
		If Waypoint Then
			SetAlpha 0.05
			DrawLine x,y,Waypoint.x,Waypoint.y
			SetAlpha 1.0
		End
	'	DrawText Int(angle)+" - "+Int(GetAngle(x,y,0,0)),x,y+16
	'	DrawText Int(angleTarget),x,y+32
	End
	
	Method Update:Void()
		FollowTargetAndWaypoint()
		
		If lastHealMS < Millisecs() Then
			if hull < 3 Then hull += 1
			lastHealMS = Millisecs()  + 1500
		End
		
		Super.Update()
		AttackTarget()
		
		GetOrbit(Self, angle,(speed/2.0),x,y)'' Hacky way of moving the ship forward xD
	End
	
	Method UpdateTarget:Bool(obj:CObject) '' Return True to stop the loop
		Return UpdateTargetCombat(obj)
	End
	
End

'---------------------------------------------------------------------------
Class Destroyer Extends CObject

	Method New()
		image = game.images.Find("destroyer")
		angle = Rnd(0,360)
		speed = Rnd(0.4,0.6)
		hull = 15
		preferedDirection = Int(Rnd(3))
		if preferedDirection <> 1.0 Then preferedDirection = -1.0
	End
	
	Method Draw:Void()
		Super.Draw()
		If Target Then
			SetAlpha 0.1
			DrawLine x,y,Target.x,Target.y
			SetAlpha 1.0
		End
		If Waypoint Then
			SetAlpha 0.05
			DrawLine x,y,Waypoint.x,Waypoint.y
			SetAlpha 1.0
		End
	'	DrawText Int(angle)+" - "+Int(GetAngle(x,y,0,0)),x,y+16
	'	DrawText Int(angleTarget),x,y+32
	End
	
	Method Update:Void()
		FollowTargetAndWaypoint()
		
		Super.Update()
		AttackTarget()
		
		GetOrbit(Self, angle,(speed/2.0),x,y)'' Hacky way of moving the ship forward xD
	End
	
	Method UpdateTarget:Bool(obj:CObject) '' Return True to stop the loop
		Return UpdateTargetCombat(obj)
	End
	
End

'---------------------------------------------------------------------------
Class Turret Extends CObject
	Field parent:CObject = Null
	Field offset:FPoint = Null
	
	Method New()
		image = game.images.Find("turret")
		angle = Rnd(0,360)
		speed = 1.25
		hull = 5
		rangeAttack = 115
		preferedDirection = Int(Rnd(3))
		if preferedDirection <> 1.0 Then preferedDirection = -1.0
	End
	
	Method Attach:Void(obj:CObject, angle#, dist#)
		parent = obj
		offset = New FPoint(angle,dist)
		team = obj.team
	End
		
	Method Update:Void()
		If parent Then
			speed = 3
			GetOrbit(Self, parent.angle+offset.x, offset.y,parent.x,parent.y)
			
			If parent.hull < 1 Then
				parent = null ; speed = 1.25
			End
		End
		
		If Target then
			angleTarget = GetAngle(x,y,Target.x,Target.y)
		ElseIf parent
			angleTarget = parent.angle
		Else
			angleTarget = GetAngle(x,y,0,0)+180
		End
		If angleTarget > 360 Then angleTarget -= 360
		If angleTarget < 360 Then angleTarget += 360
		Super.Update()
		
		AttackTarget()
	End
	
	Method UpdateTarget:Bool(obj:CObject) '' Return True to stop the loop
		Return UpdateTargetCombat(obj)
	End
	
	Method AttackTarget:Void()
		If Target then
			If Target.hull < 1 Then
				Target = null
			ElseIf Millisecs() > lastShotMS+500
				Local TargetDist# = Target.DistanceFrom(Self)
				If TargetDist > rangeTarget Then
					Target = null
					Waypoint = Null
				ElseIf TargetDist < rangeAttack And angle-2.5 < angleTarget And angle+2.5 > angleTarget
					'' LASER BEAM
					If Lazor.LazorList then
						Lazor.LazorList.AddLast(New Lazor(x,y,Target.x+4,Target.y,255*(team=1),255*(team=2),255*(team*3)))
						Lazor.LazorList.AddLast(New Lazor(x,y,Target.x,Target.y+4,255*(team=1),255*(team=2),255*(team*3)))
						Lazor.LazorList.AddLast(New Lazor(x,y,Target.x-4,Target.y,255*(team=1),255*(team=2),255*(team*3)))
						Lazor.LazorList.AddLast(New Lazor(x,y,Target.x,Target.y-4,255*(team=1),255*(team=2),255*(team*3)))
					End
					Target.hull -= 2
					lastShotMS = Millisecs()
					If isSoundOn then game.sounds.Find("Shoot_Slow").Play()
				End
			End
		End
	End
End

'---------------------------------------------------------------------------
Class Asteroid Extends CObject
	Method New()
		image = game.images.Find("asteroid")
		angle = Rnd(0,360)
		hull = 30
	End
	
	Method Update:Void()
		angle += dt.delta
		if angle > 360 Then angle -= 360.0
	End
End

'---------------------------------------------------------------------------
Class LargeAsteroid Extends CObject
	Method New()
		image = game.images.Find("large_asteroid")
		angle = Rnd(0,360)
		hull = 50
	End
	
	Method Update:Void()
		angle += dt.delta*0.5
		if angle > 360 Then angle -= 360.0
	End
End

Class Planet Extends CObject
	Method New()
		image = game.images.Find("planet")
		angle = Rnd(0,360)
		hull = 25
		rangeTarget = 100
		rangeAttack = 75
	End
	
	Method Draw:Void()
		if image then image.Draw(x,y,-angle)
		If Target Then
			SetAlpha 0.1
			DrawLine x,y,Target.x,Target.y
			SetAlpha 1.0
		End
		If Waypoint Then
			SetAlpha 0.05
			DrawLine x,y,Waypoint.x,Waypoint.y
			SetAlpha 1.0
		End
	'	DrawText Int(angle)+" - "+Int(GetAngle(x,y,0,0)),x,y+16
	'	DrawText Int(angleTarget),x,y+32
	End
	
	Method Update:Void()
		angle += dt.delta*0.15
		if angle > 360 Then angle -= 360.0
		
		If Target then
			If Target.hull < 1 Then
				Target = null
			ElseIf Millisecs() > lastShotMS+600
				Local TargetDist# = Target.DistanceFrom(Self)
				If TargetDist > rangeTarget Then
					Target = null
				Else'If TargetDist < rangeAttack And angle-2.5 < angleTarget And angle+2.5 > angleTarget
					'' LASER BEAM
					If Lazor.LazorList then
						Lazor.LazorList.AddLast(New Lazor(x+1,y,Target.x+5,Target.y,255*(team=1),255*(team=2),255*(team*3)))
						Lazor.LazorList.AddLast(New Lazor(x,y+1,Target.x,Target.y+5,255*(team=1),255*(team=2),255*(team*3)))
						Lazor.LazorList.AddLast(New Lazor(x-1,y,Target.x-5,Target.y,255*(team=1),255*(team=2),255*(team*3)))
						Lazor.LazorList.AddLast(New Lazor(x,y-1,Target.x,Target.y-5,255*(team=1),255*(team=2),255*(team*3)))
						Lazor.LazorList.AddLast(New Lazor(x,y,Target.x,Target.y,255*(team=1),255*(team=2),255*(team*3)))
					End
					Target.hull -= 3
					lastShotMS = Millisecs()
					If isSoundOn then game.sounds.Find("Shoot_Slow").Play()
				End
			End
		End
	End
	
	Method UpdateTarget:Bool(obj:CObject) '' Return True to stop the loop
		If Target <> Null Then Return True
		
		If obj.team <> team And obj.team > 0 Then
			If obj.DistanceFrom(Self) < rangeTarget Then
				Target = obj
				lastShotMS = Millisecs()
			End
		End
		
		Return False
	End
End

'---------------------------------------------------------------------------
Global WaypointCurrent:WaypointNode = Null
Class WaypointNode Extends CObject
	Field pulse#=1.0, name$="Waypoint"
	
	Method Draw:Void()
		SetAlpha 0.1
		DrawCircle(x,y,pulse*50.0)
		If WaypointCurrent = Self Then
			SetAlpha 0.15
			DrawCircle(x,y, 40.0)
		End
		if RealMouseX > x-40 And RealMouseX < x+40 And RealMouseY > y-40 And RealMouseY < y+40
			SetAlpha 0.05
			DrawCircle(x,y, 37.5)
			SetAlpha 0.75
			DrawText("Select",x,y,0.5,1)
			DrawText(name,x,y,0.5,0)
			SetAlpha 1.0	
		Else
			SetAlpha 0.5
			DrawText(name,x,y,0.5,0.5)
			SetAlpha 1.0		
		End
	End
	
	Method Update:Void()
		pulse += 0.01
		if pulse > 1.0 Then pulse = 0.0
		
		If isMouseUp And RealMouseX > x-40 And RealMouseX < x+40 And RealMouseY > y-40 And RealMouseY < y+40
			WaypointCurrent = Self
		End
	End
	
End

'---------------------------------------------------------------------------
Class Lazor
	Global LazorList:List<Lazor> = Null
	
	Field p1:FPoint = Null
	Field p2:FPoint = Null
	Field r%=255,g%=255,b%=255
	Field opacity# = 1.0
	
	Method New(x1%,y1%,x2%,y2%,rr%=255,gg%=255,bb%=255,oopacity#=1.0)
		p1 = New FPoint(x1,y1)
		p2 = New FPoint(x2,y2)
		r=rr
		g=gg
		b=bb
		opacity = oopacity
	End
	
	Method Draw:Void()
		If opacity > 1.0 Then Return
		SetAlpha opacity
		SetColor r,g,b
		DrawLine p1.x,p1.y,p2.x,p2.y
		SetColor 255,255,255
		SetAlpha 1.0
	End
	
	Method Update:Void()
		opacity -= 0.025
		if opacity < 0 Then opacity = 0.0
	End
End