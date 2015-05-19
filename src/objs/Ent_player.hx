package objs;

import flash.display.*;
import flash.geom.*;
import flash.events.*;
import flash.net.*;
import gamecontrol.*;
import com.terry.*;
import com.terry.util.*;

//Note: "player" is special as a rule, with default implementations in several places
class Ent_player extends Ent_generic {
	public function new() {
		super();
		
		name = "player";
	}
	
	override public function create(i:Int, xp:Float, yp:Float, para1:String = "0", para2:String = "0", para3:String = "0"):Void {
		Obj.entities[i].rule = "player";
		Obj.entities[i].tileset = "terminal";
		setupcollision(i);
		
		World.placetile(Obj.entities[i].xp, Obj.entities[i].yp, Localworld.FLOOR);
		
		Obj.entities[i].tile = ">".charCodeAt(0);
		Obj.entities[i].col = 0xD1F1F5;
		Obj.entities[i].dir = Game.playerdir;
		
		Obj.entities[i].lightsource = "none";
		Obj.entities[i].health = Game.health;
		
		Obj.entities[i].checkcollision = true; //Do collision FROM this entity - avoids NxN tests
	}
	
	override public function update(i:Int):Void {
		//Player entity's actual position is usually controlled
		//in the input class: this is for state changes
		if (Obj.entities[i].state == 0) {
			
		}
	}
	
	override public function animate(i:Int):Void {
		switch(Obj.entities[i].dir) {
			case Help.UP:
				Obj.entities[i].tile = "^".charCodeAt(0);
			case Help.DOWN:
				Obj.entities[i].tile = "V".charCodeAt(0);
			case Help.LEFT:
				Obj.entities[i].tile = "<".charCodeAt(0);
			case Help.RIGHT:
				Obj.entities[i].tile = ">".charCodeAt(0);
		}
		
		if (Obj.entities[i].health == 3) {
			Obj.entities[i].col = 0xD1F1F5;
		}else if (Obj.entities[i].health == 2) {
			if (Help.slowsine % 32 >= 16) {
				Obj.entities[i].col = 0xD1F1F5;
			}else {
				Obj.entities[i].col = 0xFFF144;
			}
		}else if (Obj.entities[i].health == 1) {
			if (Help.slowsine % 16 >= 8) {
				Obj.entities[i].col = 0xFF1111;
			}else {
				Obj.entities[i].col = 0xFF4444;
			}
		}
		
		if (Game.icecube > 0) {
			Obj.entities[i].col = Gfx.RGB(64, 64, Std.int(255 - (Math.random() * Help.glow * 2)));
		}
		
		Obj.entities[i].drawframe = Obj.entities[i].tile;
	}
	
	override public function drawentity(i:Int):Void {
		Gfx.changetileset(Obj.entities[i].tileset);
		
		if(Inventory.equippedgadget>-1){
			if (Inventory.itemlist[Inventory.equippedgadget].issword) {
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
				Gfx.fillrect(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, Gfx.tiles[Gfx.currenttileset].width, Gfx.tiles[Gfx.currenttileset].height, 0x0a0b15);
				Gfx.drawtile_col(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, Obj.entities[i].drawframe, Game.playerbacking);
			}else {
				Gfx.fillrect(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, Gfx.tiles[Gfx.currenttileset].width, Gfx.tiles[Gfx.currenttileset].height, 0x0a0b15);
				if(Game.currentweapon == "deathgun"){
					Gfx.drawtile_col(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, Obj.entities[i].drawframe, Draw.messagecol(Game.weaponcol));
				}else {
					Gfx.drawtile_col(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, Obj.entities[i].drawframe, Game.playerbacking);
				}
			}
		}else{
			Gfx.fillrect(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, Gfx.tiles[Gfx.currenttileset].width, Gfx.tiles[Gfx.currenttileset].height, 0x0a0b15);
			if(Game.currentweapon == "deathgun"){
				Gfx.drawtile_col(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, Obj.entities[i].drawframe, Draw.messagecol(Game.weaponcol));
			}else {
				Gfx.drawtile_col(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, Obj.entities[i].drawframe, Game.playerbacking);
			}
		}
	}
	
	override public function drawinit(i:Int, xoff:Int, yoff:Int, frame:Int):Void {
		Gfx.draw_defaultinit(i, xoff, yoff, frame);
	}
	
	override public function collision(i:Int, j:Int):Void {
		//i is this entity, j is the other
		if (Obj.entities[j].rule == "enemy") {
			if (Obj.entitycollide(i, j)) {
				//trace("collision");
			}
		}
	}
	
	override public function setupcollision(i:Int):Void {
		Gfx.changetileset(Obj.entities[i].tileset);
		
		Obj.entities[i].cx = 0;
		Obj.entities[i].cy = 0;
		Obj.entities[i].w = Gfx.tiles[Gfx.currenttileset].width;
		Obj.entities[i].h = Gfx.tiles[Gfx.currenttileset].height;
	}
}