package;

import openfl.display.*;
import openfl.Assets;
import config.*;
import gamecontrol.*;
import com.terry.*;
import objs.*;

class Init {
	public static function loadresources():Void {
		//Load Soundeffects
		Music.addeffect("intro");
		Music.addeffect("killenemy");
		Music.addeffect("dash");
		Music.addeffect("bomb");
		Music.addeffect("shoot");
		Music.addeffect("tick");
		Music.addeffect("breakwall");
		Music.addeffect("dead");
		Music.addeffect("nuke");
		Music.addeffect("ascend");
		Music.addeffect("blocked");
		Music.addeffect("throwwall");
		Music.addeffect("hurtboss");
		Music.addeffect("killboss");
		Music.addeffect("pushback");
		Music.addeffect("swordclash");
		
		//Load Tiles
		Gfx.maketiles("terminal", 16, 20);
		Gfx.changetileset("terminal");
		
		Gfx.addimage("logo", "data/graphics/logo.png");
		
		//Import fonts
		Text.addfont("FFFIntelligent");
		Text.cachefont("FFFIntelligent", 8, 16); //Totally optional!
	}
	
	public static function init():Void {
		Gfx.createscreen(384, 240, 2);
		
		
		#if flash
		Gfx.fullscreen = false;
		#else
		Gfx.fullscreen = true;
		Gfx.updategraphicsmode();
		#end
		
		Key.haspriority = true;
		
		World.changecamera("none");
		
		//Init all entity types
		Obj.templates.push(new Ent_player());
		Obj.templates.push(new Ent_enemy());
		Obj.loadtemplates();
		
		//Load resources
		loadresources();
		
		//Init the game
		//Game.changestate(Game.CLICKTOSTART);
		Game.changestate(Game.TITLEMODE);
		
		Lerp.start("intro", 60);
		
		//Start the game
		Coreloop.setupgametimer();
		
		//Game.changestate(Game.GAMEMODE);
		//Game.restartgame();
		Localworld.generate("ludumdare");
	}
}