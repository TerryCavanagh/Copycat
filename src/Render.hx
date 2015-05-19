package;

import com.terry.*;
import gamecontrol.*;
import config.*;

class Render {
	public static function titlerender() {
		Gfx.changetileset("terminal");
		
		Gfx.fillrect(0, 0, Gfx.screenwidth, Gfx.screenheight, 32, 32, 128 - Std.int(Help.glow/4));
		Gfx.drawimage(Gfx.CENTER, Lerp.to(-48, 30, "intro", "bounce_out"), "logo");
		
		Text.changesize(16);
		//Text.print_freescale(Gfx.CENTER, 30, "COPYCAT", Draw.messagecol("flashing"), 3, 4, Gfx.CENTER, Gfx.CENTER);
		
		Gfx.fillrect(0, 105, Gfx.screenwidth, 60, 16, 16, 64 - Std.int(Help.glow/8));
		if (Game.menuframe == 0) {
			Draw.terminalprint(2, 20+90-5, "ARROWS", Draw.messagecol("white"), false, 0, 4, 0x000000);
			Draw.terminalprint(3, 20 + 110, "SPACE", Draw.messagecol("white"), false, 4, 0, 0x000000);
			Draw.terminalprint(11, 20+90-5, "Move/Rotate", Draw.messagecol("gray"), false, 0, 4, 0x000000);
			Draw.terminalprint(11, 20 + 110, "Use weapon", Draw.messagecol("gray"), false, 0, 0, 0x000000);
			
			Gfx.fillrect(Gfx.screenwidthmid - 45, 160, 90, 15, 16, 16, 64 - Std.int(Help.glow / 8));
			Gfx.fillrect(Gfx.screenwidthmid - 45 + 2, 160+2, 30 - 4, 15-4, 190, 190, 255);
			Gfx.fillrect(Gfx.screenwidthmid - 45 + 32, 160+2, 30 - 4, 15-4, 64, 64, 160);
			Gfx.fillrect(Gfx.screenwidthmid - 45 + 62, 160+2, 30 - 4, 15-4, 64, 64, 160);
		}else if (Game.menuframe == 1) {
			Draw.terminalprint(Gfx.CENTER, 20+90, "Defeat enemies to", Draw.messagecol("gray"), false, 0, 0, 0x000000);
			Draw.terminalprint(Gfx.CENTER, 20 + 110, "absorb their power.", Draw.messagecol("gray"), false, 0, 0, 0x000000);			
			
			Gfx.fillrect(Gfx.screenwidthmid - 45, 160, 90, 15, 16, 16, 64 - Std.int(Help.glow / 8));
			Gfx.fillrect(Gfx.screenwidthmid - 45 + 2, 160+2, 30 - 4, 15-4, 64, 64, 160);
			Gfx.fillrect(Gfx.screenwidthmid - 45 + 32, 160+2, 30 - 4, 15-4, 190, 190, 255);
			Gfx.fillrect(Gfx.screenwidthmid - 45 + 62, 160+2, 30 - 4, 15-4, 64, 64, 160);
		}else if (Game.menuframe == 2) {
			Draw.terminalprint(Gfx.CENTER, 20+90, "Destroy the mimic", Draw.messagecol("gray"), false, 0, 0, 0x000000);
			Draw.terminalprint(Gfx.CENTER, 20 + 110, "crystal to ascend.", Draw.messagecol("gray"), false, 0, 0, 0x000000);
			Gfx.fillrect(Gfx.screenwidthmid - 45, 160, 90, 15, 16, 16, 64 - Std.int(Help.glow / 8));
			Gfx.fillrect(Gfx.screenwidthmid - 45 + 2, 160+2, 30 - 4, 15-4, 64, 64, 160);
			Gfx.fillrect(Gfx.screenwidthmid - 45 + 32, 160+2, 30 - 4, 15-4, 64, 64, 160);
			Gfx.fillrect(Gfx.screenwidthmid - 45 + 62, 160+2, 30 - 4, 15-4, 190, 190, 255);
		}
		
		Text.changesize(8);
		Draw.rterminalprint((23 * 16) + 8, Gfx.screenheight - 14, "by terry, for LD32", Draw.messagecol("gray"), false);
		Draw.terminalprint(0, Gfx.screenheight - 14, "post-compo version", Draw.messagecol("gray"), false, 8);
	}
	
