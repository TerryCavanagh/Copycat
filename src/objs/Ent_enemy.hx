package objs;

import flash.display.*;
import flash.geom.*;
import flash.events.*;
import flash.net.*;
import gamecontrol.*;
import com.terry.*;
import com.terry.util.*;

class Ent_enemy extends Ent_generic {
	public function new() {
		super();
		
		name = "enemy";
		init_drawframe = 1;
		
		addpara1("thing", 0);
	}
	
	override public function create(i:Int, xp:Float, yp:Float, para1:String = "0", para2:String = "0", para3:String = "0"):Void {
		Obj.entities[i].rule = "enemy";
		Obj.entities[i].tileset = "terminal";
		Obj.entities[i].name = para1;
		Obj.entities[i].type = para1;
		World.placetile(Obj.entities[i].xp, Obj.entities[i].yp, Localworld.FLOOR);
		setupcollision(i);
		
		switch(Obj.entities[i].type) {
			case "boss":
				Obj.entities[i].tile = 206;
				Obj.entities[i].ai = "gotocenter";
				Obj.entities[i].stringpara = Obj.entities[i].ai;
				Obj.entities[i].speed = 0;
				Obj.entities[i].para = 0;
				Obj.entities[i].health = 1;
				Obj.entities[i].dir = Help.randomdirection();
				Obj.entities[i].lightsource = "none";
				
				Obj.entities[i].canattack = false;
			case "runnerguy":
				Obj.entities[i].tile = 127;
				Obj.entities[i].ai = "random";
				Obj.entities[i].stringpara = Obj.entities[i].ai;
				Obj.entities[i].speed = 0;
				Obj.entities[i].health = 1;
				Obj.entities[i].dir = Help.randomdirection();
				Obj.entities[i].lightsource = "none";
				
				Obj.entities[i].canattack = false;
			case "swordguy":
				Obj.entities[i].tile = 234;
				Obj.entities[i].ai = "pathfind";
				Obj.entities[i].stringpara = Obj.entities[i].ai;
				Obj.entities[i].speed = 0;
				Obj.entities[i].health = 1;
				Obj.entities[i].dir = Help.randomdirection();
				
				Obj.entities[i].canattack = false;
			case "snakeguy":
				Obj.entities[i].tile = 21;
				Obj.entities[i].ai = "pathfind_rush";
				Obj.entities[i].stringpara = Obj.entities[i].ai;
				Obj.entities[i].speed = 2;
				Obj.entities[i].health = 1;
				Obj.entities[i].dir = Help.randomdirection();
				Obj.entities[i].canattack = false;
			case "gunguy":
				Obj.entities[i].tile = 24;
				Obj.entities[i].ai = "pathfind";
				Obj.entities[i].stringpara = Obj.entities[i].ai;
				Obj.entities[i].speed = 0;
				Obj.entities[i].health = 1;
				Obj.entities[i].stunned = 2;
				Obj.entities[i].dir = Help.randomdirection();
				Obj.entities[i].lightsource = "none";
				
				Obj.entities[i].canattack = false;
			case "bombguy":
				Obj.entities[i].tile = 66;
				Obj.entities[i].ai = "pathfind_nodir";
				Obj.entities[i].stringpara = Obj.entities[i].ai;
				Obj.entities[i].speed = 0;
				Obj.entities[i].health = 1;
				Obj.entities[i].dir = Help.randomdirection();
				Obj.entities[i].lightsource = "none";
				
				Obj.entities[i].canattack = false;
			case "builderguy":
				Obj.entities[i].tile = 2;
				Obj.entities[i].ai = "wander";
				Obj.entities[i].stringpara = Obj.entities[i].ai;
				Obj.entities[i].speed = 0;
				Obj.entities[i].health = 1;
				Obj.entities[i].dir = Help.randomdirection();
				Obj.entities[i].lightsource = "none";
				
				Obj.entities[i].canattack = false;
			case "actualbomb":
				Obj.entities[i].tile = 149;
				Obj.entities[i].ai = "none";
				Obj.entities[i].stringpara = Obj.entities[i].ai;
				Obj.entities[i].lightsource = "none";
				Obj.entities[i].speed = 0;
				Obj.entities[i].para = 7;
				Obj.entities[i].health = 1;
				Obj.entities[i].dir = Help.randomdirection();
				Obj.entities[i].collidable = false;
				
				Obj.entities[i].canattack = false;
			default:
				trace("the hell is a " + Obj.entities[i].type + "?");
		}
		
		if (para2 == "up") {
			Obj.entities[i].dir = Help.UP;
		}else if (para2 == "down") {
			Obj.entities[i].dir = Help.DOWN;
		}else if (para2 == "left") {
			Obj.entities[i].dir = Help.LEFT;
		}else if (para2 == "right") {
			Obj.entities[i].dir = Help.RIGHT;
		}
		
		if (Obj.entities[i].type == "swordguy") {
			Game.destroywall(i);
		}
	}
	
