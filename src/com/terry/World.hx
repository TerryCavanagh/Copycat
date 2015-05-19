package com.terry;

import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import gamecontrol.Localworld;
import com.terry.*;
import com.terry.util.*;

class World {
	public static function init():Void {
		//Start here!
		mapwidth = 0; mapheight = 0;
		changecamera("normal");
		cameratransition = 0; cameratransitionpos = 0; oldcamerax = 0; oldcameray = 0;
		startscriptname = ""; startscript = false;
		camerax = 0; cameray = 0;
		camerapointmode = false; camerapointx = 0; camerapointy = 0;
		disablecamera = false;
		stage = ""; level = "";
		Tmap.init();
		
		//We init the lookup table:
		for (i in 0...100) {
			vmult.push(Std.int(i * 100));
		}
		//We create a blank map 
		for (j in 0...50) {
			for (i in 0...30) {
				contents.push(0);
				highlight.push(0);
				highlightcooldown.push(0);
				heatmap.push(0);
				laser.push(0);
				sword.push(0);
			}
		}
		
		for (j in 0...20) {
			for (i in 0...50) {
				worldmap.push(0);
				worldmapfog.push(0);
				worldmapseed.push(0);
			}
		}
		
		for (i in 0...2000) {
			collisionarray.push(0);
		}
		
		Localworld.initcollisionarray();
	}
	
	public static function sc(t:Int):Void { //Set collision
		collisionarray[t] = 1;
	}
	
	public static function changecamera(newmode:String):Void {
		cameramode = newmode;
	}
	
	public static var cameramode:String;
	
	public static function centercamera(xp:Int, yp:Int):Void {
		camerax = Std.int(xp - (Gfx.screenwidth / 2));
		cameray = Std.int(yp - (Gfx.screenheight / 2));
		if (camerax < 0) camerax = 0;
		if (cameray < 0) cameray = 0;
		if (camerax > (mapwidth - Gfx.screentilewidth) * Gfx.tiles[Gfx.currenttileset].width) camerax = ((mapwidth - Gfx.screentilewidth) * Gfx.tiles[Gfx.currenttileset].width) - 1;
		if (cameray > (mapheight - Gfx.screentileheight) * Gfx.tiles[Gfx.currenttileset].height) cameray = ((mapheight - Gfx.screentileheight) * Gfx.tiles[Gfx.currenttileset].height) - 1;
	}
	
	public static function cameracontrol():Void {
		switch(cameramode) {
			case "none", "disable":
				disablecamera = true;
			case "normal":
				disablecamera = false;
				var i:Int, j:Int;
				i = Obj.getplayer();
				
				if (camerapointmode || i < 0) {
					if (cameratransition > 0) {		
						temp = Std.int(oldcamerax + (Gfx.screenwidth / 2) - (((oldcamerax - ((camerapointx * Gfx.tiles[Gfx.currenttileset].height) -  (Gfx.screenwidth / 2))) * cameratransitionpos) / cameratransition));
						temp2 = Std.int(oldcameray + (Gfx.screenheight / 2) - (((oldcameray - ((camerapointy * Gfx.tiles[Gfx.currenttileset].height) -  (Gfx.screenheight / 2))) * cameratransitionpos) / cameratransition));
						centercamera(temp, temp2);
						cameratransitionpos++;
						if (cameratransitionpos >= cameratransition) {
							cameratransition = 0; cameratransitionpos = 0;
						}
					}else{
						centercamera(camerapointx*Gfx.tiles[Gfx.currenttileset].width, camerapointy*Gfx.tiles[Gfx.currenttileset].height);
					}
				}else{	
					if (cameratransition > 0) {		
						temp = Std.int(oldcamerax + (Gfx.screenwidth / 2) - (((oldcamerax - (Obj.entities[i].xp -  (Gfx.screenwidth / 2))) * cameratransitionpos) / cameratransition));
						temp2 = Std.int(oldcameray +  (Gfx.screenheight / 2) - (((oldcameray - (Obj.entities[i].yp -  (Gfx.screenheight / 2))) * cameratransitionpos) / cameratransition));
						centercamera(temp, temp2);
						cameratransitionpos++;
						if (cameratransitionpos >= cameratransition) {
							cameratransition = 0; cameratransitionpos = 0;
						}
					}else{
						centercamera(Std.int(Obj.entities[i].xp), Std.int(Obj.entities[i].yp));
					}
				}
		}
	}
	
