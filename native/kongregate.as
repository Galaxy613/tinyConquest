// Kongregate API Monkey runtime .as class
//
// Copyright 2012 Brad Davies (DPbrad).
// No warranty implied; use at your own risk.

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.system.Security;
import flash.net.URLRequest
import flash.events.Event

var kongObj:Kong

class Kong{

	internal var connection:*;
	
	public function KongInit():int
	{
		kongObj = this;
		var paramObj:Object = LoaderInfo(game.root.loaderInfo).parameters;
		var apiPath:String = paramObj.kongregate_api_path || "http://www.kongregate.com/flash/API_AS3_Local.swf";
		Security.allowDomain(apiPath);
		var request:URLRequest = new URLRequest(apiPath);
		var loader:Loader = new Loader();
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, kLC);
		loader.load(request);
		game.stage.addChild(loader);
		trace("Hello!");
		return 0
	}

	// This function is called when loading is complete
	private function kLC(event:Event):void
	{
		connection = event.target.content;
		connection.services.connect();
	}

	public function KongSubmitStat(stat:String,value:int):int
	{
		if (connection)
		{
			connection.stats.submit(stat,value);
		}
		return 0;
	}
	
	public function KongGetUsername():String
	{
		if (connection)
		{
			return connection.services.getUsername();
		}
		return "No-Connection";
	}
	
	public function KongIsGuest():Boolean
	{
		if (connection)
		{
			return connection.services.isGuest();
		}
		return true;
	}
	
	public function KongIsConnected():Boolean
	{
		return connection?true:false;
	}
	
	public function KongGetUserId():int
	{
		if (connection)
		{
			return connection.services.getUserId();
		}
		return 0;
	}
	
	public function KongPrivateMessage(pm:String):int
	{
		if(connection)
		{
			connection.services.privateMessage({content:pm});
		}
		return 0;
	}
	
	public function KongShowSignInBox():int
	{
		if (connection)
		{
			if(connection.services.isGuest()){
				connection.services.showSignInBox();
			}
		}
		return 0;
	}
	
	public function KongGetGameAuthToken():String
	{
		if (connection)
		{
			return connection.services.getGameAuthToken();
		}
		return "No-Connection";
	}
	
	public function KongShowRegisterBox():int
	{
		if (connection)
		{
			if(connection.services.isGuest()){
			  connection.services.showRegistrationBox();
			}
		}
		return 0;
	}
}