	public static function gamerender() {
		Text.changesize(16);
		
		if (Game.nukedelay > 0) {
			if (!Game.playbackrecording) Random.setseed(Std.int(Help.slowsine / 2));
			for (j in 0 ... Gfx.screentileheight) {
				for (i in 0 ... Gfx.screentilewidth) {
					var tcol:Int = Random.pint(0, 359);
					Gfx.fillrect(i * Gfx.tiles[Gfx.currenttileset].width, j * Gfx.tiles[Gfx.currenttileset].height, Gfx.tiles[Gfx.currenttileset].width, Gfx.tiles[Gfx.currenttileset].height, Gfx.hsl2rgb(tcol, (0.7 * ((Game.nukedelay+30)/60)), 0.2));
					Gfx.drawtile_col(i * Gfx.tiles[Gfx.currenttileset].width, j * Gfx.tiles[Gfx.currenttileset].height, Random.pint(0, 255), Gfx.hsl2rgb(tcol, 1.0 * ((Game.nukedelay+30)/60), 0.5));
				}
			}
		}else {
			Draw.drawbackground();
			Draw.drawmap(World.tileset);
			Draw.drawqueue();
			Gfx.drawentities();
			Draw.swordlayer();
			Gfx.drawentitymessages();
			Draw.drawparticles();
			
			Text.changesize(16);
			if (Game.messagedelay != 0) {
				Gfx.fillrect(0, Gfx.screenheight - 18, Gfx.screenwidth, 18, Draw.messagecolback(Game.messagecol));
				Draw.terminalprint(1, 8 + 13 * 16, Game.message, Draw.messagecol(Game.messagecol), false);
				
				Draw.rterminalprint(23 * 16, 8 + 13 * 16, Std.string(Game.score), Draw.messagecol(Game.messagecol), false);
				Game.temp = Text.len(Std.string(Game.score));
				Text.changesize(8);
				if(Game.score >= Game.bestscore && Game.bestscore > 0){
					Draw.rterminalprint((23 * 16) - Game.temp-6, 17+13*16, "NEW RECORD!", Draw.messagecol(Game.messagecol), false);
				}else {
					Draw.rterminalprint((23 * 16) - Game.temp-6, 17+13*16, "SCORE", Draw.messagecol(Game.messagecol), false);
				}
			}else {
				Gfx.fillrect(0, Gfx.screenheight - 18, Gfx.screenwidth, 18, Draw.messagecolback(Game.weaponcol));
				Draw.terminalprint(1, 8 + 13 * 16, Game.weaponname(), Draw.messagecol(Game.weaponcol), false);
				
				Draw.rterminalprint(23 * 16, 8 + 13 * 16, Std.string(Game.score), Draw.messagecol(Game.weaponcol), false);
				Game.temp = Text.len(Std.string(Game.score));
				Text.changesize(8);
				if(Game.score >= Game.bestscore && Game.bestscore > 0){
					Draw.rterminalprint((23 * 16) - Game.temp-6, 17+13*16, "NEW RECORD!", Draw.messagecol(Game.weaponcol), false);
				}else {
					Draw.rterminalprint((23 * 16) - Game.temp-6, 17+13*16, "SCORE", Draw.messagecol(Game.weaponcol), false);
				}
			}
		}
		
		#if !flash
		
		if (Game.exitmenu) {
			Gfx.fillrect(0, 0, Gfx.screenwidth, Gfx.screenheight, 0);
			
			Text.changesize(16);
			Text.print(Gfx.CENTER, 80, "EXIT GAME?", 0xFFFFFF); 
			Text.print(Gfx.CENTER, 120, "PRESS [ESCAPE] TO QUIT OR", 0xDDDDDD); 
			Text.print(Gfx.CENTER, 136, "SPACE TO RETURN TO GAME", 0xDDDDDD); 
			Text.changesize(8);
			Text.print(Gfx.CENTER, 220, "PRESS [F] TO TOGGLE FULLSCREEN", 0xDDDDDD); 
		}
		
		#end
	}
}