	public static function changemapsize(x:Int, y:Int):Void {
		mapwidth = x; mapheight = y;
		for (i in 0...mapheight) {
			vmult[i] = i * mapwidth;
		}
	}
	
	public static function setrowcollision(t:Int):Void {
		for (i in 0...20) {
			collisionarray[(t * 20) + i] = 1;
		}
	}
	
	public static function collide(x:Int, y:Int):Bool {
		//which tiles are collidable?
		if (x < 0 || y < 0 || x >= mapwidth || y >= mapheight) return true;
		if (collisionarray[contents[x + vmult[y]]]==1) return true;
		return false;
	}
	
	private static var currentchar:String;
	private static var startindex:Int;
	private static var endindex:Int;
	
	public static function fillcontent():Void {
		var i:Int;
		var j:Int;
		var t:Int, xp:Int = 0, yp:Int = 0, w:Int = 0, h:Int = 0, trig:String = "null";
		var destx:Int = 0, desty:Int = 0, doorname:String = "";
		var type:String, para1:String, para2:String, para3:String;
		
		i = -3; j = 0; mapheight = 100;
		startindex = 0; endindex = 0;
		
		while (j < mapheight) {
			currentchar = levelstring.substr(endindex, 1);
			if (currentchar == ",") {
				if (i < 0) {
					if (i == -3) {
						mapwidth = Std.parseInt(levelstring.substr(startindex, endindex - startindex));
					}
					if (i == -2) { 
						mapheight = Std.parseInt(levelstring.substr(startindex, endindex - startindex));
						changemapsize(mapwidth, mapheight);
					}
					if (i == -1) { 
						tileset = levelstring.substr(startindex, endindex - startindex);
						Gfx.changetileset(tileset);
						//Set up the screentile width and height variables for map drawing
						Gfx.screentilewidth = Std.int(Gfx.screenwidth / Gfx.tiles[Gfx.currenttileset].width);
						Gfx.screentileheight = Std.int(Gfx.screenheight / Gfx.tiles[Gfx.currenttileset].height);
					}
				}else{
					contents[i + vmult[j]] = Std.parseInt(levelstring.substr(startindex, endindex - startindex));
				}
				endindex++;	startindex = endindex;
				i++;
				if (i >= mapwidth) { i = 0; j++; }
			}
			endindex++;
		}
		
		//Load blocks
		i = popint();
		while (i > 0) {
			t = popint(); xp = popint(); yp = popint(); w = popint(); h = popint();
			trig = popstring(); destx = popint(); desty = popint(); 
			doorname = popstring();
			Obj.createblock(t, xp, yp, w, h, trig, destx, desty, doorname);
			i--;
		}
		
		//Load entities
		Obj.ninitentities = 0;
		i = popint();
		while (i > 0) {
			xp = popint(); yp = popint(); type = popstring();
			para1 = popstring(); para2 = popstring(); para3 = popstring();
			Obj.createinitentity(xp, yp, type, para1, para2, para3);
			i--;
		}
		
		//Add entities based on init list
		for (i in 0...Obj.ninitentities) {
			Obj.initentities[i].entity = Obj.createentity(Obj.initentities[i].xp, 
																										Obj.initentities[i].yp, 
																										Obj.initentities[i].rule, 
																										Obj.initentities[i].para1, 
																										Obj.initentities[i].para2, 
																										Obj.initentities[i].para3);
		}
	}
	
	public static function popint():Int {
		var t:Int;
		//Return the next int from the levelstring
		while (endindex < levelstring.length) {
			currentchar = levelstring.substr(endindex, 1);
			if (currentchar == ",") {
				t = Std.parseInt(levelstring.substr(startindex, endindex - startindex));
				endindex++;	startindex = endindex;
				return t;
			}
			endindex++;
		}
		
		//Didn't find anything
		return 0;
	}
	
	public static function popstring():String {
		var t:String;
		//Return the next int from the levelstring
		while (endindex < levelstring.length) {
			currentchar = levelstring.substr(endindex, 1);
			if (currentchar == ",") {
				t = Std.string(levelstring.substr(startindex, endindex - startindex));
				endindex++;	startindex = endindex;
				return t;
			}
			endindex++;
		}
		
		//Didn't find anything
		return "null";
	}
	
