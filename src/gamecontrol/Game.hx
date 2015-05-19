package gamecontrol;

import com.terry.*;
import config.*;
import openfl.display.*;
import openfl.events.*;
import openfl.geom.*;
import openfl.net.*;

class Game {
	public static var TITLEMODE:Int = 0;
	public static var CLICKTOSTART:Int = 1;
	public static var FOCUSMODE:Int = 2;
	public static var GAMEMODE:Int = 3;
	public static var NOW:Int = -1;
	
	public static function init():Void {
		numpossiblemoves = 0;
		for (i in 0 ... 50){
			possiblemove.push("nothing");
			possiblemovescore.push(0);
		}
		
		for (i in 0 ... 50) {
			enemyqueue.push(new Enemyqueue());
		}
		
		enemyqueuesize = 0;
		
		if (playbackrecording) {
			replayonrestart = true;
			recordstring = originalrecordstring;
		}
		
		bestscore = 0;
		
		playerdir = Help.RIGHT;
		
		Inventory.init();
	}
	
	public static function restartgame():Void {
		//Starts the entire game over. Get rid of reset eventually
		//Openworld.generate(Random.string(10));
		
		//Openworld.gotocamp();
		//start("outside");	
		liverecordstring = "";
		if (replayonrestart) {
			playbackrecording = true;
			recordposition = 0;
			gameseed = Std.parseInt(Help.getroot(originalrecordstring, "_"));
			recordstring = Help.getbranch(recordstring, "_");
		}
		
		if (gameseed == -1) {
			Random.setseed(Std.int(Math.random() * 233280));
		}else {
			Random.setseed(gameseed);
		}
		
		record(Std.string(Random.seed) + "_");
		
		Music.playef("intro");
		
		gameover = false;
		message = "";
		messagedelay = 0;
		bossbomb = false;
		Localworld.generate("ludumdare");
		
		enemyqueuesize = 0;
		speedframe = 0;
		nukedelay = 0;
		ascenddelay = 0;
		playerbomb = 0;
		
		Obj.nentity = 0;
		Game.health = 1;
		if (Game.score > Game.bestscore) Game.bestscore = Game.score;
		Game.score = 0;
		
		Obj.createentity(Random.pint(6,18), Random.pint(4,6), "player");
		placeatborder("enemy", "swordguy", NOW);
		placeatborder("enemy", "swordguy", NOW);
		
		Inventory.numitems = 0;
		Inventory.giveitem("swordgun");
		Inventory.giveitem("dashgun");
		Inventory.giveitem("shootgun");
		Inventory.giveitem("bombgun");
		Inventory.giveitem("wallgun");
		Inventory.giveitem("deathgun");
		Inventory.giveitem("lifegun");
		Game.changeweapon("none");
		
		Game.changeweapon(Random.ppickstring("dashgun", "swordgun", "shootgun"));
		//Game.changeweapon("swordgun");
		//Game.changeweapon("wallgun");
		
		Game.turn = "playermove";
		
		Localworld.updatelighting();
		enemycountdown = 4;
	}
	
