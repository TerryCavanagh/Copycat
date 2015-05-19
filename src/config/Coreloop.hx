package config;

import openfl.display.Sprite;
import openfl.utils.Timer;
import openfl.events.*;
import openfl.Lib;
import gamecontrol.*;
import com.terry.*;
import com.terry.util.*;
import openfl.display.Stage;

class Coreloop {
	public static function init(stage:Stage):Void {
		infocus = true; 
		//stage.addEventListener(Event.DEACTIVATE, windowNotActive);
		//stage.addEventListener(Event.ACTIVATE, windowActive);
	}
	
	public static function setupgametimer():Void {
		_rate = 1000 / TARGET_FPS;
	  _skip = _rate * 10;
		_timer.addEventListener(TimerEvent.TIMER, mainloop);
		_timer.start();
	}
	
	private static function mainloop(e:TimerEvent):Void {
		_current = Lib.getTimer();
		if (_last < 0) _last = _current;
		_delta += _current - _last;
		_last = _current;
		if (_delta >= _rate){
			_delta %= _skip;
			while (_delta >= _rate){
				_delta -= _rate;
				input();
				logic();
			}
			render();
			e.updateAfterEvent();
		}
	}
	
	private static function input():Void{
		if (infocus) {
			Mouse.update(Std.int(Lib.current.mouseX / Gfx.screenscale), Std.int(Lib.current.mouseY / Gfx.screenscale));
			Key.keypoll();
			
			switch(Game.gamestate) {
				case Game.TITLEMODE:	Input.titleinput();
				case Game.GAMEMODE: Input.gameinput();
				case Game.CLICKTOSTART: if (Mouse.justleftpressed()) { Game.changestate(Game.TITLEMODE); }
			}
		}
	}

	private static function logic():Void {
		if (!infocus) {
			if (Music.globalsound > 0) {
				Music.globalsound = Music.globalsound * 0.95;
			  if (Music.globalsound < 0.1) Music.globalsound = 0;
				Music.updateallvolumes();
			}
			Music.processmusic();
			Gfx.processfade();
			Help.updateglow();
		}else {		
			Lerp.update();
			
			switch(Game.gamestate) {
				case Game.TITLEMODE: Logic.titlelogic();
				case Game.GAMEMODE: Logic.gamelogic(); 
			}
			
			Game.fadelogic();
			Obj.cleanup();
			Music.processmusic();
			Gfx.processfade();
			Help.updateglow();
			
			//Mute button
			Music.processmute();
		}
	}

	private static function render():Void {
		Gfx.backbuffer.lock();
		if (!infocus) {
			Draw.outoffocusrender();
		}else {
			Gfx.cls();
			
			switch(Game.gamestate) {
				case Game.TITLEMODE: Render.titlerender();
				case Game.GAMEMODE: Render.gamerender(); 
				case Game.CLICKTOSTART: Draw.clicktostart();
			}
			
			Draw.drawfade();
			Gfx.screenrender();
		}
	}
	
	public static function windowNotActive(e:Event):Void{ infocus = false; }
  public static function windowActive(e:Event):Void{ infocus = true; }
	
	public static var infocus:Bool;
	public static var gamestate:Int;
	
	private static var TARGET_FPS:Int = 60;
	private static var _rate:Float;
	private static var _skip:Float;
	private static var _last:Float = -1;
	private static var _current:Float = 0;
	private static var _delta:Float = 0;
	private static var _timer:Timer = new Timer(4);
}