	override public function update(i:Int):Void {
		switch(Obj.entities[i].type) {
			case "boss":
			case "runnerguy":
			case "builderguy":
			case "actualbomb":
				Obj.entities[i].para--;
				Game.playtick();
				if (Obj.entities[i].para <= 0) {
					//Detonate!
					Game.tx = Obj.entities[i].xp;
					Game.ty = Obj.entities[i].yp;
					for (j in -1 ... 2) {
						for (k in -1 ... 2) {
							Localworld.highlightpointoff(Game.tx + k, Game.ty + j);
							Game.temp = Game.checkforenemy(Game.tx + k, Game.ty + j);
							if (Game.checkforplayer(Obj.entities[i].xp + k, Obj.entities[i].yp + j)) {
								Game.hurtplayer();
								Game.checkifplayerdead();
							}else if (Game.temp == -2) {
								World.placetile(Game.tx + k, Game.ty + j, Localworld.FLOOR);
							}else if (Game.temp >= 0) {
								if (Obj.entities[Game.temp].type == "boss") {
									Game.bossbomb = true;
									Game.killenemy(Game.temp);
									Game.bossbomb = false;
								}
								
								if (Obj.entities[Game.temp].type != "actualbomb" &&
								    Obj.entities[Game.temp].type != "bombguy")	Game.killenemy(Game.temp);
							}
						}
					}
					Obj.entities[i].active = false;
					Music.playef("bomb");
					Gfx.screenshake = 15;
					Gfx.flashlight = 5;
				}
			case "bombguy":
				if (Obj.entities[i].ai == "pathfind_nodir") {
					//Drop a bomb when we're close enough
					var player:Int = Obj.getplayer();
					var xdist:Int = Std.int(Math.abs(Obj.entities[i].xp - Obj.entities[player].xp));
					var ydist:Int = Std.int(Math.abs(Obj.entities[i].yp - Obj.entities[player].yp));
					if (xdist + ydist <= 4) {
						Obj.entities[i].ai = "pathfind_away";
						Obj.entities[i].para = 8;
						Obj.createentity(Obj.entities[i].xp, Obj.entities[i].yp, "enemy", "actualbomb");
					}
				}else if (Obj.entities[i].ai == "pathfind_away") {
					Obj.entities[i].para--;
					if (Obj.entities[i].para <= 0) {
						Obj.entities[i].ai = "pathfind_nodir";
					}
				}
			case "gunguy":
				if (Obj.entities[i].stunned <= 0) Obj.entities[i].lightsource = "laser_narrow";
			case "swordguy", "snakeguy", "gunguy", "bombguy":
				if (Obj.entities[i].state == 0) {
					//Normal
				}else if (Obj.entities[i].state == 1) {
					//Alert
					//Obj.entities[i].state = 0;
				}else if (Obj.entities[i].state == 2) {
					//Knocked out
				}
		}
	}
	
	override public function alert(i:Int):Void {
		if (!Obj.entities[i].alerted_thisframe) {
			Obj.entities[i].alerted_thisframe = true;
			switch(Obj.entities[i].type) {
				case "boss":
					/*
					Music.playef("shoot");
					Game.hurtplayer();
					Game.checkifplayerdead();	
					*/
				case "gunguy":
					Music.playef("shoot");
					Game.hurtplayer();
					Game.checkifplayerdead();	
			}
		}
	}
	
