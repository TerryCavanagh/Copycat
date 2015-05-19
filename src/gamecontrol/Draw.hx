package gamecontrol;

import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import com.terry.*;

class Draw {
	public static function init():Void {
		
	}
	
	public static function gfxflashlight():Void {
		Gfx.backbuffer.fillRect(Gfx.backbuffer.rect, 0xFFFFFF);
	}
	
	public static function gfxscreenshake():Void {
		Gfx.screenbuffer.lock();
		Gfx.screenbuffer.copyPixels(Gfx.backbuffer, Gfx.backbuffer.rect, Gfx.tl, null, null, false);
		Gfx.settpoint(Std.int((Math.random() * 5) - 3), Std.int((Math.random() * 5) - 3));
		Gfx.screenbuffer.copyPixels(Gfx.backbuffer, Gfx.backbuffer.rect, Gfx.tpoint, null, null, false);
		Gfx.screenbuffer.unlock();
		
		Gfx.backbuffer.lock();
		Gfx.backbuffer.fillRect(Gfx.backbuffer.rect, 0x000000);
		Gfx.backbuffer.unlock();
	}
	
	public static function getperlin(x:Int, y:Int):Int {
		x = x % Gfx.images[perlinnoise].width;
		y = y % Gfx.images[perlinnoise].height;
		return Gfx.getred(Gfx.images[perlinnoise].getPixel(x, y));
	}
	
	public static function clicktostart():Void {
		Text.changesize(8);
		Text.print(Text.CENTER, 115, "[Click to start]", Gfx.RGB(Std.int(255 - (Help.glow / 2)), Std.int(255 - (Help.glow / 2)), Std.int(255 - (Help.glow / 2))));
	}

	public static function outoffocusrender():Void {
		Gfx.fillrect(0, 100, 384, 38, 0, 0, 0);
		Gfx.fillrect(0, 228, 384, 12, 0, 0, 0);
		
		Text.changesize(16);
		Text.print(Text.CENTER, 99, "Game paused", Gfx.RGB(Std.int(255 - (Help.glow / 2)), Std.int(255 - (Help.glow / 2)), Std.int(255 - (Help.glow / 2))));
		
		Text.changesize(8);
		Text.print(Text.CENTER, 122, "[click to resume]", Gfx.RGB(Std.int(196 - (Help.glow / 2)), Std.int(196 - (Help.glow / 2)), Std.int(196 - (Help.glow / 2))));
		Text.print(Text.CENTER, 227, "Press M to mute", Gfx.RGB(Std.int(255 - (Help.glow / 2)), Std.int(255 - (Help.glow / 2)), Std.int(255 - (Help.glow / 2))));
		
		Gfx.normalrender();
	}
	
	public static function drawfade():Void {
		if (Gfx.fademode == Gfx.FADED_OUT) {
			Gfx.backbuffer.fillRect(Gfx.backbuffer.rect, 0x000000);
		}else if (Gfx.fademode == Gfx.FADING_OUT) {
			Gfx.fillrect(0, 0, Std.int((Gfx.fadeamount * (Gfx.screenwidth / 20)) / 10), Gfx.screenheight, 0, 0, 0);
			Gfx.fillrect(Std.int(Gfx.screenwidth - ((Gfx.fadeamount * (Gfx.screenwidth / 20)) / 10)), 0, Gfx.screenwidthmid, Gfx.screenheight, 0, 0, 0);
			Gfx.fillrect(0, 0, Gfx.screenwidth, Std.int((Gfx.fadeamount * (Gfx.screenheight / 20)) / 10), 0, 0, 0);
			Gfx.fillrect(0, Std.int(Gfx.screenheight - ((Gfx.fadeamount * (Gfx.screenheight / 20)) / 10)), Gfx.screenwidth,  Gfx.screenheightmid, 0, 0, 0);
		}else if (Gfx.fademode == Gfx.FADING_IN) {
			Gfx.fillrect(0, 0, Std.int((Gfx.fadeamount * (Gfx.screenwidth / 20)) / 10), Gfx.screenheight, 0, 0, 0);
			Gfx.fillrect(Std.int(Gfx.screenwidth - ((Gfx.fadeamount * (Gfx.screenwidth / 20)) / 10)), 0, Gfx.screenwidthmid, Gfx.screenheight, 0, 0, 0);
			Gfx.fillrect(0, 0, Gfx.screenwidth, Std.int((Gfx.fadeamount * (Gfx.screenheight / 20)) / 10), 0, 0, 0);
			Gfx.fillrect(0, Std.int(Gfx.screenheight - ((Gfx.fadeamount * (Gfx.screenheight / 20)) / 10)), Gfx.screenwidth, Gfx.screenheightmid, 0, 0, 0);
		}
	}
	
