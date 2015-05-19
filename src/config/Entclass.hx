package config;

import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import com.terry.*;

class Entclass {
	public function new() {
		for (i in 0 ... 20){
			possibleactions.push("");
		}
		
		clear();
	}
	
	public function clear():Void {
		//Set all values to a default, required for creating a new entity
		active = false; invis = false;
		tile = 0; rule = "null";
		type = "null";  
		name = "null"; stringpara = "null";
		state = 0; statedelay = 0; life = 0; para = 0;
		behave = 0; animate = 0;
		
		xp = 0; yp = 0; ax = 0; ay = 0; vx = 0; vy = 0;
		w = 0; h = 0; cx = 0; cy = 0;
		newxp = 0; newyp = 0;
		
		col = 0xFFFFFF;
		
		transx = 0; transy = 0;	rot = 0;
		
		x1 = 0; y1 = 0; x2 = Gfx.screenwidth; y2 = Gfx.screenheight;
		
		jumping = false; gravity = false; onground = 0; onroof = 0; jumpframe = 0;
		
		onentity = 0; onwall = 0; onxwall = 0; onywall = 0;
		
		framedelay = 0; drawframe = 0; walkingframe = 0; dir = 0; actionframe = 0;
		speed = 0;
		health = 3;
		
		canturn = true;
		canattack = true;
		alertbysound = true;
		
		tileset = "sprites";
		checkcollision = false;
		lightsource = "none";
		
		action = "nothing"; actionset = false; ai = "random";
		numpossibleactions = 0;
		inchain = false;
		stunned = 0;
		alerted_thisframe = false;
		
		userevertdir = false;
		revertdir = 0;
		rotatedir = Help.NODIRECTION;
		
		message = "";
		messagecol = "";
		messagedelay = 0;
		collidable = true;
		
		fireproof = false;
	}
	
	public function setmessage(_message, _messagecol = "white", _messagedelay = 120):Void {
		//if (messagedelay <= 0) {
			message = " " + _message + " ";
			messagecol = _messagecol;
			messagedelay = _messagedelay;
		//}
	}
	
	public function resetactions():Void {
		actionset = false;
		numpossibleactions = 0;
	}
	
	public function addaction(t:String):Void {
		possibleactions[numpossibleactions] = t;
		numpossibleactions++;
	}
	
	public function removeaction(t:String):Void {
		for (i in 0 ... numpossibleactions) {
			if (t == possibleactions[i]) _removeaction(i);
		}
	}
	
	public function _removeaction(j:Int):Void {
		for (i in j ... numpossibleactions) {
			possibleactions[i] = possibleactions[i + 1];
		}
		numpossibleactions--;
	}
	
	//Fundamentals
	public var alerted_thisframe:Bool;
	public var action:String;
	public var actionset:Bool;
	public var possibleactions:Array<String> = new Array<String>();
	public var numpossibleactions:Int;
	public var inchain:Bool;
	public var ai:String;
	public var lightsource:String;
	public var speed:Int;
	public var health:Int;
	public var canturn:Bool;
	public var canattack:Bool;
	public var alertbysound:Bool;
	public var fireproof:Bool;
	
	public var userevertdir:Bool;
	public var revertdir:Int;
	public var stunned:Int;
	
	public var active:Bool;
	public var invis:Bool;
	public var type:String;
	public var tile:Int;
	public var rule:String;
	public var state:Int;
	public var statedelay:Int;
	public var behave:Int;
	public var animate:Int;
	public var para:Int;
	public var life:Int;
	public var name:String;
	public var stringpara:String;
	public var tileset:String;
	public var checkcollision:Bool;
	public var col:Int;
	public var target:Int;
	public var collidable:Bool;
	public var rotatedir:Int;
	
	public var message:String;
	public var messagedelay:Int;
	public var messagecol:String;
	//Position and velocity
	public var xp:Int;
	public var yp:Int;
	public var oldxp:Int;
	public var oldyp:Int;
	public var ax:Int;
	public var ay:Int;
	public var vx:Int;
	public var vy:Int;
	public var cx:Int;
	public var cy:Int;
	public var w:Int;
	public var h:Int;
	public var newxp:Int;
	public var newyp:Int; //For collision functions
	public var x1:Int;
	public var y1:Int;
	public var x2:Int;
	public var y2:Int;
	public var rot:Float;
	public var transx:Int;
	public var transy:Int;
	//Collision Rules
	public var onentity:Int;
	public var onwall:Int;
	public var onxwall:Int;
	public var onywall:Int;
	
	//Platforming specific
	public var jumping:Bool;
	public var gravity:Bool;
	public var onground:Int;
	public var onroof:Int;
	public var jumpframe:Int;
	//Animation
	public var framedelay:Int;
	public var drawframe:Int;
	public var walkingframe:Int;
	public var dir:Int;
	public var actionframe:Int;
}