	public static function destroywall(i:Int, diroffset:Int = 0):Void {
		tx = Obj.entities[i].xp;
		ty = Obj.entities[i].yp;
		if (diroffset == 0) {
			tdir = Obj.entities[i].dir;
		}else{
			tdir = Help.clockwise(Obj.entities[i].dir, diroffset);
		}
		temp = checkforenemy(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir));
		if(temp == -2){
			World.placetile(tx + Localworld.xstep(tdir), Game.ty + Localworld.ystep(tdir), Localworld.FLOOR);
			Game.playbreakwall();
		}
	}
	
	public static function placewall(i:Int, diroffset:Int = 0):Void {
		tx = Obj.entities[i].xp;
		ty = Obj.entities[i].yp;
		if (diroffset == 0) {
			tdir = Obj.entities[i].dir;
		}else if (diroffset == 2) {
			tdir = Help.oppositedirection(Obj.entities[i].dir);
		}else{
			tdir = Help.clockwise(Obj.entities[i].dir, diroffset);
		}
		temp = checkforenemy(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir));
		if(temp == -1){
			World.placetile(tx + Localworld.xstep(tdir), Game.ty + Localworld.ystep(tdir), Localworld.WALL);
		}
	}
	
	public static function start(t:String):Void {
	}
	
	/** True when there are no entities within 2 spaces of the entrance */
	public static function entranceclear():Bool {
		return true;
	}
	
	public static function runnerguyexists():Bool {
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].rule == "enemy") {
					if (Obj.entities[i].type == "runnerguy") {
						return true;
					}
				}
			}
		}
		
		for (i in 0 ... enemyqueuesize) {
			if (enemyqueue[i].type == "runnerguy") {
				return true;
			}
		}
		
		return false;
	}
	
	/** How many enemies are currently on the map? */
	public static function numberofenemies():Int {
		var temp:Int = 0;
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].rule == "enemy") {
					if (Obj.entities[i].type != "runnerguy") {
						temp++;
					}
				}
			}
		}
		
		return temp + enemyqueuesize;
	}
	
	public static function placeatborder(rule:String, type:String = "", speed:Int = 3):Void {
		if (type == "bombguy") {
			//Bombguys are no fun. Quick kludge to make them a different enemy instead 50% of the time
			if (Random.pbool()) {
				type = Random.ppickstring("swordguy", "gunguy", "snakeguy", "builderguy");
			}
		}
		if (type == "runnerguy") {
			//There should only ever be one runnerguy. If there's already one in the queue
			//or on screen, change it to something else
			if (runnerguyexists()) {
				trace("a runner guy exists, but we already have one.");
				type = Random.ppickstring("swordguy", "gunguy", "snakeguy", "builderguy");
			}
		}
		tx = -1;
		var player:Int = Obj.getplayer();
		while (tx == -1 || World.at(tx, ty) != Localworld.FLOOR) {
			if (Random.pbool()) {
				//Horizontal
				if (Random.pbool() && Obj.entities[player].yp != 0) {
					//Top
					tx = Random.pint(2, World.mapwidth-3);
					ty = 0;
				}else {
					//Bottom
					tx = Random.pint(2, World.mapwidth - 3);
					ty = World.mapheight - 1;
				}
			}else {
				if (Random.pbool() && Obj.entities[player].xp != 0) {
					//Left
					tx = 0;
					ty = Random.pint(2, World.mapheight - 3);
				}else {
					//Right
					tx = World.mapwidth - 1;
					ty = Random.pint(2, World.mapheight - 3);
				}
			}
		}
		
		var dir:String = "";
		if (tx == 0) dir = "right";
		if (tx == World.mapwidth - 1) dir = "left";
		if (ty == 0) dir = "down";
		if (ty == World.mapheight - 1) dir = "up";
		
		if (!queuecollision(tx, ty)) {
			addtoqueue(tx, ty, rule, type, speed, dir);
		}else {
			placeatborder(rule, type, speed);
		}
	}
	
	public static function queuecollision(x:Int, y:Int):Bool {
		for (i in 0 ... enemyqueuesize) {
			if (enemyqueue[i].x == x && enemyqueue[i].y == y) {
				return true;
			}
		}
		return false;
	}
	
	public static function addtoqueue(x:Int, y:Int, r:String, t:String, speed:Int, dir:String):Void {
		if (speed == -1) {
			Obj.createentity(x, y, r, t, dir);
		}else {
			enemyqueue[enemyqueuesize].add(x, y, r, t, speed, dir);
			enemyqueuesize++;
		}
	}
	
	public static function updatequeue():Void {
		var i:Int = 0;
		while(i < enemyqueuesize){
			enemyqueue[i].speed--;
			if (enemyqueue[i].speed <= 0) {
				Obj.createentity(enemyqueue[i].x, enemyqueue[i].y, enemyqueue[i].rule, enemyqueue[i].type, enemyqueue[i].dir);
				removefromqueue(i);
			}else {
				i++;
			}
		}
	}
	
	public static function removefromqueue(t:Int):Void {
		if (t >= enemyqueuesize-1) {
			enemyqueuesize--;
		}else{
			for (i in t ... enemyqueuesize) {
				enemyqueue[i].add(enemyqueue[i + 1].x, enemyqueue[i + 1].y, enemyqueue[i + 1].rule, enemyqueue[i + 1].type, enemyqueue[i + 1].speed, enemyqueue[i + 1].dir);
			}
			enemyqueuesize--;
		}
	}
	
	public static function fadelogic():Void {
		if (Gfx.fademode == Gfx.FADED_IN && Obj.activedoor != "null") {
			Gfx.fademode = Gfx.FADE_OUT; Gfx.fadeaction = "changeroom";
			Obj.activedoordest = Obj.activedoor;
		}
	}
	
	public static function changestate(state:Int):Void {
		gamestate = state;
	}
	
	public static function sortpossiblemoves():Void {
		//Sort possible moves by highest scoring to lowest
		var tempint:Int;
		var tempstring:String;
		
		for (j in 0 ... numpossiblemoves) {
			for (i in j ... numpossiblemoves) {
				if (possiblemovescore[i] < possiblemovescore[j]) {
					tempint = possiblemovescore[i];
					possiblemovescore[i] = possiblemovescore[j];
					possiblemovescore[j] = tempint;
					
					tempstring = possiblemove[i];
					possiblemove[i] = possiblemove[j];
					possiblemove[j] = tempstring;
				}
			}
		}
	}
	
	public static function weaponname():String {
	  if (currentweapon == "swordgun") return "SWORD";
		if (currentweapon == "dashgun") return "DASHER";
		if (currentweapon == "shootgun") return "GUN";
		if (currentweapon == "bombgun") return "BOMBS";
		if (currentweapon == "wallgun") return "BUILDER";
		if (currentweapon == "deathgun") return "DEATH";
		if (currentweapon == "lifegun") return "ASCEND";
		return "???";
	}

	
	public static function changeweapon(t:String, alert:Bool = true):Void {
		if(t != currentweapon){
			currentweapon = t;
			Inventory.setequippedgadget(t);
			var player:Int = Obj.getplayer();
			
			switch(t) {
				case "swordgun":
					//showmessage("SWORD!", "red");
					weaponbacking = Gfx.RGB(64, 0, 0);
					playerbacking = Gfx.RGB(255, 0, 0);
					weaponcol = "red";
					Obj.entities[player].lightsource = "none";
					
					Game.destroywall(player);
				case "shootgun":
					//showmessage("GUN!", "yellow");
					weaponbacking = Gfx.RGB(64, 64, 0);
					playerbacking = Gfx.RGB(255, 255, 0);
					weaponcol = "yellow";
					Obj.entities[player].lightsource = "laser_narrow";
				case "dashgun":
					//showmessage("DASHER!", "green");
					weaponbacking = Gfx.RGB(0, 64, 0);
					playerbacking = Gfx.RGB(0, 255, 0);
					weaponcol = "green";
					Obj.entities[player].lightsource = "none";
				case "bombgun":
					//showmessage("DASHER!", "green");
					weaponbacking = Gfx.RGB(0, 0, 64);
					playerbacking = Gfx.RGB(0, 0, 255);
					weaponcol = "blue";
					Obj.entities[player].lightsource = "none";
				case "wallgun":
					weaponbacking = Gfx.RGB(64, 0, 64);
					playerbacking = Gfx.RGB(255, 0, 255);
					weaponcol = "purple";
					Obj.entities[player].lightsource = "none";
					
					//Wall gun places walls in front of player
					if (Game.currentweapon == "wallgun") {
						var player:Int = Obj.getplayer();
						Game.tx = Obj.entities[player].xp;
						Game.ty = Obj.entities[player].yp;
						Game.tdir = Obj.entities[player].dir;
						
						Game.tx += Localworld.xstep(Game.tdir);
						Game.ty += Localworld.ystep(Game.tdir);
						
						temp = checkforenemy(Game.tx, Game.ty);
						if (temp >= 0) {
							killenemy(temp);
						}
						
						World.placetile(Game.tx, Game.ty, Localworld.WALL);
					}
				case "deathgun":
					//showmessage("DASHER!", "green");
					weaponbacking = Gfx.RGB(64, 64, 64);
					playerbacking = Gfx.RGB(255, 255, 255);
					weaponcol = "rainbow";
					Obj.entities[player].lightsource = "none";
				case "lifegun":
					//showmessage("DASHER!", "green");
					weaponbacking = Gfx.RGB(64, 64, 64);
					playerbacking = Gfx.RGB(255, 255, 255);
					weaponcol = "life";
					Obj.entities[player].lightsource = "none";
				default:
					weaponbacking = Gfx.RGB(64, 64, 64);
					playerbacking = Gfx.RGB(255, 255, 255);
					weaponcol = "white";
					Obj.entities[player].lightsource = "none";
			}
		}
	}
	
	public static function removemovesbelownothing():Void {
		//Remove moves below "nothing". Depends on one of the moves actually being "nothing".
		if (numpossiblemoves > 0) {
			if (possiblemove[numpossiblemoves - 1] != "nothing") {
				numpossiblemoves--;
				removemovesbelownothing();
			}
		}
	}
	
	/** Convert Help.DIR to Game's format "move_dir" */
	public static function movestring(t:Int):String {
		if (t == Help.UP) return "move_up";
		if (t == Help.DOWN) return "move_down";
		if (t == Help.LEFT) return "move_left";
		if (t == Help.RIGHT) return "move_right";
		return "nothing";
	}
	
	
	public static function reversemovestring(t:String):Int {
		if (t == "move_up") return Help.UP;
		if (t == "move_down") return Help.DOWN;
		if (t == "move_left") return Help.LEFT;
		if (t == "move_right") return Help.RIGHT;
		return Help.NODIRECTION;
	}
	
	public static function resetplayermove(i:Int, t:String):Void {
		Obj.entities[i].revertdir = Obj.entities[i].dir;
		oldx = Obj.entities[i].xp;
		oldy = Obj.entities[i].yp;
		Obj.entities[i].resetactions();
		lastplayeraction = t;
		Obj.entities[i].addaction(lastplayeraction);
		tickthisframe = false;
		dasheffectthisframe = false;
		breakwallthisframe = false;
	}

	public static function startmove(t:String):Void {
		resetplayermove(Obj.getplayer(), t);
		turn = "doplayermove";
	}
	
	public static function killenemy(target:Int):Void {
		Obj.templates[Obj.entindex.get(Obj.entities[target].rule)].kill(target);
	}
	
	public static function stunenemy(target:Int, time:Int):Void {
		Obj.templates[Obj.entindex.get(Obj.entities[target].rule)].stun(target, time);
	}
	
	public static function allenemiesdead():Bool {
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].rule == "enemy") {
					return false;
				}
			}
		}
		return true;
	}
	
	public static function hurtplayer():Void {
		//trace("hurtplayer called");
		health--;
		Obj.entities[Obj.getplayer()].health--;
		Gfx.screenshake = 10;
		Gfx.flashlight = 5;
	}
	
	public static function checkifplayerdead():Void {
		if (Obj.entities[Obj.getplayer()].health <= 0) {
			World.placetile(Obj.entities[Obj.getplayer()].xp, Obj.entities[Obj.getplayer()].yp, Localworld.RUBBLE);
			Obj.entities[Obj.getplayer()].active = false;
			
			Music.playef("dead");
			showmessage("GAME OVER", "red", -1);
			gameover = true;
		}
		Localworld.updatelighting();
	}
	
	public static function doenemyattack():Void {
		//If the player's ended a turn beside an enemy, take damage...
		tx = Std.int(Obj.entities[Obj.getplayer()].xp);
		ty = Std.int(Obj.entities[Obj.getplayer()].yp);
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].rule == "enemy") {
					//if (Obj.entities[i].state == 1) {
					if (Obj.entities[i].canattack) {
						if (adjacent(tx, ty, Std.int(Obj.entities[i].xp), Std.int(Obj.entities[i].yp))) {
							hurtplayer();
						}
					}
				}
			}
		}
		
		checkifplayerdead();
	}
	
	public static function clearchain():Void {
		for (i in 0 ... Obj.nentity) {
			Obj.entities[i].inchain = false;
		}
	}
	
	public static function resetenemymove(i:Int):Void {
		if (Obj.entities[i].rule == "enemy") {
			Obj.entities[i].action = "nothing";
			Obj.entities[i].actionset = false;
			Obj.entities[i].userevertdir = false;
			
			doenemyai(i);
		}
	}
	
	public static function resetenemymoves():Void {
		Game.speedframe = Game.speedframe+1;
		if (Game.speedframe == 12) Game.speedframe = 0;
		
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				Obj.entities[i].alerted_thisframe = false;
			  //Obj.updateentities(i);
				resetenemymove(i);
			}
		}
	}
	
	public static function cantmove():Void {
		var player:Int = Obj.getplayer();
		Obj.entities[player].dir = Obj.entities[player].revertdir;
		
		Obj.entities[player].xp = oldx;
		Obj.entities[player].yp = oldy;
		
		Game.speedframe += 11;
		if (Game.speedframe >= 12) Game.speedframe -= 12;
		
		Music.playef("blocked");
		Gfx.screenshake = 5;
	}
	
	public static function findpathtopoint(t:Int, xoff:Int, yoff:Int, x:Int, y:Int):Void {
		Astar.setmapcollision();
		
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (i != t) {
					Astar.setcollidepoint(getintendedx(i), getintendedy(i));
				}
			}
		}
		
		Astar.pathfind(x, y, getcurrentx(t) + xoff, getcurrenty(t) + yoff);
	}
	
	public static function findpathtocenter(a:Int):Void {
		Astar.setmapcollision();
		
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active && Obj.entities[i].collidable) {
				if (i != a) {
					Astar.setcollidepoint(getintendedx(i), getintendedy(i));	
				}
			}
		}
		
		Astar.pathfind(12, 5, getcurrentx(a), getcurrenty(a));
	}
	
	public static function findpathbetween(a:Int, b:Int):Void {
		Astar.setmapcollision();
		
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active && Obj.entities[i].collidable) {
				if (i != a && i != b) {
					Astar.setcollidepoint(getintendedx(i), getintendedy(i));	
				}
			}
		}
		
		Astar.pathfind(getcurrentx(b), getcurrenty(b), getcurrentx(a), getcurrenty(a));
	}
	
	public static function adjacent(x1:Int, y1:Int, x2:Int, y2:Int):Bool {
		if (x1 == x2 && y1 == y2) return true;
		if (x1 == x2-1 && y1 == y2) return true;
		if (x1 == x2+1 && y1 == y2) return true;
		if (x1 == x2 && y1 == y2+1) return true;
		if (x1 == x2 && y1 == y2-1) return true;
		return false;
	}
	
	/** Can an entity of speed t move this turn? */
	public static function turnspeed(t):Bool {
		if (t == 0) return true;
		if (t == 1) if (speedframe % 2 == 0) return true;
		if (t == 2) if (speedframe % 3 == 0) return true;
		if (t == 3) if (speedframe % 4 == 0) return true;
		return false;
	}
	
	/** Setup Game's tx, ty and tdir variables for entity t */
	public static function settempobjvariables(t:Int):Void {
		tx = Obj.entities[t].xp;
		ty = Obj.entities[t].yp;
		tdir = Obj.entities[t].dir;
	}
	
	public static function getsimplemove(p:Int, e:Int):Int {
		if (Math.abs(Obj.entities[p].xp - Obj.entities[e].xp) < 4) {
			if (Obj.entities[p].yp < Obj.entities[e].yp) {
				return Help.UP;
			}else {
				return Help.DOWN;
			}
		}else {
			if (Obj.entities[p].xp < Obj.entities[e].xp) {
				return Help.LEFT;
			}else {
				return Help.RIGHT;
			}
		}
		return Help.randomdirection();
	}
	
	/** In this function, enemies decide what they're going to do this turn. */
	public static function doenemyai(i:Int):Void {
		var player:Int;
		var nextmove:Int;
		player = Obj.getplayer();
		
		Obj.entities[i].resetactions();
		if (Obj.entities[i].rule == "enemy") {
			//So, AI works like this: there is a big picture thing that the entity is
			//trying to do, which breaks down to smaller picture next move stuff.
			//For example, an entity might want to get in line with the player and shoot.
			if (turnspeed(Obj.entities[i].speed)) {
				if(Obj.entities[i].stunned==0){
					switch(Obj.entities[i].ai) {
						case "random":
							tdir = Help.randomdirection();
							Obj.entities[i].addaction(movestring(tdir));
						case "pathfind":
							//Pathfind to enemy - only accept useful paths
							//If the enemy is going to be adjacent to where the player is headed, DON'T MOVE
							if (adjacent(getdestinationx(player, Obj.entities[player].possibleactions[0]), getdestinationy(player, Obj.entities[player].possibleactions[0]), getcurrentx(i), getcurrenty(i))) {
								//Turn to face the player.
								tx = Obj.entities[i].xp;
								ty = Obj.entities[i].yp;
								tdir = Obj.entities[i].dir;
								tx2 = Obj.entities[player].xp;
								ty2 = Obj.entities[player].yp;
								
								if (tx + Localworld.xstep(tdir) == tx2 && ty + Localworld.ystep(tdir) == ty2) {
									Obj.entities[i].addaction("wait");
								}else{
									tdir = Obj.entities[i].dir;
									tdir = Help.clockwise(tdir);
									if (tx + Localworld.xstep(tdir) == tx2 && ty + Localworld.ystep(tdir) == ty2) {
										Obj.entities[i].addaction("clockwise");
									}else {
										tdir = Obj.entities[i].dir;
										tdir = Help.anticlockwise(tdir);
										if (tx + Localworld.xstep(tdir) == tx2 && ty + Localworld.ystep(tdir) == ty2) {
											Obj.entities[i].addaction("anticlockwise");
										}else {
											if(Random.pbool()){
												Obj.entities[i].addaction("clockwise");
											}else {
												Obj.entities[i].addaction("anticlockwise");
											}
										}										
									}
								}
							}else{
								//findpathbetween(i, player);
								
								//nextmove = Astar.getnextmove();
								nextmove = Localworld.heatmapmovedir(Obj.entities[i].xp, Obj.entities[i].yp, Obj.entities[i].dir);
								if (nextmove == Help.NODIRECTION) {
									nextmove = getsimplemove(player, i);
									
									if (Obj.entities[i].type == "gunguy") {
										World.placetile(Obj.entities[i].xp + Localworld.xstep(nextmove), Obj.entities[i].yp + Localworld.ystep(nextmove), Localworld.FLOOR);
									}
								}
								
								if(Obj.entities[i].dir == nextmove){
									Obj.entities[i].addaction(movestring(nextmove));
								}else {
									if (Help.anticlockwise(Obj.entities[i].dir) == nextmove) {
										Obj.entities[i].addaction("anticlockwise");
									}else if (Help.clockwise(Obj.entities[i].dir) == nextmove) {
										Obj.entities[i].addaction("clockwise");
									}else {
										Obj.entities[i].addaction(Random.ppickstring("clockwise", "anticlockwise"));
									}
								}
							}
						case "pathfind_nodir":
							//Pathfind to enemy - only accept useful paths
							//If the enemy is going to be adjacent to where the player is headed, DON'T MOVE
							if (adjacent(getdestinationx(player, Obj.entities[player].possibleactions[0]), getdestinationy(player, Obj.entities[player].possibleactions[0]), getcurrentx(i), getcurrenty(i))) {
								Obj.entities[i].addaction("wait");
							}else{
								//findpathbetween(i, player);
								
								//nextmove = Astar.getnextmove();
								nextmove = Localworld.heatmapmovedir(Obj.entities[i].xp, Obj.entities[i].yp, Obj.entities[i].dir);
								if (nextmove == Help.NODIRECTION) {
									nextmove = getsimplemove(player, i);
									Obj.entities[i].addaction(movestring(nextmove));
									
									World.placetile(Obj.entities[i].xp + Localworld.xstep(nextmove), Obj.entities[i].yp + Localworld.ystep(nextmove), Localworld.FLOOR);
								}else {
									Obj.entities[i].addaction(movestring(nextmove));
								}
							}
						case "pathfind_away":
							//Pathfind to enemy - only accept useful paths
							//If the enemy is going to be adjacent to where the player is headed, DON'T MOVE
							if (adjacent(getdestinationx(player, Obj.entities[player].possibleactions[0]), getdestinationy(player, Obj.entities[player].possibleactions[0]), getcurrentx(i), getcurrenty(i))) {
								Obj.entities[i].addaction("wait");
							}else{
								//findpathbetween(i, player);
								
								//nextmove = Astar.getnextmove();
								nextmove = Localworld.heatmapmovedir_away(Obj.entities[i].xp, Obj.entities[i].yp, Obj.entities[i].dir);
								if (nextmove != Help.NODIRECTION) {
									Obj.entities[i].addaction(movestring(nextmove));
								}
							}
						case "pathfind_rush":
							//Pathfind to enemy - only accept useful paths
							//If the enemy is going to be adjacent to where the player is headed, DON'T MOVE
							//findpathbetween(i, player);
								
							//nextmove = Astar.getnextmove();
							nextmove = Localworld.heatmapmove(Obj.entities[i].xp, Obj.entities[i].yp);
							if (nextmove == Help.NODIRECTION) {
								nextmove = getsimplemove(player, i);
								World.placetile(Obj.entities[i].xp + Localworld.xstep(Obj.entities[i].dir), Obj.entities[i].yp + Localworld.ystep(Obj.entities[i].dir), Localworld.FLOOR);
								
								Obj.entities[i].addaction(movestring(nextmove));
							}else{
								Obj.entities[i].addaction("dash" + movestring(nextmove));
								//Obj.entities[i].ai = "pathfind_rush2";
							}
						case "pathfind_rush2":
							//Continue going the same way until the next step is a wall
							settempobjvariables(i);
							if (World.collide(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir))) {
								Obj.entities[i].addaction("wait");
								Obj.entities[i].ai = "pathfind_rush";
							}else {
								Obj.entities[i].addaction(movestring(Obj.entities[i].dir));
								Obj.entities[i].addaction(movestring(Help.clockwise(Obj.entities[i].dir)));
								Obj.entities[i].addaction(movestring(Help.oppositedirection(Obj.entities[i].dir)));
								Obj.entities[i].addaction(movestring(Help.anticlockwise(Obj.entities[i].dir)));
							}
						case "wander":
							//Pathfind to enemy - only accept useful paths
							//If the enemy is going to be adjacent to where the player is headed, DON'T MOVE
							//findpathbetween(i, player);
								
							//nextmove = Astar.getnextmove();
							nextmove = Localworld.heatmapmove(Obj.entities[i].xp, Obj.entities[i].yp);
							if (nextmove != Help.NODIRECTION) {
								Obj.entities[i].addaction(movestring(nextmove));
								Obj.entities[i].ai = "wander_2";
							}
						case "wander_2":
							//Continue going the same way until the next step is a wall
							settempobjvariables(i);
							Obj.entities[i].para--;
							if (World.collide(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir)) || Obj.entities[i].para <=0) {
								Obj.entities[i].addaction("wait");
								Obj.entities[i].ai = "wander";
								Obj.entities[i].para = Random.pint(3, 5);
							}else {
								Obj.entities[i].addaction(movestring(Obj.entities[i].dir));
								Obj.entities[i].addaction(movestring(Help.clockwise(Obj.entities[i].dir)));
								Obj.entities[i].addaction(movestring(Help.oppositedirection(Obj.entities[i].dir)));
								Obj.entities[i].addaction(movestring(Help.anticlockwise(Obj.entities[i].dir)));
							}
						case "gotocenter":
							//Pathfind to enemy - only accept useful paths
							//If the enemy is going to be adjacent to where the player is headed, DON'T MOVE
							//findpathbetween(i, player);
								
							//nextmove = Astar.getnextmove();
							findpathtocenter(i); 
								
							nextmove = Astar.getnextmove();
							if (nextmove != Help.NODIRECTION) {
								Obj.entities[i].addaction(movestring(nextmove));
							}else {
								Obj.entities[i].ai = "none";
							}
					}
				}else {
					Obj.entities[i].addaction("wait");
				}
			}else {
				Obj.entities[i].addaction("wait");
			}
		}
	}
	
	public static function dashmove(i:Int):Void {
		Game.playdasheffect();
		
		tx = Obj.entities[i].xp;
		ty = Obj.entities[i].yp;
		tdir = Obj.entities[i].dir;
		
		World.placetile(tx, ty, Localworld.WALL);
		
		temp = Game.checkforentity(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir));
		
		if (currentweapon == "swordgun") {
			var player:Int = Obj.getplayer();
			if (Obj.entities[player].active) {
				swordx = Obj.entities[player].xp;
				swordy = Obj.entities[player].yp;
				swordx = swordx + Localworld.xstep(Obj.entities[player].dir);
				swordy = swordy + Localworld.ystep(Obj.entities[player].dir);
			}
		}else {
			swordx = -100; swordy = -100;
		}
		
		while (temp != -2) {
			if (tx == swordx && ty == swordy) {
				killenemy(i);
				temp = -2;
			}
			if (temp >= 0) {
				if (Obj.entities[temp].rule == "player") {
					hurtplayer();
					checkifplayerdead();
					temp = -2;
				}else{
					tx = tx - Localworld.xstep(tdir); 
					ty = ty - Localworld.ystep(tdir);
					temp = -2;
				}
			}
			
			Localworld.highlightpoint(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir));
			Obj.entities[i].xp = tx + Localworld.xstep(tdir); 
			Obj.entities[i].yp = ty + Localworld.ystep(tdir);
			tx = Obj.entities[i].xp;
			ty = Obj.entities[i].yp;
			if (temp != -2) temp = Game.checkforentity(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir));
		}
		/*
		if (temp == -2) {
			World.placetile(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir), Localworld.FLOOR);
		}
		*/
	}
	
	public static function enemywaves():Void {
		//swordguy
		//gunguy
		//snakeguy
		//bombguy
		//builderguy
		//runnerguy
		if(score<8){
			Game.enemycountdown = 12;
			Game.placeatborder("enemy", Random.ppickstring(
				"swordguy", "swordguy", 
				"gunguy",  
				"snakeguy"));
		}else if (score < 12) {
			Game.enemycountdown = 11;
			Game.placeatborder("enemy", Random.ppickstring(
				"swordguy", "swordguy", 
				"gunguy",  "gunguy", 
				"snakeguy",
				"bombguy", "bombguy"));
		}else if (score < 15) {
			Game.enemycountdown = 11;
			Game.placeatborder("enemy", Random.ppickstring(
				"swordguy", "swordguy", 
				"gunguy",  "gunguy", 
				"snakeguy",
				"bombguy", "builderguy"));
		}else if (score < 20) {
			Game.enemycountdown = 10;
			Game.placeatborder("enemy", Random.ppickstring(
				"swordguy", 
				"gunguy",  "gunguy", 
				"snakeguy",
				"bombguy", "builderguy"));
		}else{
			Game.enemycountdown = 10;
			if (numberofenemies() < 4) Game.placeatborder("enemy", Random.ppickstring("swordguy", "gunguy"));
			Game.placeatborder("enemy", Random.ppickstring(
				"swordguy", "swordguy",
				"gunguy",  "gunguy", 
				"snakeguy",
				"bombguy", "builderguy", "runnerguy"));
		}
	}
	
	public static function bossingame():Bool {
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].type == "boss") {
					return true;
				}
			}
		}
		return false;
	}
	
	public static function getintendedx(i:Int):Int {
		//Return context sensitive x position: depending on 
		//where in the movement decision process they are
		if (Obj.entities[i].actionset) {
			return getdestinationx(i);
		}
		return getcurrentx(i);
	}
	
	public static function getintendedy(i:Int):Int {
		//Return context sensitive y position: depending on 
		//where in the movement decision process they are
		if (Obj.entities[i].actionset) {
			return getdestinationy(i);
		}
		return getcurrenty(i);
	}
	
	public static function getcurrentx(i:Int):Int {
		//return Obj.getgridpoint(Obj.entities[i].xp, Gfx.tiles[Gfx.currenttileset].height);
		return Std.int(Obj.entities[i].xp);
	}
	
	public static function getcurrenty(i:Int):Int {
		//return Obj.getgridpoint(Obj.entities[i].yp, Gfx.tiles[Gfx.currenttileset].height);
		return Std.int(Obj.entities[i].yp);
	}
	
	public static function getdestinationx(i:Int, movestring:String=""):Int {
		//tx = Obj.getgridpoint(Obj.entities[i].xp, Gfx.tiles[Gfx.currenttileset].width);
		tx = Std.int(Obj.entities[i].xp);
		
		if (movestring != "") {
			if (movestring == "move_left") tx--;
			if (movestring == "move_right") tx++;
			if (movestring == "dashmove_left") tx--;
			if (movestring == "dashmove_right") tx++;
			if (movestring == "backwardsmove_left") tx--;
			if (movestring == "backwardsmove_right") tx++;
			if (movestring == "doublemove_left") tx-=2;
			if (movestring == "doublemove_right") tx+=2;
		}else{			
			if (Obj.entities[i].action == "move_left") tx--;
			if (Obj.entities[i].action == "move_right") tx++;
			if (Obj.entities[i].action == "dashmove_left") tx--;
			if (Obj.entities[i].action == "dashmove_right") tx++;
			if (Obj.entities[i].action == "backwardsmove_left") tx--;
			if (Obj.entities[i].action == "backwardsmove_right") tx++;
			if (Obj.entities[i].action == "doublemove_left") tx-=2;
			if (Obj.entities[i].action == "doublemove_right") tx+=2;
		}
		
		return tx;
	}
	
	public static function getdestinationy(i:Int, movestring:String=""):Int {
		//ty = Obj.getgridpoint(Obj.entities[i].yp, Gfx.tiles[Gfx.currenttileset].height);
		ty = Std.int(Obj.entities[i].yp);
		
		if (movestring != "") {
			if (movestring == "move_up") ty--;
			if (movestring == "move_down") ty++;
			if (movestring == "dashmove_up") ty--;
			if (movestring == "dashmove_down") ty++;
			if (movestring == "backwardsmove_up") ty--;
			if (movestring == "backwardsmove_down") ty++;
			if (movestring == "doublemove_up") ty-=2;
			if (movestring == "doublemove_down") ty+=2;
		}else{			
			if (Obj.entities[i].action == "move_up") ty--;
			if (Obj.entities[i].action == "move_down") ty++;
			if (Obj.entities[i].action == "dashmove_up") ty--;
			if (Obj.entities[i].action == "dashmove_down") ty++;
			if (Obj.entities[i].action == "backwardsmove_up") ty--;
			if (Obj.entities[i].action == "backwardsmove_down") ty++;
			if (Obj.entities[i].action == "doublemove_up") ty-=2;
			if (Obj.entities[i].action == "doublemove_down") ty+=2;
		}
		
		return ty;
	}
	
	public static function getdestinationx2(i:Int, movestring:String=""):Int {
		//tx = Obj.getgridpoint(Obj.entities[i].xp, Gfx.tiles[Gfx.currenttileset].width);
		tx = Std.int(Obj.entities[i].xp);
		
		if (movestring != "") {
			if (movestring == "move_left") tx-=2;
			if (movestring == "move_right") tx+=2;
			if (movestring == "backwardsmove_left") tx-=1;
			if (movestring == "backwardsmove_right") tx+=1;
		}else{			
			if (Obj.entities[i].action == "move_left") tx-=2;
			if (Obj.entities[i].action == "move_right") tx+=2;
			if (Obj.entities[i].action == "backwardsmove_left") tx-=1;
			if (Obj.entities[i].action == "backwardsmove_right") tx+=1;
		}
		
		return tx;
	}
	
	public static function getdestinationy2(i:Int, movestring:String=""):Int {
		//ty = Obj.getgridpoint(Obj.entities[i].yp, Gfx.tiles[Gfx.currenttileset].height);
		ty = Std.int(Obj.entities[i].yp);
		
		if (movestring != "") {
			if (movestring == "move_up") ty-=2;
			if (movestring == "move_down") ty+=2;
			if (movestring == "backwardsmove_up") ty-=1;
			if (movestring == "backwardsmove_down") ty+=1;
		}else{			
			if (Obj.entities[i].action == "move_up") ty-=2;
			if (Obj.entities[i].action == "move_down") ty+=2;
			if (Obj.entities[i].action == "backwardsmove_up") ty-=1;
			if (Obj.entities[i].action == "backwardsmove_down") ty+=1;
		}
		
		return ty;
	}
	
	/** Return true if a and b are opposite direction strings */
	public static function oppositedirstring(a:String, b:String):Bool {
		if (a == "up" && b == "down") return true;
		if (a == "down" && b == "up") return true;
		if (a == "left" && b == "right") return true;
		if (a == "right" && b == "left") return true;
		return false;
	}
	
	/** Return the opposite direction move string */
	public static function oppositedirmovestring(a:String):String {
		if (a == "move_up") return "move_down";
		if (a == "move_down") return "move_up";
		if (a == "move_left") return "move_right";
		if (a == "move_right") return "move_left";
		return "nothing";
	}
	
	public static function couldtry(xoff:Int, yoff:Int, i:Int):Bool {
		if (!World.collide(xoff, yoff)) {
			for (j in 0 ... Obj.nentity) {
				if (i != j) {
					if (Obj.entities[j].active) {
						tx2 = getdestinationx(j); ty2 = getdestinationy(j);
						if (xoff == tx2 && yoff == ty2) return true;
					}
				}
			}
		}else {
			return true;
		}
		
		return false;
	}
	
	public static function couldtryagain(i:Int):Bool {
		//An entity can try to move again if they've got an empty square adjacent.
		var mleft:Int = 0, mright:Int = 0, mup:Int = 0, mdown:Int = 0;
		tx1 = getcurrentx(i); ty1 = getcurrenty(i);
		
		mup = couldtry(tx1, ty1 - 1, i)?1:0;
		mdown = couldtry(tx1, ty1 + 1, i)?1:0;
		mleft = couldtry(tx1 - 1, ty1, i)?1:0;
		mright = couldtry(tx1 + 1, ty1, i)?1:0;
		
		if (mleft + mright + mup + mdown == 4) return false;
		return true;
	}
	
	public static function figureoutmove(i:Int):Void {
		//Pick a move at random from this entities available list
		//trace("Figuring out entity ", Std.string(i), ", " + Obj.entities[i].type);
		if (Obj.entities[i].numpossibleactions == 0) {
			Obj.entities[i].action = "nothing";
			Obj.entities[i].actionset = true;
			//trace("  Out of moves, do nothing.");
		}else {
			if (!Obj.entities[i].actionset) {
				//tx = Std.int(Math.random() * Obj.entities[i].numpossibleactions);
				tx = 0;
				tempstring = Obj.entities[i].possibleactions[tx];
				if (Help.getroot(tempstring, "_") == "move" || 
				    Help.getroot(tempstring, "_") == "dashmove" || 
				    Help.getroot(tempstring, "_") == "backwardsmove" || 
				    Help.getroot(tempstring, "_") == "backwardsdoublemove" || 
						Help.getroot(tempstring, "_") == "doublemove") {
					Obj.entities[i].rotatedir = Help.NODIRECTION;
					Obj.entities[i].action = tempstring;
					//trace("  Attempting ", Obj.entities[i].action);
				}else if (tempstring == "wait") {
					Obj.entities[i].rotatedir = Help.NODIRECTION;
					Obj.entities[i].action = "wait";
					Obj.entities[i].actionset = true;
				}else if (tempstring == "clockwise") {
					if (Obj.entities[i].rotatedir == Help.LEFT) {
						//really wanna avoid flicking back and forth, so do something else.
						Obj.entities[i].action = movestring(Obj.entities[i].dir);
						Obj.entities[i].rotatedir = Help.NODIRECTION;
					}else{
						Obj.entities[i].action = "clockwise";
						Obj.entities[i].actionset = true;
						Obj.entities[i].rotatedir = Help.RIGHT;
					}
				}else if (tempstring == "anticlockwise") {
					if (Obj.entities[i].rotatedir == Help.RIGHT) {
						//really wanna avoid flicking back and forth, so do something else.
						Obj.entities[i].action = movestring(Obj.entities[i].dir);
						Obj.entities[i].rotatedir = Help.NODIRECTION;
					}else{
						Obj.entities[i].action = "anticlockwise";
						Obj.entities[i].actionset = true;
						Obj.entities[i].rotatedir = Help.LEFT;
					}
				}else if (tempstring == "reverse_ai") {
					Obj.entities[i].rotatedir = Help.NODIRECTION;
					if (Obj.entities[i].ai == "anticlockwisefollowwall") {
						Obj.entities[i].ai = "clockwisefollowwall";
					}else if (Obj.entities[i].ai == "clockwisefollowwall") {
						Obj.entities[i].ai = "anticlockwisefollowwall";
					}
					Obj.entities[i].stringpara = Obj.entities[i].ai;
					Obj.entities[i].action = "nothing";
					Obj.entities[i].actionset = true;
				}else {
					//Do something other that move: for the moment, just do nothing
					Obj.entities[i].rotatedir = Help.NODIRECTION;
					Obj.entities[i].action = "nothing";
					Obj.entities[i].actionset = true;
					//trace("  Doing nothing.");
				}
			}
		}
		
		//Ok, now try to do that move
		if (Help.getroot(Obj.entities[i].action, "_") == "move" || 
		    Help.getroot(Obj.entities[i].action, "_") == "dashmove" ||
		    Help.getroot(Obj.entities[i].action, "_") == "backwardsmove" ||
				Help.getroot(Obj.entities[i].action, "_") == "doublemove") {
			tx1 = getdestinationx(i); ty1 = getdestinationy(i);
			
			if (Obj.entities[i].rule == "player" && currentweapon == "wallgun") {
				//Special case: we check the square one ahead instead
				tx1 = getdestinationx2(i); ty1 = getdestinationy2(i);
			}
			
			if (currentweapon == "swordgun") {
				//There's a special danger square. If our destination is that, then do nothing.
				var player:Int = Obj.getplayer();
				if (tx1 == Obj.entities[player].xp + Localworld.xstep(Obj.entities[player].dir)) {
					if (ty1 == Obj.entities[player].yp + Localworld.ystep(Obj.entities[player].dir)) {
						Obj.entities[i].removeaction(Obj.entities[i].action);
						Obj.entities[i].action = "wait";
						Obj.entities[i].actionset = true;
						return;
					}
				}
			}
			
			//First check for simple wall collisions
			if (World.collide(tx1, ty1)) {
				//Collision: remove this option from this entity
				Obj.entities[i].removeaction(Obj.entities[i].action);
				Obj.entities[i].action = "nothing";
				//trace("  Collided with wall, try again.");
				return;
			}else {
				//Ok, next check for complex enemy collisions: either
				//A set enemy or a chain enemy collides on it's destination square, and is a solid block
				//An unset enemy collides on it's current sqaure, but is not solid yet
				if (!(Obj.entities[i].rule == "player" && currentweapon == "wallgun")) {
					//If we're using the wall gun, don't care about entity collisions. Try to crush!
					for (j in 0 ... Obj.nentity) {
						if(Obj.entities[j].active && Obj.entities[j].collidable){
							if (i != j) {
								if (Obj.entities[j].actionset || Obj.entities[j].inchain) {
									tx2 = getdestinationx(j); ty2 = getdestinationy(j);	
									if (tx1 == tx2 && ty1 == ty2) {
										Obj.entities[i].removeaction(Obj.entities[i].action);
										Obj.entities[i].action = "nothing";
										//trace("  Collided with set entity or entity in chain, try again. (entity " + Std.string(j) + ")");
										return;
									}
									if (Obj.entities[j].inchain) {
										//Special check: If an entity is in a chain and moving
										//the opposite direction from you, then ALSO check thier current square
										if (oppositedirstring(Help.getbranch(Obj.entities[i].action, "_"),
																					Help.getbranch(Obj.entities[j].action, "_"))) {
											tx2 = getcurrentx(j); ty2 = getcurrenty(j);
											if (tx1 == tx2 && ty1 == ty2) {
												Obj.entities[i].removeaction(Obj.entities[i].action);
												Obj.entities[i].action = "nothing";
												//trace("  Collided with entity in chain going back the same way, try again. (entity " + Std.string(j) + ")");
												return;
											}
										}
									}
								}else {
									tx2 = getcurrentx(j); ty2 = getcurrenty(j);									
									if (tx1 == tx2 && ty1 == ty2) {
										//Ok, we've collided with an entity that's still deciding.
										Obj.entities[i].inchain = true;
										//trace("  Collided with unset entity " + Std.string(j) + ", passing signal:");
										while (!Obj.entities[j].actionset) figureoutmove(j);
										return;
									}
								}
							}
						}
					}
					
					//We're still here! Then then move is ok
					Obj.entities[i].actionset = true;
					//trace("  Move is ok!");
				}else {
					Obj.entities[i].actionset = true;
				}
			}
		}
	}
	
	public static function figureoutplayermove(i:Int):Void {
		//As above; just in this case we just think of the enemies and static things.
		//Pick a move at random from this entities available list
		//trace("Figuring out entity ", Std.string(i), ", " + Obj.entities[i].type);
		if (Obj.entities[i].numpossibleactions == 0) {
			Obj.entities[i].action = "nothing";
			Obj.entities[i].actionset = true;
			//trace("  Out of moves, do nothing.");
		}else {
			if (!Obj.entities[i].actionset) {
				//tx = Std.int(Math.random() * Obj.entities[i].numpossibleactions);
				tx = 0;
				tempstring = Obj.entities[i].possibleactions[tx];
				if (Help.getroot(tempstring, "_") == "move" || 
				    Help.getroot(tempstring, "_") == "dashmove" || 
				    Help.getroot(tempstring, "_") == "backwardsmove" || 
						Help.getroot(tempstring, "_") == "doublemove") {
					Obj.entities[i].action = tempstring;
					//trace("  Attempting ", Obj.entities[i].action);
				}else if (tempstring == "wait") {
					Obj.entities[i].action = "wait";
					Obj.entities[i].actionset = true;
				}else if (tempstring == "clockwise") {
					Obj.entities[i].action = "clockwise";
					Obj.entities[i].actionset = true;
				}else if (tempstring == "anticlockwise") {
					Obj.entities[i].action = "anticlockwise";
					Obj.entities[i].actionset = true;
				}else if (tempstring == "reverse_ai") {
					if (Obj.entities[i].ai == "anticlockwisefollowwall") {
						Obj.entities[i].ai = "clockwisefollowwall";
					}else if (Obj.entities[i].ai == "clockwisefollowwall") {
						Obj.entities[i].ai = "anticlockwisefollowwall";
					}
					Obj.entities[i].stringpara = Obj.entities[i].ai;
					Obj.entities[i].action = "nothing";
					Obj.entities[i].actionset = true;
				}else {
					//Do something other that move: for the moment, just do nothing
					Obj.entities[i].action = "nothing";
					Obj.entities[i].actionset = true;
					//trace("  Doing nothing.");
				}
			}
		}
		
		//Ok, now try to do that move
		if (Help.getroot(Obj.entities[i].action, "_") == "move" || 
		    Help.getroot(Obj.entities[i].action, "_") == "dashmove" ||
		    Help.getroot(Obj.entities[i].action, "_") == "backwardsmove" ||
				Help.getroot(Obj.entities[i].action, "_") == "doublemove") {
			tx1 = getdestinationx(i); ty1 = getdestinationy(i);
			
			if (Obj.entities[i].rule == "player" && currentweapon == "wallgun") {
				//Special case: we check the square one ahead instead
				//tx1 = getdestinationx2(i); ty1 = getdestinationy2(i);
			}
			
			//First check for simple wall collisions
			if (Game.checkforenemy(tx1, ty1) !=-1) {
				//Collision: remove this option from this entity
				Obj.entities[i].removeaction(Obj.entities[i].action);
				Obj.entities[i].action = "nothing";
				//trace("  Collided with wall, try again.");
				return;
			}else {
				Obj.entities[i].actionset = true;
			}
		}
	}
	
	public static function allactionsset():Bool {
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (!Obj.entities[i].actionset) return false;
			}
		}
		return true;
	}
	
	
	/** Return index of an enemy at this square, -2 for a wall, -1 for empty space */
	public static function checkforplayerorwall(x:Int, y:Int):Int {
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active && Obj.entities[i].collidable) {
				if (Obj.entities[i].rule == "player") {
					if (Obj.entities[i].xp == x && Obj.entities[i].yp == y) {
						return i;
					}
				}
			}
		}
		
		if (World.collide(x, y)) return -2;
		return -1;
	}
	
	/** Return index of an enemy at this square, -2 for a wall, -1 for empty space */
	public static function checkforenemy(x:Int, y:Int):Int {
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active && Obj.entities[i].collidable) {
				if (Obj.entities[i].xp == x && Obj.entities[i].yp == y) {
					if (Obj.entities[i].rule == "enemy") {
						return i;
					}
				}
			}
		}
		
		if (World.collide(x, y)) return -2;
		return -1;
	}
	
	/** Return index of an enemy at this square, -2 for a wall, -1 for empty space */
	public static function checkforentity(x:Int, y:Int):Int {
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].xp == x && Obj.entities[i].yp == y) {
					return i;
				}
			}
		}
		
		if (World.collide(x, y)) return -2;
		return -1;
	}
	
	/** Kludge to prevent shooting through a bomb */
	public static function checkforenemyorbomb(x:Int, y:Int):Int {
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].xp == x && Obj.entities[i].yp == y) {
					if (Obj.entities[i].rule == "enemy") {
						return i;
					}
				}
			}
		}
		
		if (World.collide(x, y)) return -2;
		return -1;
	}
	
	/** Kludge to prevent shooting through a bomb */
	public static function checkforenemyorbomborsword(x:Int, y:Int):Int {
		if (Localworld.swordat(x, y) != 0) return -2;
		
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].xp == x && Obj.entities[i].yp == y) {
					if (Obj.entities[i].rule == "enemy") {
						return i;
					}
				}
			}
		}
		
		if (World.collide(x, y)) return -2;
		return -1;
	}
	
	/** Return true if the player is at this square */
	public static function checkforplayer(x:Int, y:Int):Bool {
		var player:Int = Obj.getplayer();
		if (Obj.entities[player].xp == x && Obj.entities[player].yp == y) {
			//trace("player is at ", x, y);
			return true;
		}
		
		return false;
	}
	
	/** Return true if wall or bomb. */
	public static function checkforbomborwall(x:Int, y:Int):Bool {
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].xp == x && Obj.entities[i].yp == y) {
					if (Obj.entities[i].rule == "enemy") {
						return true;
					}
				}
			}
		}
		
		if (World.collide(x, y)) return true;
		return false;
	}
	
	
	/** Alert all the enemies! */
	public static function alertallenemies():Void {
		alarm = true;
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].rule == "enemy") {
					if (Obj.entities[i].alertbysound) {
						Localworld.foundplayer(i);
					}
				}
			}
		}
	}
	
	public static var gamestate:Int;
	
	public static var turn:String;
	public static var signal:Int;
	public static var signalcheck:Bool;
	
	public static var tempstring:String;
	public static var tx:Int;
	public static var ty:Int;
	public static var tdir:Int;
	public static var tx1:Int; 
	public static var ty1:Int; 
	public static var tx2:Int; 
	public static var ty2:Int;
	public static var temp:Int;
	public static var attempts:Int;
	public static var playerdir:Int;
	
	public static var lastplayeraction:String;
	public static var possiblemove:Array<String> = new Array<String>();
	public static var possiblemovescore:Array<Int> = new Array<Int>();
	public static var numpossiblemoves:Int;
	
	public static var speedframe:Int = 0;
	
	public static function showmessage(_message:String, col:String, time:Int = 90):Void {
		message = _message;
		messagedelay = time;
		messagecol = col; 
	}
	
	public static var message:String = "";
	public static var messagedelay:Int = 0;
	public static var messagecol:String = "white";
	
	public static var teststate:Int = 2;
	
	public static var health:Int = 1;
	public static var keys:Int = 3;
	public static var floor:Int = 1;
	
	public static function clearhighlight():Void {
		for (j in 0 ... World.mapheight) {
			for (i in 0 ... World.mapwidth) {
				if (Localworld.highlightcooldownat(i, j) > 0) {
					Localworld.highlightpoint(i, j, Localworld.highlightcooldownat(i, j)-1);
				}
			}
		}
	}
	
	public static function deadifsword(x:Int, y:Int):Bool {
		//Check for enemy swords at x, y. We're dead if there's one.
		for (i in 0 ... Obj.nentity) {
			if (Obj.entities[i].active) {
				if (Obj.entities[i].rule == "enemy") {
					if (Obj.entities[i].type == "swordguy") {
						tx = Obj.entities[i].xp;
						ty = Obj.entities[i].yp;
						tdir = Obj.entities[i].dir;
						if (x == tx + Localworld.xstep(tdir) && y == ty + Localworld.ystep(tdir)) {
							dashdeathkludge = true;
							return true;
						}
					}
				}
			}
		}
		return false;
	}
	
	public static var alarm:Bool = false;
	public static var alertlevel:Int = 0;
	
	public static var playerbacking:Int = 0x000000;
	public static var weaponbacking:Int = 0x000000;
	
	public static var icecube:Int;
	
	public static var enemycountdown:Int;
	
	public static var nukedelay:Int;
	public static var ascenddelay:Int;
	
	public static var currentweapon:String = "swordgun";
	public static var weaponcol:String = "red";
	public static var score:Int;
	public static var bestscore:Int;
	public static var playerbomb:Int;
	public static var gameover:Bool = false;
	
	public static function playtick():Void {
		if (!tickthisframe) {
			tickthisframe = true;
			Music.playef("tick");
		}
	}
	
	public static var tickthisframe:Bool = false;
	
	public static function playdasheffect():Void {
		if (!dasheffectthisframe) {
			dasheffectthisframe = true;
			Music.playef("dash");
		}
	}
	
	public static var dasheffectthisframe:Bool = false;
	
	
	public static function playbreakwall():Void {
		if (!breakwallthisframe) {
			breakwallthisframe = true;
			Music.playef("breakwall");
		}
	}
	
	public static var breakwallthisframe:Bool = false;
	public static var bossbomb:Bool;
	public static var menuframe:Int;
	public static var menudelay:Int;
	public static var dashdeathkludge:Bool = false;
	
	public static var oldx:Int;
	public static var oldy:Int;
	public static var swordx:Int;
	public static var swordy:Int;
	
	//For testing, some keypress recording stuff
	public static var originalrecordstring:String = "197657_luluuuuuuul";
	public static var playbackrecording:Bool = false;
	public static var gameseed = -1;
	public static var playbackspeed:Int = 30;
	public static var stepthrough:Bool = true;
	
	public static var replayonrestart:Bool;
	public static var recordposition:Int = 0;
	public static var playbackdelay:Int = 0;
	public static var recordstring:String;
	
	public static function record(t:String):Void {
		liverecordstring += t;
	}
	
	public static var liverecordstring:String = "";
	
	public static var enemyqueue:Array<Enemyqueue> = new Array<Enemyqueue>();
	public static var enemyqueuesize:Int = 0;
	
	
	public static var exitmenu:Bool = false;
	
	#if !flash
	public static function addexitmenu():Void {
		//Create the exit and full screen buttons
	}
	
	public static function removeexitmenu():Void {
		//Remove the exit and fullscreen buttons
	}
	#end
}