	public static function textboxcol(type:Int, shade:Int):Int {
		//Color lookup function for textboxes
		switch(type) {
			case 0: //White textbox
				switch(shade) {
					case 0: return Gfx.RGB(0, 0, 0);
					case 1: return Gfx.RGB(64, 64, 64);
					case 2: return Gfx.RGB(192, 192, 192);
				}
			case 1: //Red textbox
				switch(shade) {
					case 0: return Gfx.RGB(0, 0, 0);
					case 1: return Gfx.RGB(65, 3, 19);
					case 2: return Gfx.RGB(255, 31, 41);
				}
			case 2: //Green textbox
				switch(shade) {
					case 0: return Gfx.RGB(0, 0, 0);
					case 1: return Gfx.RGB(3, 65, 5);
					case 2: return Gfx.RGB(31, 255, 84);
				}
			case 3: //Blue textbox
				switch(shade) {
					case 0: return Gfx.RGB(0, 0, 0);
					case 1: return Gfx.RGB(3, 37, 65);
					case 2: return Gfx.RGB(31, 105, 255);
				}
		}
		return Gfx.RGB(0, 0, 0);
	}
	
	public static function drawparticles():Void {			
		for (i in 0...Obj.nparticles) {
			if (Obj.particles[i].active) {
				if (Obj.particles[i].type == "pixel") {
					Gfx.settrect(Std.int(Obj.particles[i].xp - World.camerax), Std.int(Obj.particles[i].yp - World.cameray), 5, 5);
					Gfx.backbuffer.fillRect(Gfx.trect, Gfx.RGB(255, 255, 255));
				}else if (Obj.particles[i].type == "rpgtext") {
					//White text
					Text.print(Std.int(Obj.particles[i].xp - World.camerax), Std.int(Obj.particles[i].yp - World.cameray), 
										 Std.string(Obj.particles[i].colour), Gfx.RGB(255, 255, 255));
				}else {
					Gfx.changetileset(Obj.particles[i].type);
					Gfx.drawtile(Std.int(Obj.particles[i].xp - World.camerax), Std.int(Obj.particles[i].yp - World.cameray), Obj.particles[i].tile);
				}
			}
		}
	}
	
	public static function drawmap(tileset:String):Void {
		Gfx.changetileset(tileset);
		
		if (World.disablecamera) {
			World.camerax = 0; World.cameray = 0;
		}else{
			if (World.noxcam) World.camerax = 0; if (World.noycam) World.cameray = 0;
		}
		
		if (Obj.getplayer() > -1) {
			World.camerax = Obj.entities[Obj.getplayer()].xp - 24;
			if (World.camerax < 0) World.camerax = 0;
			if (World.camerax + 24 > World.mapwidth) World.camerax = World.mapwidth - 24;
			
			World.cameray = Obj.entities[Obj.getplayer()].yp - 5;
			if (World.cameray < 0) World.cameray = 0;
			if (World.cameray + 10 > World.mapheight) World.cameray = World.mapheight - 10;
		}
		World.cameray = 0;
		var t:Int;
		
		for (j in World.cameray ... Gfx.screentileheight + 1 + World.cameray) {
			for (i in World.camerax ... Gfx.screentilewidth + 1 + World.camerax) {
				t = World.at(i, j);// , World.camerax, World.cameray);
				if (t > 0) {
					Gfx.fillrect((i * Gfx.tiles[Gfx.currenttileset].width) - (World.camerax * Gfx.tiles[Gfx.currenttileset].width), (j * Gfx.tiles[Gfx.currenttileset].height) - (World.cameray * Gfx.tiles[Gfx.currenttileset].height), Gfx.tiles[Gfx.currenttileset].width, Gfx.tiles[Gfx.currenttileset].height, Localworld.backcolourmap(i, j, t));
					Gfx.drawtile_col((i * Gfx.tiles[Gfx.currenttileset].width) - (World.camerax * Gfx.tiles[Gfx.currenttileset].width), (j * Gfx.tiles[Gfx.currenttileset].height) - (World.cameray * Gfx.tiles[Gfx.currenttileset].height), Localworld.charmap(i, j, t), Localworld.colourmap(i, j, t));
				}
			}
		}
	}
	
