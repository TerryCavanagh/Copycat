package gamecontrol;

import openfl._v2.geom.Point;
import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import config.*;
import com.terry.*;
	
class Localworld {
	public static var BACKGROUND:Int = 0;
	public static var FLOOR:Int = 1;
	public static var BLOOD:Int = 2;
	public static var WALL:Int = 3;
	public static var RUBBLE:Int = 4;
	
	public static var numworldblocks:Int = 5;
	
	public static function init():Void {
		tpoint = new Point();
		for (i in 0 ... 100) worldblock.push(new Worldblockclass());
		
		worldblock[BACKGROUND].set(0, 0, Gfx.RGB(0, 0, 0), Gfx.RGB(0, 0, 32));
		worldblock[FLOOR].set(c("."), c("."), 0x1e265f, 0x1e265f);
		worldblock[BLOOD].set(c("#"), c("#"), Gfx.RGB(96, 48, 48), Gfx.RGB(64, 32, 32));
		worldblock[WALL].set(177, 177, 0x2281ff, 0x2281ff);
		worldblock[RUBBLE].set(c("#"), c("#"), Gfx.RGB(48, 48, 96), Gfx.RGB(32, 32, 64));
	}

	public static function sc(t:Int):Void { //Set collision
	  World.sc(t);
	}
	
	public static function initcollisionarray():Void {
		//Set collision info for entire map
		sc(BACKGROUND);
		sc(WALL);
	}
	
	public static function loadlevel(s:String, r:String):Void {
		World.noxcam = false; World.noycam = false;
		if (World.mapwidth <= Gfx.screentilewidth) World.noxcam = true;
		if (World.mapheight <= Gfx.screentileheight) World.noycam = true;
	}
	
	public static function c(t:String):Int {
		return t.charCodeAt(0);
	}
	
	public static function charmap(x:Int, y:Int, t:Int):Int {
		return worldblock[t].charcode_lit;
	}
	