	override public function kill(i:Int):Void {
		switch(Obj.entities[i].type) {
			case "boss":
				if (Obj.entities[i].para == 0) {
					if(Game.currentweapon=="swordgun"){
						Music.playef("hurtboss");
						Gfx.screenshake = 10;
						Gfx.flashlight = 5;
						Obj.entities[i].para = 1;
					}
				}else if (Obj.entities[i].para == 1) {
					if(Game.currentweapon=="dashgun"){
						Music.playef("hurtboss");
						Gfx.screenshake = 10;
						Gfx.flashlight = 5;
						Obj.entities[i].para = 2;
					}
				}else if (Obj.entities[i].para == 2) {
					if(Game.currentweapon=="shootgun"){
						Music.playef("hurtboss");
						Gfx.screenshake = 10;
						Gfx.flashlight = 5;
						Obj.entities[i].para = 3;
					}
				}else if (Obj.entities[i].para == 3) {
					if (Game.bossbomb) {
						Music.playef("hurtboss");
						Gfx.screenshake = 10;
						Gfx.flashlight = 5;
						Obj.entities[i].para = 4;
				  }
				}else if (Obj.entities[i].para == 4) {
					if(Game.currentweapon=="wallgun"){
						Music.playef("hurtboss");
						Gfx.screenshake = 10;
						Gfx.flashlight = 5;
						Obj.entities[i].para = 5;
				  }
				}else if (Obj.entities[i].para == 5) {
					if(Game.currentweapon=="deathgun"){
						Music.playef("killboss");
						Gfx.screenshake = 10;
						Gfx.flashlight = 5;
						
						World.placetile(Std.int(Obj.entities[i].xp), Std.int(Obj.entities[i].yp), Localworld.BLOOD);
						Obj.entities[i].active = false;
						
						Game.changeweapon("lifegun");
						Game.score++;
						Game.bossbomb = true;
				  }
				}
				
				
				
			case "actualbomb":
				//can't be killed
			case "runnerguy":
				Music.playef("killenemy");
				
				World.placetile(Std.int(Obj.entities[i].xp), Std.int(Obj.entities[i].yp), Localworld.BLOOD);
				Obj.entities[i].active = false;
				Gfx.screenshake = 10;
				Gfx.flashlight = 5;
				
				Game.changeweapon("deathgun");
				Game.score++;
			case "builderguy":
				Music.playef("killenemy");
				
				World.placetile(Std.int(Obj.entities[i].xp), Std.int(Obj.entities[i].yp), Localworld.BLOOD);
				Obj.entities[i].active = false;
				Gfx.screenshake = 10;
				Gfx.flashlight = 5;
				
				Game.changeweapon("wallgun");
				Game.score++;
			case "bombguy":
				Music.playef("killenemy");
				
				World.placetile(Std.int(Obj.entities[i].xp), Std.int(Obj.entities[i].yp), Localworld.BLOOD);
				Obj.entities[i].active = false;
				Gfx.screenshake = 10;
				Gfx.flashlight = 5;
				
				Game.changeweapon("bombgun");
				Game.score++;
			case "gunguy":
				Music.playef("killenemy");
				
				World.placetile(Std.int(Obj.entities[i].xp), Std.int(Obj.entities[i].yp), Localworld.BLOOD);
				Obj.entities[i].active = false;
				Gfx.screenshake = 10;
				Gfx.flashlight = 5;
				
				Game.changeweapon("shootgun");
				Game.score++;
			case "snakeguy":
				Music.playef("killenemy");
				
				World.placetile(Std.int(Obj.entities[i].xp), Std.int(Obj.entities[i].yp), Localworld.BLOOD);
				Obj.entities[i].active = false;
				Gfx.screenshake = 10;
				Gfx.flashlight = 5;
				
				Game.changeweapon("dashgun");
				Game.score++;
			case "swordguy":
				Music.playef("killenemy");
				
				World.placetile(Std.int(Obj.entities[i].xp), Std.int(Obj.entities[i].yp), Localworld.BLOOD);
				Obj.entities[i].active = false;
				Gfx.screenshake = 10;
				Gfx.flashlight = 5;
				
				Game.changeweapon("swordgun");
				Game.score++;
		}
	}
	
