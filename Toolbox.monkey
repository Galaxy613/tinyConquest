Strict
Import Conquest

Class CustomScreen Extends Screen
	
End

Function StrToInt:Int(str:String)
	If str = "" Then str = "0" '' Android doesn't like blank strings...
	Return Int(str)
End

Function Distance:Float(x1:Float, y1:Float, x2:Float, y2:Float)
	Local dx:Float = x2 - x1
	Local dy:Float = y2 - y1
	Return Sqrt(dx * dx + dy * dy)
End

Function GetAngle:Float(x1:Float, y1:Float, x2:Float, y2:Float)
	Local dx:Float = x2 - x1
	Local dy:Float = y2 - y1
	Return ATan2(dy,dx)
End

Function GetAngleVector:Float(currentAngle:Float, targetAngle:Float, prefer:Float = 1.0)
	currentAngle = currentAngle Mod 360.0
	targetAngle = targetAngle Mod 360.0
	Local TargetDistance:Float = 0.0

	'' Test each possibility and find which has the shortest distance...
	Local d1:Float = Abs(currentAngle - targetAngle)
	Local d2:Float = Abs( (currentAngle + 360) - targetAngle)
	Local d3:Float = Abs(currentAngle - (targetAngle + 360))
	
	If d1 < d2 And d1 < d3 Then
		TargetDistance = (currentAngle-targetAngle)
	EndIf
	If d2 < d1 And d2 < d3 Then
		TargetDistance = ((currentAngle+360)-targetAngle)
	EndIf
	If d3 < d2 And d3 < d1 Then 
		TargetDistance = (currentAngle-(targetAngle+360))
	EndIf
	
	'' If the targetdistance is positive, then the current ang is too big.
	If TargetDistance > 0.0 Then Return -1.0
	'' If it's negative, we'll need to reach it.
	If TargetDistance < 0.0 Then Return 1.0
	
	Return prefer
End 

Function GetOrbit:Void(returnPoint:FPoint, angle:Float, dist:Float, tx:Float = 0, ty:Float = 0)
	returnPoint.x = tx+(Cos(angle)*dist)
	returnPoint.y = ty+(Sin(angle)*dist)
End

Class FPoint
' Public fields
	Field x:Float
	Field y:Float
	
' Constructors
	Method New(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End
End 

Class BasicButton Extends Rectangle
	Field text:String = "Blank", hit:Bool = false, drawHit:Bool = false, selected:Bool = false, active:Bool = true
	
	Method New(xx:Int, yy:Int, radius:Int, ttext:String = "Blank")
		x=xx
		y=yy
		w=radius
		text=ttext
	End
	
	Method Draw:Void()
		If Not active Then Return
		SetAlpha 0.15
		If Not empty Then SetAlpha 0.4
		If drawHit Then SetAlpha 0.5 ; drawHit = False
		DrawCircle(x,y,w)
		If selected Then DrawCircle(x,y,w+4)
		SetAlpha 0.9
		If text.Contains("~n") Then
			Local tmpStrAr := text.Split("~n")
			DrawText(tmpStrAr[0],x,y,0.5,1)
			DrawText(tmpStrAr[1],x,y,0.5,0)
		Else
			DrawText(text,x,y,0.5,0.5)
		End
		SetAlpha 1.0
	End
	
	Method Update:Void()
		If Not active Then Return
		empty = True
		hit = False
		If game.mouseX > x-w And game.mouseX < x+w And game.mouseY > y-w And game.mouseY < y+w Then
			empty = False
			If isMouseUp Then
				hit = True
				drawHit = True
			End
		End
	End
End