	public static function colourmap(x:Int, y:Int, t:Int):Int {
		highlight = highlightat(x, y);
		highlightcooldown = highlightcooldownat(x, y);
		laser = laserat(x, y);
		//Return the RGB value to use for each wall type
		if (laser == 1 && highlight == 1) {
			tr = 255;
			tg = Std.int(Math.min(Gfx.getgreen(worldblock[t].front_lit)*0.2, 255));
			tb = Std.int(Math.min(Gfx.getblue(worldblock[t].front_lit)*0.2, 255));
			
			tr = Std.int(Math.min(tr * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			tg = Std.int(Math.min(tg * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			tb = Std.int(Math.min(tb * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			return Gfx.RGB(tr, tg, tb);
		}else if (laser == 1) {
			tg = Std.int(Math.min(Gfx.getgreen(worldblock[t].front_lit)*0.2, 255));
			tb = Std.int(Math.min(Gfx.getblue(worldblock[t].front_lit)*0.2, 255));
			return Gfx.RGB(255, tg, tb);
		}else if (highlight == 1) {
			tr = Std.int(Math.min(Gfx.getred(worldblock[t].front_lit) * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			tg = Std.int(Math.min(Gfx.getgreen(worldblock[t].front_lit) * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			tb = Std.int(Math.min(Gfx.getblue(worldblock[t].front_lit) * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			return Gfx.RGB(tr, tg, tb);
		}else {
			return worldblock[t].front_lit;
		}
		return 0;
	}
	
	public static function backcolourmap(x:Int, y:Int, t:Int):Int {
		highlight = highlightat(x, y);
		highlightcooldown = highlightcooldownat(x, y);
		laser = laserat(x, y);
		//Return the RGB value to use for each BACKGROUND wall type
		if (Game.currentweapon == "deathgun") {
			tr = Draw.messagecolback("rainbow");
			tg = tr;
			tb = tr;
			
			tr = Std.int(Gfx.getred(tr) / 2);
			tg = Std.int(Gfx.getgreen(tg) / 2);
			tb = Std.int(Gfx.getblue(tb) / 2);
			
			return Gfx.RGB(tr, tg, tb);
		}else if (laser == 1 && highlight == 1) {
			tr = 64;
			tg = Std.int(Math.min(Gfx.getgreen(worldblock[t].front_lit)*0.2, 255));
			tb = Std.int(Math.min(Gfx.getblue(worldblock[t].front_lit) * 0.2, 255));
			
			tr = Std.int(Math.min(tr * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			tg = Std.int(Math.min(tg * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			tb = Std.int(Math.min(tb * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			return Gfx.RGB(tr, tg, tb);
		}else if (laser == 1) {
			tg = Std.int(Math.min(Gfx.getgreen(worldblock[t].front_lit)*0.2, 255));
			tb = Std.int(Math.min(Gfx.getblue(worldblock[t].front_lit)*0.2, 255));
			return Gfx.RGB(64, tg, tb);
		}else if (highlight == 1) {
			tr = Std.int(Math.min(Gfx.getred(worldblock[t].back_lit) * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			tg = Std.int(Math.min(Gfx.getgreen(worldblock[t].back_lit) * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			tb = Std.int(Math.min(Gfx.getblue(worldblock[t].back_lit) * (1 + (Lerp.from_value(2, 0.0, highlightcooldown, 20, "sine_in"))), 255));
			return Gfx.RGB(tr, tg, tb);
		}else {
			//Show heatmap for testing
			/*
			var redthing:Int = 255 - (heatmapat(x, y) * 40);
			if (redthing >= 255) redthing = 0;
			if (redthing < 0) redthing = 0;
			return Gfx.RGB(redthing, Std.int(redthing / 2), 0);
			*/
			return worldblock[t].back_lit;
		}
		return 0;
	}
	
	public static function changemapsize(w:Int, h:Int):Void {
		World.changemapsize(w, h);
	}
	
	public static function clearmap():Void {
		for (j in 0 ... World.mapheight) {
			for (i in 0 ... World.mapwidth) {
				World.placetile(i, j, BACKGROUND);
			}
		}
	}
	
	public static function randomwall():Void {
		World.placetile(Random.pint(0, World.mapwidth - 1), Random.pint(0, World.mapheight - 1), WALL);
	}
	
	public static function checkfreespace(x:Int, y:Int, w:Int, h:Int):Bool {
		//Check that the given rectangle doesn't contain anything except background
		if (x < 0) return false;
		for (j in y ... y + h) {
			for (i in x ... x + w) {
				if (World.at(i, j) != BACKGROUND) return false;
				if (i >= World.mapwidth) return false;
				if (j >= World.mapheight) return false;
			}
		}
		return true;
	}
	
	public static function placeroomrects():Void {
		for (i in 0 ... roomrects.length) {
			placeactualroom(Std.int(roomrects[i].x), Std.int(roomrects[i].y), Std.int(roomrects[i].width), Std.int(roomrects[i].height));
		}
	}
	
	public static function placeactualroom(x:Int, y:Int, w:Int, h:Int):Void {
		for (j in y ... y + h) {
			for (i in x ... x + w) {
				if (World.at(i, j) == FLOOR) {
					World.placetile(i, j, FLOOR);
				}else {
					World.placetile(i, j, FLOOR);
					if (i == x) World.placetile(i, j, WALL);
					if (i == x + w - 1) World.placetile(i, j, WALL);
					if (j == y) World.placetile(i, j, WALL);
					if (j == y + h - 1) World.placetile(i, j, WALL);
				}
			}
		}
	}
	
	public static function placeactualroom_nochecks(x:Int, y:Int, w:Int, h:Int, floortile:Int = -1, walltile:Int = -1):Void {
		if (floortile == -1) floortile = FLOOR;
		if (walltile == -1) walltile = WALL;
		
		for (j in y ... y + h) {
			for (i in x ... x + w) {
				World.placetile(i, j, floortile);
				if (i == x) World.placetile(i, j, walltile);
				if (i == x + w - 1) World.placetile(i, j, walltile);
				if (j == y) World.placetile(i, j, walltile);
				if (j == y + h - 1) World.placetile(i, j, walltile);
			}
		}
	}
	
	public static function randomroom(type:String):Void {
		//Try to place a random room on the map of the given type.
		tx1 = -1; ty1 = -1;
		attempts = 500;
		
		switch(type) {
			case "big":
				while (!checkfreespace(tx1, ty1, tx2, ty2) && attempts > 0) {
					tx1 = Random.pint(0, World.mapwidth - 1);
					ty1 = Random.pint(0, World.mapheight - 1);
					tx2 = Random.pint(12, 15); 
					ty2 = Random.pint(8, 11);
					attempts--;
				}
				
				if (attempts > 0) {
					roomrects.push(new Rectangle(tx1, ty1, tx2, ty2));
					placeactualroom_nochecks(tx1, ty1, tx2, ty2);
				}
			case "small":
				while (!checkfreespace(tx1, ty1, tx2, ty2) && attempts > 0) {
					tx1 = Random.pint(0, World.mapwidth - 1);
					ty1 = Random.pint(0, World.mapheight - 1);
					tx2 = Random.pint(5, 8); 
					ty2 = Random.pint(5, 8);
					attempts--;
				}
				
				if (attempts > 0) {
					roomrects.push(new Rectangle(tx1, ty1, tx2, ty2));
					placeactualroom_nochecks(tx1, ty1, tx2, ty2);
				}
		}
	}
	
	public static function draw_horizontal_line(x:Int, y1:Int, y2:Int, tile:Int):Void {
		if (y1 > y2) {
			draw_horizontal_line(x, y2, y1, tile);
		}else{
			for (i in y1 ... y2 + 1) {
				if (World.at(x, i) != FLOOR) World.placetile(x, i, tile);
			}
		}
	}

	public static function draw_vertical_line(x1:Int, x2:Int, y:Int, tile:Int):Void {
		if (x1 > x2) {
			draw_vertical_line(x2, x1, y, tile);
		}else{
			for (i in x1 ... x2+1) {
				if (World.at(i, y) != FLOOR) World.placetile(i, y, tile);
			}
		}
	}
	
	public static function drawcorner(x1:Int, y1:Int, x2:Int, y2:Int, type:String):Void {
		if (type == "tl") {
			draw_horizontal_line(x1-1, y1-1, y2+1, WALL);
			draw_horizontal_line(x1+1, y1-1, y2+1, WALL);
			
			draw_vertical_line(x1-1, x2+1, y1-1, WALL);
			draw_vertical_line(x1-1, x2+1, y1+1, WALL);
			
			draw_horizontal_line(x1, y1, y2, FLOOR);
			draw_vertical_line(x1, x2, y1, FLOOR);
		}else if (type == "tr") {
			draw_horizontal_line(x1-1, y1-1, y2+1, WALL);
			draw_horizontal_line(x1+1, y1-1, y2+1, WALL);
			
			draw_vertical_line(x1-1, x2+1, y2-1, WALL);
      draw_vertical_line(x1-1, x2+1, y2+1, WALL);
			
			draw_horizontal_line(x1, y1, y2, FLOOR);
			draw_vertical_line(x1, x2, y2, FLOOR);
		}else if (type == "bl") {
			draw_horizontal_line(x2-1, y1-1, y2+1, WALL);
			draw_horizontal_line(x2+1, y1-1, y2+1, WALL);
			
			draw_vertical_line(x1-1, x2+1, y1-1, WALL);
			draw_vertical_line(x1-1, x2+1, y1+1, WALL);
			
			draw_horizontal_line(x2, y1, y2, FLOOR);
			draw_vertical_line(x1, x2, y1, FLOOR);
		}else if (type == "br") {
			draw_horizontal_line(x2-1, y1-1, y2+1, WALL);
			draw_horizontal_line(x2+1, y1-1, y2+1, WALL);
			
			draw_vertical_line(x1-1, x2+1, y2-1, WALL);
      draw_vertical_line(x1-1, x2+1, y2+1, WALL);
			
			draw_horizontal_line(x2, y1, y2, FLOOR);
			draw_vertical_line(x1, x2, y2, FLOOR);
		}else if (type == "box") {
			draw_horizontal_line(x1-1, y1-1, y2+1, WALL);
			draw_horizontal_line(x1+1, y1-1, y2+1, WALL);
			
			draw_horizontal_line(x2-1, y1-1, y2+1, WALL);
			draw_horizontal_line(x2+1, y1-1, y2+1, WALL);
			
			draw_vertical_line(x1-1, x2+1, y1-1, WALL);
			draw_vertical_line(x1-1, x2+1, y1+1, WALL);
			
			draw_vertical_line(x1-1, x2+1, y2-1, WALL);
      draw_vertical_line(x1-1, x2+1, y2+1, WALL);
			
			draw_horizontal_line(x1, y1, y2, FLOOR);
			draw_horizontal_line(x2, y1, y2, FLOOR);
			draw_vertical_line(x1, x2, y1, FLOOR);
			draw_vertical_line(x1, x2, y2, FLOOR);
		}
	}
	
	public static function connectrooms(a:Int, b:Int):Void {
		//Tunnel between rooms a and b! Basically, draw two lines of floor.
		//Pick a point in both rooms:
		if(roomrects.length>b && roomrects.length>a){
			tx1 = Random.pint(Std.int(roomrects[a].x)+1, Std.int(roomrects[a].x + roomrects[a].width-2));
			ty1 = Random.pint(Std.int(roomrects[a].y)+1, Std.int(roomrects[a].y + roomrects[a].height-2));
			
			tx2 = Random.pint(Std.int(roomrects[b].x)+1, Std.int(roomrects[b].x + roomrects[b].width-2));
			ty2 = Random.pint(Std.int(roomrects[b].y) + 1, Std.int(roomrects[b].y + roomrects[b].height - 2));
			if (tx2 < tx1) {
				var temp:Int = tx1;
				tx1 = tx2;
				tx2 = temp;
			}
			if (ty2 < ty1) {
				var temp:Int = ty1;
				ty1 = ty2;
				ty2 = temp;
			}
			
			//pick a corner
			var corner:Int = Random.pint(0, 3);
			//is that corner in one of the rooms? then swap it horizontally.
			if (corner == 0) {
				//Top Left
				if (roomrects[a].contains(tx1, ty1) || roomrects[b].contains(tx1, ty1)) {
					drawcorner(tx1, ty1, tx2, ty2, "tr");
				}else {
					drawcorner(tx1, ty1, tx2, ty2, "tl");
				}
			}else if (corner == 1) {
				//Top right
				if (roomrects[a].contains(tx2, ty1) || roomrects[b].contains(tx2, ty1)) {
					drawcorner(tx1, ty1, tx2, ty2, "tl");
				}else {
					drawcorner(tx1, ty1, tx2, ty2, "tr");
				}
			}else if (corner == 2) {
				//Bottom left
				if (roomrects[a].contains(tx1, ty2) || roomrects[b].contains(tx1, ty2)) {
					drawcorner(tx1, ty1, tx2, ty2, "br");
				}else {
					drawcorner(tx1, ty1, tx2, ty2, "bl");
				}
			}else if (corner == 3) {
				//Bottom right
				if (roomrects[a].contains(tx2, ty2) || roomrects[b].contains(tx2, ty2)) {
					drawcorner(tx1, ty1, tx2, ty2, "bl");
				}else {
					drawcorner(tx1, ty1, tx2, ty2, "br");
				}
			}
		}
	}
	
	public static function shiftleft():Void {
		for (j in 0 ... World.mapheight) {
			for (i in 0 ... World.mapwidth - 1) {
				World.placetile(i, j, World.at(i + 1, j));
			}
		}
		
		for (j in 0 ... World.mapheight) {
			World.placetile(World.mapwidth - 1, j, BACKGROUND);
		}
	}
	
	public static function shiftup():Void {
		for (i in 0 ... World.mapwidth) {
			for (j in 0 ... World.mapheight - 1) {
				World.placetile(i, j, World.at(i, j+1));
			}
		}
		
		for (i in 0 ... World.mapwidth) {
			World.placetile(i, World.mapheight - 1, BACKGROUND);
		}
	}
	
	public static function shiftright():Void {
		for (j in 0 ... World.mapheight) {
			var i:Int = World.mapwidth - 1;
			while (i > 0) {
				World.placetile(i, j, World.at(i - 1, j));
				i--;
			}
		}
		
		for (j in 0 ... World.mapheight) {
			World.placetile(0, j, BACKGROUND);
		}
	}
	
	public static function shiftdown():Void {
		for (i in 0 ... World.mapwidth) {
			var j:Int = World.mapheight - 1;
			while (j > 0) {
				World.placetile(i, j, World.at(i, j - 1));
				j--;
			}
		}
		
		for (i in 0 ... World.mapwidth) {
			World.placetile(i, 0, BACKGROUND);
		}
	}
	
	public static function centermap():Void {
		//Ok! Find the boundary of the map first of all
		tx1 = World.mapwidth; ty1 = World.mapheight; tx2 = -1; ty2 = -1;
		
		for (j in 0 ... World.mapheight) {
			for (i in 0 ... World.mapwidth) {
				if (World.at(i, j) != BACKGROUND) {
					if (i < tx1) tx1 = i;
					if (j < ty1) ty1 = j;
					if (i > tx2) tx2 = i;
					if (j > ty2) ty2 = j;
				}
			}
		}
		
		tx2 = World.mapwidth - 1 - tx2;
		ty2 = World.mapheight - 1 - ty2;
		while (tx1 - tx2 > 2) {
			shiftleft();
			tx1--; tx2++;
		}
		while (tx1 - tx2 < -2) {
			shiftright();
			tx1++; tx2--;
		}
		while (ty1 - ty2 > 1) {
			shiftup();
			ty1--; ty2++;
		}
		while (ty1 - ty2 < -1) {
			shiftdown();
			ty1++; ty2--;
		}
	}
	
	public static function generate(s:String, overlap:Bool = false):Void {
		World.tileset = "terminal";
		Gfx.changetileset(World.tileset);
		Gfx.screentilewidth = Std.int(Gfx.screenwidth / Gfx.tiles[Gfx.currenttileset].width);
		Gfx.screentileheight = Std.int(Gfx.screenheight / Gfx.tiles[Gfx.currenttileset].height);
		
		switch(s) {
			case "ludumdare":
				changemapsize(24, 11);
				for (j in 0 ... World.mapheight) {
					for (i in 0 ... World.mapwidth) {
						World.placetile(i, j, Random.ppickint(WALL, FLOOR, FLOOR, FLOOR, FLOOR));
						/*
						if (i < 4 || i > World.mapwidth - 4 || j < 4 || j > World.mapheight - 4) {
							if(i!=0 && j!=0 && i!=World.mapwidth-1 &&j!=World.mapheight-1){
								World.placetile(i, j, WALL);
							}else {
								World.placetile(i, j, FLOOR);
							}
						}
						*/
					}
				}
		}
	}	
	
	
	public static function swordpoint(x:Int, y:Int, a:Int):Void {
		if (a == Help.RIGHT) {
			a = 8;
		}else if (a == Help.LEFT) {
			a = 4;
		}else if (a == Help.DOWN) {
			a = 2;
		}else if (a == Help.UP) {
			a = 1;
		}
		if (Help.inboxw(x, y, 0, 0, World.mapwidth-1, World.mapheight-1)) {
			World.sword[x + World.vmult[y]] += a;
		}
	}
	
	public static function swordat(x:Int, y:Int):Int {
		if (x >= 0 && y >= 0 && x < World.mapwidth && y < World.mapheight) {
			return World.sword[x + World.vmult[y]];
		}
		return 0;
	}
	
	public static function swordclink():Void {
		//If there is sword overlap ANYWHERE in the map, do a clink sound.
		var t:Int = 0;
		for (j in 0 ... World.mapheight) {
			for (i in 0 ... World.mapwidth) {
				t = World.sword[i + World.vmult[j]];
				if (t > 0) {
					if (t != 1 && t != 2 && t != 4 && t != 8) {
						Music.playef("swordclash");
						return;
					}
				}
			}
		}
	}
	
	public static function makeswordmap():Void {
		for (j in 0 ... World.mapheight) {
			for (i in 0 ... World.mapwidth) {
				World.sword[i + World.vmult[j]] = 0;
			}
		}
		
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].rule == "enemy") {
					if (Obj.entities[i].type == "swordguy") {
						tx = Obj.entities[i].xp;
						ty = Obj.entities[i].yp;
						tdir = Obj.entities[i].dir;
						swordpoint(tx + xstep(tdir), ty + ystep(tdir), tdir);
					}
				}
			}
		}
		
		if(Game.currentweapon=="swordgun"){
			var i:Int = Obj.getplayer();
			if(i>-1){
				if (Obj.entities[i].active) {
					tx = Obj.entities[i].xp;
					ty = Obj.entities[i].yp;
					tdir = Obj.entities[i].dir;
					swordpoint(tx + xstep(tdir), ty + ystep(tdir), tdir);
				}
			}
		}
	}
	
	public static function clearhighlight():Void {
		for (j in 0 ... World.mapheight) {
			for (i in 0 ... World.mapwidth) {
				World.highlight[i + World.vmult[j]] = 0;
			}
		}
	}
	
	public static function clearlaser():Void {
		for (j in 0 ... World.mapheight) {
			for (i in 0 ... World.mapwidth) {
				World.laser[i + World.vmult[j]] = 0;
			}
		}
	}
	
	/** Create a heatmap for pathfinding. */
	public static function createheatmap():Void {
		//We start by blanking the current map.
		//-2 means still to be assigned.
		//-1 means a wall.
		for (j in 0 ... World.mapheight) {
			for (i in 0 ... World.mapwidth) {
				if (World.collide(i, j)) {
					heatmapset(i, j, -1);
				}else {
					heatmapset(i, j, -2);
				}
			}
		}
		
		//From the player, we flood fill out.
		tr = Obj.getplayer();
		if (tr > -1) {
			if(Obj.entities[tr].active){
				tx = Obj.entities[tr].xp;	ty = Obj.entities[tr].yp;
				
				heatmapfill(tx, ty, 0);
			}
		}
	}
	
	/** Recursive function for filling heatmap data. */
	public static function heatmapfill(x:Int, y:Int, temperature:Int):Void {
		if (Help.inbox(x, y, 0, 0, World.mapwidth-1, World.mapheight-1)) {
			tr = heatmapat(x, y);
			if (tr == -2 || temperature < tr) {
				//Still to be assigned!
				heatmapset(x, y, temperature);
				heatmapfill(x, y - 1, temperature+1);
				heatmapfill(x, y + 1, temperature+1);
				heatmapfill(x - 1, y, temperature+1);
				heatmapfill(x + 1, y, temperature+1);
			}
		}
	}
	
	/** From (x,y), which direction is best to move closer to the player? */
	public static function heatmapmovedir(x:Int, y:Int, dir:Int):Int {
		//This increase the movement cost of changing direction.
		tg = 10000;
		
		tb = Help.NODIRECTION;
		tdir = Random.pint(0, 3);
		
		for (i in 0 ... 4) {
			tdir = Help.clockwise(tdir);
			tr = heatmapat(x + xstep(tdir), y + ystep(tdir));
			if (tr == -2) {
				//Shit, we're locked out.
				return Help.NODIRECTION;
			}
			if (tr != -1) if (dir != i) tr += 1;
			if (tr > -1 && tr < tg) {	tg = tr; tb = tdir; }
		}
		
		return tb;
	}
	
	/** From (x,y), which direction is best to move further from the player? */
	public static function heatmapmovedir_away(x:Int, y:Int, dir:Int):Int {
		//This increase the movement cost of changing direction.
		tg = 0;
		
		tb = Help.NODIRECTION;
		tdir = Random.pint(0, 3);
		
		for (i in 0 ... 4) {
			tdir = Help.clockwise(tdir);
			tr = heatmapat(x + xstep(tdir), y + ystep(tdir));
			//if (tr != -1) if (dir == i) tr--;
			if (tr == -2) {
				//Shit, we're locked out.
				return Help.NODIRECTION;
			}
			if (tr > -1 && tr != 1000 && tr > tg) {	tg = tr; tb = tdir; }
		}
		
		return tb;
	}
	
	/** From (x,y), which direction is best to move closer to the player? */
	public static function heatmapmove(x:Int, y:Int):Int {
		tg = 10000;
		
		tb = Help.NODIRECTION;
		tdir = Random.pint(0, 3);
		
		for (i in 0 ... 4) {
			tdir = Help.clockwise(tdir);
			tr = heatmapat(x + xstep(tdir), y + ystep(tdir));
			if (tr == -2) {
				//Shit, we're locked out.
				return Help.NODIRECTION;
			}
			if (tr > -1 && tr < tg) {	tg = tr; tb = tdir; }
		}
		
		return tb;
	}
	
	public static function heatmapat(x:Int, y:Int):Int {
		if (x >= 0 && y >= 0 && x < World.mapwidth && y < World.mapheight) {
			return World.heatmap[x + World.vmult[y]];
		}
		return 1000;
	}
	
	
	public static function heatmapset(x:Int, y:Int, t:Int):Void {
		if (x >= 0 && y >= 0 && x < World.mapwidth && y < World.mapheight) {
			World.heatmap[x + World.vmult[y]] = t;
		}
	}
	
	public static function highlightpointoff(x:Int, y:Int):Void {
		if (Help.inboxw(x, y, 0, 0, World.mapwidth-1, World.mapheight-1)) {
			World.highlight[x + World.vmult[y]] = 0;
		}
	}
	
	public static function highlightpoint(x:Int, y:Int, l:Int = 20):Void {
		if (Help.inboxw(x, y, 0, 0, World.mapwidth-1, World.mapheight-1)) {
			World.highlight[x + World.vmult[y]] = 1;
			World.highlightcooldown[x + World.vmult[y]] = l;
		}
	}
	
	public static function laserpoint(x:Int, y:Int, ent:Int):Void {
		if (Help.inboxw(x, y, 0, 0, World.mapwidth-1, World.mapheight-1)) {
			World.laser[x + World.vmult[y]] = 1;
			if (x == playerx && y == playery) {
				if (ent > -1) foundplayer(ent);
			}
		}
	}

	public static function laserat(x:Int, y:Int):Int {
		if (x >= 0 && y >= 0 && x < World.mapwidth && y < World.mapheight) {
			return World.laser[x+World.vmult[y]];
		}
		return 0;
	}
	
	public static function highlightat(x:Int, y:Int):Int {
		if (x >= 0 && y >= 0 && x < World.mapwidth && y < World.mapheight) {
			return World.highlight[x+World.vmult[y]];
		}
		return 0;
	}
	
	public static function highlightcooldownat(x:Int, y:Int):Int {
		if (x >= 0 && y >= 0 && x < World.mapwidth && y < World.mapheight) {
			return World.highlightcooldown[x+World.vmult[y]];
		}
		return 0;
	}

	public static function xstep(t:Int, dif:Int = 1):Int {
		if (t == Help.LEFT) return -dif;
		if (t == Help.RIGHT) return dif;
		return 0;
	}
	
	public static function ystep(t:Int, dif:Int = 1):Int {
		if (t == Help.UP) return -dif;
		if (t == Help.DOWN) return dif;
		return 0;
	}
	
	
	public static function xstep_between(t:Int, dir2:Int):Int {
		if (t == Help.LEFT) {
			return -1;
		}
		if (t == Help.RIGHT) {
			return 1;
		}
		if (t == Help.UP) {
			if (dir2 == Help.LEFT) {
				return -1;
			}else if (dir2 == Help.RIGHT) {
				return 1;
			}
		}
		if (t == Help.DOWN) {
			if (dir2 == Help.LEFT) {
				return -1;
			}else if (dir2 == Help.RIGHT) {
				return 1;
			}
		}
		return 0;
	}
	
	public static function ystep_between(t:Int, dir2:Int):Int {
		if (t == Help.UP) {
			return -1;
		}
		if (t == Help.DOWN) {
			return 1;
		}
		if (t == Help.LEFT) {
			if (dir2 == Help.UP) {
				return -1;
			}else if (dir2 == Help.DOWN) {
				return 1;
			}
		}
		if (t == Help.RIGHT) {
			if (dir2 == Help.UP) {
				return -1;
			}else if (dir2 == Help.DOWN) {
				return 1;
			}
		}
		return 0;
	}
	
	public static function tinydirectionallaser(x:Int, y:Int, dir:Int, ent:Int):Void {
		if (Help.inboxw(x, y, 0, 0, World.mapwidth, World.mapheight)) {
			if(!Game.checkforbomborwall(x,y) && swordat(x,y) == 0){
				laserpoint(x, y, ent);
				tinydirectionallaser(x + xstep(dir), y + ystep(dir), dir, ent);
			}else {
				if (swordat(x, y) == 0) {
					if (World.collide(x, y)) laserpoint(x, y, ent);
				}
			}
		}
	}
	
	public static function foundplayer(ent:Int):Void {
		Obj.templates[Obj.entindex.get(Obj.entities[ent].rule)].alert(ent);
	}
	
	public static function updatelighting():Void {
		//Let's just light up a box around the player for now
		clearlaser();
		createheatmap();
		makeswordmap();
		
		if(Obj.getplayer()>-1){
			playerx = Std.int(Obj.entities[Obj.getplayer()].xp);
			playery = Std.int(Obj.entities[Obj.getplayer()].yp);
			for (i in 0 ... Obj.nentity) {
				if (Obj.entities[i].active) {
					tx = Std.int(Obj.entities[i].xp); ty = Std.int(Obj.entities[i].yp); tdir = Obj.entities[i].dir;
					if (Obj.entities[i].lightsource == "laser_narrow") {
						tinydirectionallaser(tx + xstep(tdir), ty + ystep(tdir), tdir, i);
					}else if (Obj.entities[i].lightsource == "laser_all") {
						tinydirectionallaser(tx + xstep(0), ty + ystep(0), 0, -1);
						tinydirectionallaser(tx + xstep(1), ty + ystep(1), 1, -1);
						tinydirectionallaser(tx + xstep(2), ty + ystep(2), 2, -1);
						tinydirectionallaser(tx + xstep(3), ty + ystep(3), 3, -1);
					}
				}
			}
		}
	}
	
	public static function raytrace(x:Int, y:Int, dir:Float, power:Int):Void {
	  Help.bresenhamline(x, y, Std.int(x + Math.cos(Help.torad(dir)) * power * 2),  Std.int(y + Math.sin(Help.torad(dir)) * power * 2));
		
		for (i in 0 ... Std.int(Help.bressize/2)) {
			if (World.collide(Help.bresx[i], Help.bresy[i])) {
				highlightpoint(Help.bresx[i], Help.bresy[i]);
				return;
			}else{
				highlightpoint(Help.bresx[i], Help.bresy[i]);
			}
		}
	}
	
	public static var playerx:Int;
	public static var playery:Int;
	public static var spottedplayer:Bool;
	public static var tx:Int;
	public static var ty:Int;
	public static var tdir:Int;
	public static var tx1:Int;
	public static var ty1:Int;
	public static var tx2:Int;
	public static var ty2:Int;
	public static var tr:Int;
	public static var tg:Int;
	public static var tb:Int;
	public static var attempts:Int;
	
	public static var light:Int;
	public static var fog:Int;
	public static var highlight:Int;
	public static var highlightcooldown:Int;
	public static var laser:Int;
	public static var fire:Int;
	public static var fire2:Int;
	public static var fire3:Int;
	public static var firecol:Int;
	
	public static var onfire:Bool;
	
	public static var worldblock:Array<Worldblockclass> = new Array<Worldblockclass>();
	
	public static var roomrects:Array<Rectangle> = new Array<Rectangle>();
	public static var tpoint:Point = new Point();
}