	public static function placetile(xp:Int, yp:Int, t:Int):Void {
		if (Help.inboxw(xp, yp, 0, 0, mapwidth, mapheight)) {
			contents[xp + vmult[yp]] = t;
		}
	}
	
	public static function at(xp:Int, yp:Int, xoff:Int = 0, yoff:Int = 0):Int {
		xp = xp * Gfx.tiles[Gfx.currenttileset].width;
		xp += xoff;
		xoff = xp % Gfx.tiles[Gfx.currenttileset].width;
		xp = Std.int((xp - xoff) / Gfx.tiles[Gfx.currenttileset].width);
		
		yp = yp * Gfx.tiles[Gfx.currenttileset].height;
		yp += yoff;
		yoff = yp % Gfx.tiles[Gfx.currenttileset].height;
		yp = Std.int((yp - yoff) / Gfx.tiles[Gfx.currenttileset].height);
		
		/* 
		if (yp == -1) return at(xp, yp + 1, xoff, yoff);
		if (yp == mapheight) return at(xp, yp - 1, xoff, yoff);
		if (xp == -1) return at(xp + 1, yp, xoff, yoff);
		if (xp == mapwidth) return at(xp - 1, yp, xoff, yoff);
		*/
		if (xp >= 0 && yp >= 0 && xp < mapwidth && yp < mapheight) {
			return contents[xp+vmult[yp]];
		}
		return 0;
	}
	
	public static function change(t:String):Void {
		var s:String = Help.getroot(t, "_");
		t = Help.getbranch(t, "_");
		
		Obj.removeallblocks();
		
		for (i in 0...Obj.nentity) {
			//Of course the player's always gonna be object zero, this is just in case
			if (Obj.entities[i].rule != "player") Obj.entities[i].active = false;
		}
		Obj.cleanup();
		
		var i:Int = Obj.getplayer();
		Obj.entities[i].xp = Obj.doortox * Gfx.tiles[Gfx.currenttileset].width;
		Obj.entities[i].yp = Obj.doortoy * Gfx.tiles[Gfx.currenttileset].height;
		Obj.entities[i].vx = 0;
		Obj.entities[i].vy = 0;
		
		Localworld.loadlevel(s, t);
	}
	
	public static function loadmapfromstring(s:String, t:String, givenlevelstring:String):Void {
		if (s != stage) stage = s;
		if (t != level) level = t;
		
		levelstring = givenlevelstring;
		fillcontent();
	}
	
	public static function loadmap(stagename:String, levelname:String):Bool {
		#if !(flash || html5)
		
		return false;
		#else
		//Can't load external files in flash
		return false;
		#end
	}
	
	public static function clearmap():Void {
		for (j in 0...mapheight) {
			for (i in 0...mapwidth) {
				contents[i + vmult[j]] = 1;
			}
		}
	}
	
	public static var collisionarray:Array<Int> = new Array<Int>();
	public static var contents:Array<Int> = new Array<Int>();
	public static var highlight:Array<Int> = new Array<Int>();
	public static var highlightcooldown:Array<Int> = new Array<Int>();
	public static var heatmap:Array<Int> = new Array<Int>();
	public static var laser:Array<Int> = new Array<Int>();
	public static var sword:Array<Int> = new Array<Int>();
	public static var vmult:Array<Int> = new Array<Int>();
	
	public static var worldmap:Array<Int> = new Array<Int>();
	public static var worldmapfog:Array<Int> = new Array<Int>();
	public static var worldmapseed:Array<Int> = new Array<Int>();
	
	public static var temp:Int; 
	public static var temp2:Int;
	public static var tempstring:String;
	public static var background:Int;
	public static var mapwidth:Int;
	public static var mapheight:Int;
	public static var noxcam:Bool;
	public static var noycam:Bool;
	
	public static var tileset:String;
	
	//Camera
	public static var camerax:Int;
	public static var cameray:Int; 
	public static var oldcamerax:Int;
	public static var oldcameray:Int;
	public static var cameratransition:Int;
	public static var cameratransitionpos:Int;
	public static var camerapointmode:Bool; 
	public static var camerapointx:Int; 
	public static var camerapointy:Int;
	public static var disablecamera:Bool;
	
	//External scripting control
	public static var startscriptname:String;
	public static var startscript:Bool;
	
	//Levels
	public static var filename:String = "";
	public static var stage:String = "";
	public static var level:String = "";
	public static var levelstring:String;
}