	override public function animate(i:Int):Void {
		if(Obj.entities[i].active){
			switch(Obj.entities[i].type) {
				case "boss":
					switch(Obj.entities[i].para) {
						case 0:
							Obj.entities[i].col = 0xFF4444;
						case 1:
							Obj.entities[i].col = 0x44FF44;
						case 2:
							Obj.entities[i].col = 0xFFFF44;
						case 3:
							Obj.entities[i].col = 0x4444FF;
						case 4:
							Obj.entities[i].col = 0xFF44FF;
						case 5:
							Obj.entities[i].col = Draw.messagecol("rainbow");
					}
				case "runnerguy":
					Obj.entities[i].col = Draw.messagecol("rainbow");
					if (Obj.entities[i].stunned > 0) {
						Obj.entities[i].col = 0x888888;
					}
				case "builderguy":
					Obj.entities[i].col = 0xFF44FF;
					if (Obj.entities[i].stunned > 0) {
						Obj.entities[i].col = 0x888888;
					}
				case "bombguy":
					Obj.entities[i].col = 0x4444FF;
					if (Obj.entities[i].stunned > 0) {
						Obj.entities[i].col = 0x888888;
					}
				case "actualbomb":
					if (Help.tenseconds % 60 >= 45) {
						Obj.entities[i].tile = 149;
					}else {
						Obj.entities[i].tile = Std.string(Obj.entities[i].para).charCodeAt(0);
						for (k in -1 ... 2) {
							for (j in -1 ... 2) {
								Localworld.highlightpoint(Obj.entities[i].xp + k, Obj.entities[i].yp + j);
							}
						}
					}
						
					if (Help.slowsine % 32 >= 16) {
						Obj.entities[i].col = 0x4444FF;
					}else {
						Obj.entities[i].col = 0xFFFFFF;
					}
					
					if (Obj.entities[i].stunned > 0) {
						Obj.entities[i].col = 0x888888;
					}
				case "gunguy":
					switch(Obj.entities[i].dir) {
						case Help.UP:
							Obj.entities[i].tile = 24;
						case Help.DOWN:
							Obj.entities[i].tile = 25;
						case Help.LEFT:
							Obj.entities[i].tile = 27;
						case Help.RIGHT:
							Obj.entities[i].tile = 26;
					}
					Obj.entities[i].col = 0xFFFF44;
					/*
					if (Obj.entities[i].stunned > 0) {
						Obj.entities[i].col = 0x888888;
					}*/
				case "snakeguy":
					//Obj.entities[i].tile = "G".charCodeAt(0);
					Obj.entities[i].col = 0x44FF44;
					if (Obj.entities[i].stunned > 0) {
						Obj.entities[i].col = 0x888888;
					}
					
					if (Game.speedframe % 3 == 2) {
						if (Help.slowsine % 16 >= 8) {
							Obj.entities[i].col = 0x44FF44;
						}else {
							Obj.entities[i].col = 0xFFFFFF;
						}
					}
					
					/*
					if (Help.tenseconds % 60 >= 45) {
					}else {
						Localworld.highlightpoint(Obj.entities[i].xp - 1, Obj.entities[i].yp);
						Localworld.highlightpoint(Obj.entities[i].xp + 1, Obj.entities[i].yp);
						Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp - 1);
						Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp + 1);
					}
					*/
				case "swordguy":
					//Obj.entities[i].tile = "G".charCodeAt(0);
					Obj.entities[i].col = 0xFF4444;
					if (Obj.entities[i].stunned > 0) {
						Obj.entities[i].col = 0x888888;
					}
			}
		}
		Obj.entities[i].drawframe = Obj.entities[i].tile;
	}
	
	override public function drawentity(i:Int):Void {
		if (Obj.entities[i].type == "swordguy") {
			Gfx.draw_default(i);
			/*
			switch(Obj.entities[i].dir) {
				case Help.UP:
					Gfx.drawtile_col(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - 1 - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, 179, 0xFFFFFF);
				case Help.DOWN:
					Gfx.drawtile_col(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp + 1 - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, 179, 0xFFFFFF);
				case Help.LEFT:
					Gfx.drawtile_col(Std.int(Obj.entities[i].xp - 1 - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, 196, 0xFFFFFF);
				case Help.RIGHT:
					Gfx.drawtile_col(Std.int(Obj.entities[i].xp + 1 - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, 196, 0xFFFFFF);
			}
			*/
		}else{
			Gfx.draw_default(i);
		}
	}
	
	override public function drawinit(i:Int, xoff:Int, yoff:Int, frame:Int):Void {
		Gfx.draw_defaultinit(i, xoff, yoff, frame);
	}
	
	override public function collision(i:Int, j:Int):Void {
		//i is this entity, j is the other
	}
	
	override public function setupcollision(i:Int):Void {
		Gfx.changetileset(Obj.entities[i].tileset);
		
		Obj.entities[i].cx = 0;
		Obj.entities[i].cy = 0;
		Obj.entities[i].w = Gfx.tiles[Gfx.currenttileset].width;
		Obj.entities[i].h = Gfx.tiles[Gfx.currenttileset].height;
	}
}