package;

import com.terry.*;
import gamecontrol.*;
import config.*;
import openfl.system.System;

class Input {
	public static function titleinput() {
		#if !flash
			if (Key.justPressed("ESCAPE")) {
				System.exit(0);
			}
		#end
		
		if (Key.press_action && !Key.gamekeyheld) {
			Game.changestate(Game.GAMEMODE);
			Game.restartgame();
		}
		
		if (Key.justpressed_left) {
			Game.menuframe = (Game.menuframe+2) % 3;
			Game.menudelay = 0;
			Music.playef("shoot");
		}
		if (Key.justpressed_right) {
			Game.menuframe = (Game.menuframe+1) % 3;
			Game.menudelay = 0;
			Music.playef("shoot");
		}
	}
	
	public static function gameinput() {
		
		#if !flash
		
		if (Game.exitmenu) {
			if (Key.justPressed("ESCAPE")) {
				System.exit(0);
			}
			
			if (Key.justpressed_action) {
				Key.justpressed_action = false;
				Game.exitmenu = !Game.exitmenu;
				if (Game.exitmenu) {
					Game.addexitmenu();
				}else {
					Game.removeexitmenu();
					Music.playef("pushback");
				}
			}
			
			if (Key.justPressed("F")) {
				Gfx.fullscreen = !Gfx.fullscreen;
			  Gfx.updategraphicsmode();
			}
		}else{
			if (Key.justPressed("ESCAPE")) {
				Game.exitmenu = !Game.exitmenu;
				if (Game.exitmenu) {
					Game.addexitmenu();
				}else {
					Game.removeexitmenu();
				}
			}
		}
		
		#end
		
		if (Game.exitmenu) {
		}else if (Game.ascenddelay > 0) {
			
		}else if (Game.nukedelay > 0) {
			
		}else{
			if (Game.turn == "playermove") {
				if (Game.playbackrecording) {
					if (Game.stepthrough) {
						if (Key.justPressed("L")) {
							Game.playbackdelay = Game.playbackspeed;
						}
					}else{
						Game.playbackdelay++;
					}
					if (Game.playbackdelay >= Game.playbackspeed || Game.recordposition == 0) {
						if (Game.recordposition < Game.recordstring.length - 6) {
							Game.playbackdelay = Game.playbackspeed - 14;
						}else{
							Game.playbackdelay = 0;
						}
						var nextmove:String = Help.Mid(Game.recordstring, Game.recordposition, 1);
						switch(nextmove) {
							case "l":
								//Game.showmessage("LEFT", "white", 30);
								Key.press_left = true;
							case "r":
								//Game.showmessage("RIGHT", "white", 30);
								Key.press_right = true;
							case "u":
								//Game.showmessage("UP", "white", 30);
								Key.press_up = true;
							case "d":
								//Game.showmessage("DOWN", "white", 30);
								Key.press_down = true;
							case "x":
								//Game.showmessage("ACTION", "white", 30);
								Key.justpressed_action = true;
						}
						Game.recordposition++;
						if (Game.recordposition >= Game.recordstring.length) {
							//Game.showmessage("RECORDING FINISHED", "flashing", 90);
							Game.playbackrecording = false;
						}
					}
				}
				
				var i:Int = Obj.getplayer();
				if (i > -1) {
					if (Obj.entities[i].rule == "player") {
						if (Obj.entities[i].active) {
							if (Key.gamekeydelay <= 0) {
								if (Key.press_left) {
									Game.record("l");
									//Obj.entities[i].dir = Help.LEFT;
									//Game.startmove("move_left");
									if (Game.currentweapon == "wallgun") {
										Game.tx = Obj.entities[i].xp;
										Game.ty = Obj.entities[i].yp;
										Game.tdir = Help.anticlockwise(Obj.entities[i].dir);
										if (!World.collide(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir))) {
											Game.tx = Obj.entities[i].xp;
											Game.ty = Obj.entities[i].yp;
											Game.tdir = Obj.entities[i].dir;
											Game.tx += Localworld.xstep(Game.tdir);
											Game.ty += Localworld.ystep(Game.tdir);
											
											World.placetile(Game.tx, Game.ty, Localworld.FLOOR);
											
											//Is there an enemy in the corner we went through? If so, kill it
											Game.tx = Obj.entities[i].xp;
											Game.ty = Obj.entities[i].yp;
											Game.tdir = Obj.entities[i].dir;
											Game.tx += Localworld.xstep_between(Help.anticlockwise(Game.tdir), Game.tdir);
											Game.ty += Localworld.ystep_between(Help.anticlockwise(Game.tdir), Game.tdir);
											Game.temp = Game.checkforenemy(Game.tx, Game.ty);
											if (Game.temp >= 0) {
												Game.killenemy(Game.temp);
												World.placetile(Game.tx, Game.ty, Localworld.WALL);
											}
											
											Game.startmove("anticlockwise");
										}else {
											Music.playef("blocked");
											Gfx.screenshake = 5;
										}
									}else {
										/*
										Obj.entities[i].dir = Help.LEFT;
										Game.startmove("move_left");
										*/
										Game.startmove("anticlockwise");
									}
									Key.gamekeydelay = 12;
								}else if (Key.press_right) {
									Game.record("r");
									//Obj.entities[i].dir = Help.RIGHT;
									//Game.startmove("move_right");
									if (Game.currentweapon == "wallgun") {
										Game.tx = Obj.entities[i].xp;
										Game.ty = Obj.entities[i].yp;
										Game.tdir = Help.clockwise(Obj.entities[i].dir);
										if (!World.collide(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir))) {
											Game.tx = Obj.entities[i].xp;
											Game.ty = Obj.entities[i].yp;
											Game.tdir = Obj.entities[i].dir;
											Game.tx += Localworld.xstep(Game.tdir);
											Game.ty += Localworld.ystep(Game.tdir);
											
											World.placetile(Game.tx, Game.ty, Localworld.FLOOR);
											
											//Is there an enemy in the corner we went through? If so, kill it
											Game.tx = Obj.entities[i].xp;
											Game.ty = Obj.entities[i].yp;
											Game.tdir = Obj.entities[i].dir;
											Game.tx += Localworld.xstep_between(Help.clockwise(Game.tdir), Game.tdir);
											Game.ty += Localworld.ystep_between(Help.clockwise(Game.tdir), Game.tdir);
											Game.temp = Game.checkforenemy(Game.tx, Game.ty);
											if (Game.temp >= 0) {
												Game.killenemy(Game.temp);
												World.placetile(Game.tx, Game.ty, Localworld.WALL);
											}
											
											Game.startmove("clockwise");
										}else {
											Music.playef("blocked");
											Gfx.screenshake = 5;
										}
									}else{
										Game.startmove("clockwise");
										/*
										Obj.entities[i].dir = Help.RIGHT;
										Game.startmove("move_right");
										*/
									}
									Key.gamekeydelay = 12;
								}else if (Key.press_up) {
									Game.record("u");
									//Obj.entities[i].dir = Help.UP;
									//Game.startmove("move_up");
									if (Game.currentweapon == "wallgun") {
										Game.tx = Obj.entities[i].xp;
										Game.ty = Obj.entities[i].yp;
										Game.tdir = Obj.entities[i].dir;
										
										Game.tx += Localworld.xstep(Game.tdir);
										Game.ty += Localworld.ystep(Game.tdir);
										
										World.placetile(Game.tx, Game.ty, Localworld.FLOOR);
									}
									
									/*
								  Obj.entities[i].dir = Help.UP;
									Game.startmove("move_up");
									*/
									Game.startmove(Game.movestring(Obj.entities[i].dir));
									Key.gamekeydelay = 6;
								}else if (Key.press_down) {
									Game.record("d");
									//Obj.entities[i].dir = Help.DOWN;
									//Game.startmove("move_down");
									if (Game.currentweapon == "wallgun") {
										Game.tx = Obj.entities[i].xp;
										Game.ty = Obj.entities[i].yp;
										Game.tdir = Obj.entities[i].dir;
										
										Game.tx += Localworld.xstep(Game.tdir);
										Game.ty += Localworld.ystep(Game.tdir);
										
										World.placetile(Game.tx, Game.ty, Localworld.FLOOR);
									}
									
									/*
								  Obj.entities[i].dir = Help.DOWN;
									Game.startmove("move_down");
									*/
									Game.startmove("backwards" + Game.movestring(Help.oppositedirection(Obj.entities[i].dir)));
									Key.gamekeydelay = 6;
								}else if (Key.justpressed_action) {
									Game.record("x");
									//Use gadget!
									if (Inventory.equippedgadget > -1) {
										Game.dasheffectthisframe = false;
										Use.usegadget(i, Inventory.equippedgadget);
										if (Game.dashdeathkludge) {
											Key.justpressed_action = false;
											Game.resetplayermove(Obj.getplayer(), "nothing");
											Game.hurtplayer();
											Game.checkifplayerdead();
											Game.dashdeathkludge = false;
										}
										Localworld.updatelighting();
									}
									Key.gamekeydelay = 6;
								}else {
									Key.gamekeydelay = 0;
								}
							}else {
								Key.gamekeydelay--;
							}
						}
					}
				}
				
				/*
				if (Key.justPressed("ONE")) Game.changeweapon("swordgun");
				if (Key.justPressed("TWO")) Game.changeweapon("dashgun");
				if (Key.justPressed("THREE")) Game.changeweapon("shootgun");
				if (Key.justPressed("FOUR")) Game.changeweapon("bombgun");
				if (Key.justPressed("FIVE")) Game.changeweapon("wallgun");
				if (Key.justPressed("SIX")) Game.changeweapon("deathgun");
				*/
				
				if (Key.justPressed("R")) {
					Game.restartgame();
				}
				
				if (Key.justPressed("P")) {
					trace(Game.liverecordstring);
				}
				
				if (Key.justpressed_action && Game.gameover) {
					Game.restartgame();
				}
			}
		}
	}
}