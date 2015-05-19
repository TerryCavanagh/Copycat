package gamecontrol;

import com.terry.*;

class Use {
	/** Use the item numbered t in the list in the game. */
	
	public static function usegadget(ent:Int, gadget:Int):Void {
		tdir = Obj.entities[ent].dir;
		tx = Obj.entities[ent].xp;
		ty = Obj.entities[ent].yp;
		
		var ammo:Int = Inventory.getammo(gadget);
		
		if (ammo > 0) {
			Inventory.useinventoryitem(gadget);
			switch(Inventory.itemlist[gadget].name.toLowerCase()) {
				case "bombgun":
					if (Game.playerbomb == 0) {
						var player:Int = Obj.getplayer();
						tx = Obj.entities[player].xp;
						ty = Obj.entities[player].yp;
						Obj.createentity(tx, ty, "enemy", "actualbomb");
						Game.playerbomb = 6;
						
						Game.startmove("wait");
					}
				case "pushgun":
					var shotdistance:Int = 1;
					var hitenemy:Int = -1;
					while (shotdistance < Math.max(World.mapheight+1, World.mapwidth+1)) {
						hitenemy = Game.checkforenemy(tx + Localworld.xstep(tdir, shotdistance), ty + Localworld.ystep(tdir, shotdistance));
						Localworld.highlightpoint(tx + Localworld.xstep(tdir, shotdistance), ty + Localworld.ystep(tdir, shotdistance));
						if (hitenemy == -2) shotdistance = Std.int(Math.max(World.mapheight+1, World.mapwidth+1));
						if (hitenemy >= 0) {
							tx = Obj.entities[hitenemy].xp;
							ty = Obj.entities[hitenemy].yp;
							shotdistance = 10000;
						}
						shotdistance++;
					}
					
					if (hitenemy >= 0) {
						Obj.entities[hitenemy].stunned = 10;
						Obj.createentity(tx, ty, "item", "shootgun");
						while (Game.checkforenemy(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir)) == -1) {
							Obj.entities[hitenemy].xp += Localworld.xstep(tdir);
							Obj.entities[hitenemy].yp += Localworld.ystep(tdir);
							
							tx = Obj.entities[hitenemy].xp;
							ty = Obj.entities[hitenemy].yp;
							Localworld.highlightpoint(tx, ty);
						}
					}
					
					Localworld.updatelighting();
				case "dashgun":
					Game.playdasheffect();
					
					var player:Int = Obj.getplayer();
					tx = Obj.entities[player].xp;
					ty = Obj.entities[player].yp;
					tdir = Obj.entities[player].dir;
					
					temp = Game.checkforenemy(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir));
					if (Game.deadifsword(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir))) {
						Obj.entities[player].xp = tx + Localworld.xstep(tdir); 
						Obj.entities[player].yp = ty + Localworld.ystep(tdir);
						temp = -2;
					}
					while (temp != -2) {
						if (temp >= 0) {
							Game.killenemy(temp);
							Gfx.flashlight = 5;
							Gfx.screenshake = 10;
							if (Obj.entities[temp].type == "boss") {
								tx = tx - Localworld.xstep(tdir); 
								ty = ty - Localworld.ystep(tdir);
							}
							temp = -2;
						}
						
						Localworld.highlightpoint(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir));
						Obj.entities[player].xp = tx + Localworld.xstep(tdir); 
						Obj.entities[player].yp = ty + Localworld.ystep(tdir);
						tx = Obj.entities[player].xp;
						ty = Obj.entities[player].yp;
						if (temp != -2) temp = Game.checkforenemy(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir));
						if (Game.deadifsword(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir))) {
							Obj.entities[player].xp = tx + Localworld.xstep(tdir); 
							Obj.entities[player].yp = ty + Localworld.ystep(tdir);
							temp = -2;
						}
					}
					
					if (temp == -2) {
						World.placetile(tx + Localworld.xstep(tdir), ty + Localworld.ystep(tdir), Localworld.FLOOR);
					}
					
					Game.startmove("wait");
				case "shootgun":
					Music.playef("shoot");
					
					var shotdistance:Int = 1;
					while (shotdistance < Math.max(World.mapheight+1, World.mapwidth+1)) {
						temp = Game.checkforenemyorbomborsword(tx + Localworld.xstep(tdir, shotdistance), ty + Localworld.ystep(tdir, shotdistance));
						Localworld.highlightpoint(tx + Localworld.xstep(tdir, shotdistance), ty + Localworld.ystep(tdir, shotdistance));
						if (temp == -2) {
					    World.placetile(tx + Localworld.xstep(tdir, shotdistance), ty + Localworld.ystep(tdir, shotdistance), Localworld.FLOOR);
							shotdistance = Std.int(Math.max(World.mapheight+1, World.mapwidth+1));
						}
						if (temp >= 0) {
							shotdistance = 10000;
							Game.killenemy(temp);
							Gfx.flashlight = 5;
							Gfx.screenshake = 10;
						}
						shotdistance++;
					}
					Game.startmove("wait");
				case "wallgun":
					var player:Int = Obj.getplayer();
					//Player position
					tx = Obj.entities[player].xp;
					ty = Obj.entities[player].yp;
					tdir = Obj.entities[player].dir;
					//Block position
					tx += Localworld.xstep(tdir);
					ty += Localworld.ystep(tdir);
					//Position in front of the block
					tx += Localworld.xstep(tdir);
					ty += Localworld.ystep(tdir);
					temp = Game.checkforenemy(tx, ty);
					while (temp != -2) {
						if (temp >= 0) {
							Game.killenemy(temp);
							Gfx.flashlight = 5;
							Gfx.screenshake = 10;
						}
						
						Localworld.highlightpoint(tx, ty);
						tx += Localworld.xstep(tdir);
						ty += Localworld.ystep(tdir);
						temp = Game.checkforenemy(tx, ty);
					}
					
					if (temp == -2) {
						tx -= Localworld.xstep(tdir);
						ty -= Localworld.ystep(tdir);
						World.placetile(tx, ty, Localworld.WALL);
					}
					
					if (Game.currentweapon != "wallgun") {
						//Should no longer have a wall in front of us
						tx = Obj.entities[player].xp;
						ty = Obj.entities[player].yp;
						tdir = Obj.entities[player].dir;
						
						tx += Localworld.xstep(tdir);
						ty += Localworld.ystep(tdir);
						
						World.placetile(tx, ty, Localworld.FLOOR);
					}
					
					Music.playef("throwwall");
					Game.startmove("wait");
				case "deathgun":
					for (j in 0 ... World.mapheight) {
						for (i in 0 ... World.mapwidth) {
							Localworld.highlightpoint(i, j);
							if (World.at(i, j) == Localworld.WALL) {
								World.placetile(i, j, Random.ppickint(Localworld.BLOOD, Localworld.WALL));
							}else if (World.at(i, j) == Localworld.BLOOD) {
								World.placetile(i, j, Localworld.BLOOD);
							}else{
								World.placetile(i, j, Localworld.FLOOR);
							}
						}
					}
					
					for (i in 0 ... Obj.nentity) {
						if (Obj.entities[i].active) {
							if (Obj.entities[i].rule == "enemy") {
								Game.killenemy(i);
							}
							
							if (Obj.entities[i].rule == "actualbomb") {
								Obj.entities[i].active = false;
							}
						}
					}
					Game.enemyqueuesize = 0;
					Game.nukedelay = 30;
					if (Game.bossbomb) {
						Game.bossbomb = false;
						Game.changeweapon("lifegun");
					}
					if (!Game.bossingame()) {
						if (Game.currentweapon != "lifegun") Game.placeatborder("enemy", "boss");
					}
					Music.playef("nuke");
				case "lifegun":
					Game.ascenddelay = 1;
					Music.playef("ascend");
			}
		}
	}
	
	public static var tx:Int;
	public static var ty:Int;
	public static var tdir:Int;
	public static var temp:Int;
}