	public static function enemycol(t:String):Int {
		switch(t) {
			case "swordguy":
				return glowcol(0xFF4444);
			case "bombguy":
				return glowcol(0x4444FF);
			case "builderguy":
				return glowcol(0xFF44FF);
			case "gunguy":
				return glowcol(0xFFFF44);
			case "snakeguy":
				return glowcol(0x44FF44);
			case "runnerguy":
				return glowcol(messagecol("rainbow"));
		}
		return glowcol(messagecol("flashing"));
	}
	
	public static var tr:Int;
	public static var tg:Int;
	public static var tb:Int;
	public static function glowcol(t:Int):Int {
		tr = Gfx.getred(t);
		tg = Gfx.getgreen(t);
		tb = Gfx.getblue(t);
		
		tr = tr - Help.glow;
		tg = tg - Help.glow;
		tb = tb - Help.glow;
		
		if (tr < 0) tr = 0;
		if (tg < 0) tg = 0;
		if (tb < 0) tb = 0;
		
		return Gfx.RGB(tr, tg, tb);
	}
	
	public static function drawqueue():Void {
		for (i in 0 ... Game.enemyqueuesize) {
			if (Game.enemyqueue[i].dir == "right") {
				Gfx.fillrect(Game.enemyqueue[i].x * Gfx.tiles[Gfx.currenttileset].width, 
										 Game.enemyqueue[i].y * Gfx.tiles[Gfx.currenttileset].height,
										 2, Gfx.tiles[Gfx.currenttileset].height, enemycol(Game.enemyqueue[i].type));
				Gfx.fillrect(Game.enemyqueue[i].x * Gfx.tiles[Gfx.currenttileset].width, 
										 Game.enemyqueue[i].y * Gfx.tiles[Gfx.currenttileset].height,
										 4, 2, enemycol(Game.enemyqueue[i].type));
			  Gfx.fillrect(Game.enemyqueue[i].x * Gfx.tiles[Gfx.currenttileset].width, 
										 (Game.enemyqueue[i].y +1) * Gfx.tiles[Gfx.currenttileset].height - 2,
										 4, 2, enemycol(Game.enemyqueue[i].type));
			}else if (Game.enemyqueue[i].dir == "left") {
				Gfx.fillrect(((Game.enemyqueue[i].x+1) * Gfx.tiles[Gfx.currenttileset].width)-2, 
										 Game.enemyqueue[i].y * Gfx.tiles[Gfx.currenttileset].height,
										 2, Gfx.tiles[Gfx.currenttileset].height, enemycol(Game.enemyqueue[i].type));
				Gfx.fillrect(((Game.enemyqueue[i].x+1) * Gfx.tiles[Gfx.currenttileset].width)-4, 
										 Game.enemyqueue[i].y * Gfx.tiles[Gfx.currenttileset].height,
										 4, 2, enemycol(Game.enemyqueue[i].type));
			  Gfx.fillrect(((Game.enemyqueue[i].x+1) * Gfx.tiles[Gfx.currenttileset].width)-4, 
										 (Game.enemyqueue[i].y +1) * Gfx.tiles[Gfx.currenttileset].height - 2,
										 4, 2, enemycol(Game.enemyqueue[i].type));
			}else if (Game.enemyqueue[i].dir == "down") {
				Gfx.fillrect(Game.enemyqueue[i].x * Gfx.tiles[Gfx.currenttileset].width, 
										 Game.enemyqueue[i].y * Gfx.tiles[Gfx.currenttileset].height,
										 Gfx.tiles[Gfx.currenttileset].width, 2, enemycol(Game.enemyqueue[i].type));
				Gfx.fillrect(Game.enemyqueue[i].x * Gfx.tiles[Gfx.currenttileset].width, 
										 Game.enemyqueue[i].y * Gfx.tiles[Gfx.currenttileset].height,
										 2, 4, enemycol(Game.enemyqueue[i].type));
				Gfx.fillrect(((Game.enemyqueue[i].x+1) * Gfx.tiles[Gfx.currenttileset].width)-2, 
										 Game.enemyqueue[i].y * Gfx.tiles[Gfx.currenttileset].height,
										 2, 4, enemycol(Game.enemyqueue[i].type));
			}else if (Game.enemyqueue[i].dir == "up") {
				Gfx.fillrect(Game.enemyqueue[i].x * Gfx.tiles[Gfx.currenttileset].width, 
										 ((Game.enemyqueue[i].y+1) * Gfx.tiles[Gfx.currenttileset].height)-2,
										 Gfx.tiles[Gfx.currenttileset].width, 2, enemycol(Game.enemyqueue[i].type));
				Gfx.fillrect(Game.enemyqueue[i].x * Gfx.tiles[Gfx.currenttileset].width, 
										 ((Game.enemyqueue[i].y+1) * Gfx.tiles[Gfx.currenttileset].height)-4,
										 2, 4, enemycol(Game.enemyqueue[i].type));
				Gfx.fillrect(((Game.enemyqueue[i].x+1) * Gfx.tiles[Gfx.currenttileset].width)-2, 
										 ((Game.enemyqueue[i].y+1) * Gfx.tiles[Gfx.currenttileset].height)-4,
										 2, 4, enemycol(Game.enemyqueue[i].type));
			}
		}
		var t:Int;
		for (j in World.cameray ... Gfx.screentileheight + 1 + World.cameray) {
			for (i in World.camerax ... Gfx.screentilewidth + 1 + World.camerax) {
				t = Localworld.swordat(i, j);// , World.camerax, World.cameray);
				if (t > 0) {
					//Gfx.fillrect((i * Gfx.tiles[Gfx.currenttileset].width) - (World.camerax * Gfx.tiles[Gfx.currenttileset].width), (j * Gfx.tiles[Gfx.currenttileset].height) - (World.cameray * Gfx.tiles[Gfx.currenttileset].height), Gfx.tiles[Gfx.currenttileset].width, Gfx.tiles[Gfx.currenttileset].height, Localworld.backcolourmap(i, j, t));
					Gfx.drawtile_col((i * Gfx.tiles[Gfx.currenttileset].width) - (World.camerax * Gfx.tiles[Gfx.currenttileset].width), (j * Gfx.tiles[Gfx.currenttileset].height) - (World.cameray * Gfx.tiles[Gfx.currenttileset].height), swordchar(t), 0xFFFFFF);
				}
			}
		}
	}
	
	public static function swordchar(t:Int):Int {
		//1: Up
		//2: Down
		//4: Left
		//8: Right
		switch(t) {
			case 1:
				return 179;
			case 2:
				return 179;
			case 4:
				return "-".charCodeAt(0);
			case 8:
				return "-".charCodeAt(0);
			case 3: // 1 + 2
				return 186;
			case 12: // 4 + 8
				return "=".charCodeAt(0);
			default:
				return "+".charCodeAt(0);
		}
		return " ".charCodeAt(0);
	}
	
	public static function swordlayer():Void {
		var t:Int;
		for (j in World.cameray ... Gfx.screentileheight + 1 + World.cameray) {
			for (i in World.camerax ... Gfx.screentilewidth + 1 + World.camerax) {
				t = Localworld.swordat(i, j);// , World.camerax, World.cameray);
				if (t > 0) {
					//Gfx.fillrect((i * Gfx.tiles[Gfx.currenttileset].width) - (World.camerax * Gfx.tiles[Gfx.currenttileset].width), (j * Gfx.tiles[Gfx.currenttileset].height) - (World.cameray * Gfx.tiles[Gfx.currenttileset].height), Gfx.tiles[Gfx.currenttileset].width, Gfx.tiles[Gfx.currenttileset].height, Localworld.backcolourmap(i, j, t));
					Gfx.drawtile_col((i * Gfx.tiles[Gfx.currenttileset].width) - (World.camerax * Gfx.tiles[Gfx.currenttileset].width), (j * Gfx.tiles[Gfx.currenttileset].height) - (World.cameray * Gfx.tiles[Gfx.currenttileset].height), swordchar(t), 0xFFFFFF);
				}
			}
		}
	}
	
	public static function terminalprint(x:Int, y:Int, t:String, col:Int = 0xFFFFFF, drawbacking:Bool = false, xoffset:Int = 0, yoffset:Int = 0, backingcol:Int = 0x444444, bordercol:Int = 0x000000):Void {
		if (x == Gfx.CENTER) {
			x = Gfx.screenwidthmid - Std.int(Text.len(t) / 2);
			//x= Std.int(((Gfx.screenwidth - (t.length * Gfx.tiles[Gfx.currenttileset].width)) / 2) / Gfx.tiles[Gfx.currenttileset].width);
		}else {
			x = x * 16;
		}
		if (drawbacking) {
			Gfx.fillrect(x + 2, y + 4, Text.len(t), Text.height(), 0, 0, 0);
			Gfx.fillrect(x, y + 2, Text.len(t), Text.height(), backingcol);
		}
		
		Text.print(x + xoffset, y + yoffset, t, col);
	}
	
	public static function rterminalprint(x:Int, y:Int, t:String, col:Int = 0xFFFFFF, drawbacking:Bool = false, backingcol:Int = 0x444444):Void {
		x = x - Text.len(t);
		if (drawbacking) {
			Gfx.fillrect(x + 2, y + 4, Text.len(t), Text.height(), 0, 0, 0);
			Gfx.fillrect(x, y + 2, Text.len(t), Text.height(), backingcol);
		}
		
		Text.print(x, y, t, col);
	}
	
	public static function drawbackground():Void {
		Gfx.cls();
	}
	
	public static function messagecol(t:String):Int {
		switch(t) {
			case "shout":
			  if (Help.slowsine % 32 >= 16) {
					return Gfx.RGB(255, 255, 255);
				}else {
					return Gfx.RGB(196, 196, 196);
				}
			case "whisper":
				if (Help.slowsine % 32 >= 16) {
					return Gfx.RGB(164, 164, 164);
				}else {
					return Gfx.RGB(128, 128, 128);
				}
			case "player":
				if (Help.slowsine % 32 >= 16) {
					return Gfx.RGB(164, 164, 196);
				}else {
					return Gfx.RGB(164, 164, 255);
				}
			case "white":
				return Gfx.RGB(255 - Help.glow, 255 - Help.glow, 255 - Help.glow);
			case "gray":
				return Gfx.RGB(160 - Help.glow, 160 - Help.glow, 160 - Help.glow);
			case "blue": 
				return Gfx.RGB(Help.glow, Help.glow, 255 - Help.glow);
			case "red": 
				return Gfx.RGB(255 - Help.glow, Help.glow, Help.glow);
			case "purple": 
				return Gfx.RGB(255 - Help.glow, Help.glow, 255 - Help.glow);
			case "green": 
				return Gfx.RGB(Help.glow, 255 - Help.glow, Help.glow);
			case "yellow": 
				return Gfx.RGB(255 - Help.glow, 255 - Help.glow, Help.glow);
			case "flashing":
			  if (Help.slowsine % 32 >= 16) {
					return Gfx.RGB(255 - Help.glow, 164, 164);
				}else {
					return Gfx.RGB(255 - Help.glow, 255, 164);
				}
			case "good":
				if (Help.slowsine % 32 >= 16) {
					return Gfx.RGB(164, 255, 164);
				}else{
					return Gfx.RGB(64, 255, 64);
				}
			case "life":
				return Gfx.RGB(0, 0, 0);
			case "rainbow":
				return Gfx.hsl2rgb(Help.hueglow, 1, 0.5);
		}
		return Gfx.RGB(255, 255, 255);
	}
	
	public static function messagecolback(t:String):Int {
		switch(t) {
			case "white":
				return Gfx.RGB(64, 64, 64);
			case "blue": 
				return Gfx.RGB(0, 0, 64);
			case "red": 
				return Gfx.RGB(64, 0, 0);
			case "purple": 
				return Gfx.RGB(64, 0, 64);
			case "green": 
				return Gfx.RGB(0, 64, 0);
			case "yellow": 
				return Gfx.RGB(64, 64, 0);
			case "rainbow":
				return Gfx.hsl2rgb(Help.hueglow, 0.5, 0.2);
			case "life":
				return Gfx.RGB(255, 255, 255);
				
		}
		return Gfx.RGB(32, 32, 32);
	}
	
	public static var tempx:Int;
	public static var tempy:Int;
	
	public static var perlinnoise:Int;
}