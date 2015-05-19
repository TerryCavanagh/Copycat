package gamecontrol;

import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
	
class Itemclass{
	public function new(t:Int):Void {
		for (i in 0 ... 10) {
			description.push("");
		}
		
		clear();
		inititem(t);
	}
	
	public function clear():Void {
		name = "";
		for (i in 0 ... 10) {
			description[i] = "";
		}
		descriptionsize = 0;
		power = 0; ability = 0; type = Inventory.TREASURE;
		lethal = false; letter = "";
		typical = 1;
		issword = false;
		multiname = "CHARGE";
	}
	
	public function inititem(t:Int):Void {
		r = -1;
		switch(t) {
			case 0:
				name = "pushgun";
				
				description[0] = "Pushes enemies back!";
				descriptionsize = 1;
				
				type = Inventory.GADGET;
			case 1:
				name = "shootgun";
				
				description[0] = "Kills the enemy!";
				descriptionsize = 1;
				
				type = Inventory.GADGET;
			case 2:
				name = "dashgun";
				
				description[0] = "Dash through all enemies.";
				descriptionsize = 1;
				
				type = Inventory.GADGET;
			case 3:
				name = "swordgun";
				
				description[0] = "Is a sword";
				descriptionsize = 1;
				issword = true;
				
				type = Inventory.GADGET;
			case 4:
				name = "bombgun";
				
				description[0] = "Is a bomb oh no";
				descriptionsize = 1;
				
				type = Inventory.GADGET;
			case 5:
				name = "wallgun";
				
				description[0] = "shoots the walls with walls";
				descriptionsize = 1;
				
				type = Inventory.GADGET;
			case 6:
				name = "deathgun";
				
				description[0] = "oh no";
				descriptionsize = 1;
				
				type = Inventory.GADGET;
			case 7:
				name = "lifegun";
				
				description[0] = "yay well done";
				descriptionsize = 1;
				
				type = Inventory.GADGET;
		}
		
		if (r == -1){
			if (type == Inventory.USEABLE) {
				character = "*";
				r = 32; g = 32; b = 255;
			}else if (type == Inventory.WEAPON) {
				character = "/";
				r = 225; g = 128; b = 128;
			}else if (type == Inventory.GADGET) {
				character = String.fromCharCode(21);
				r = 48; g = 255; b = 48;
			}else if (type == Inventory.TREASURE) {
				character = "$";
				r = 196; g = 196; b = 32;
			}else if (type == Inventory.LETTER) {
				character = String.fromCharCode(20);
				r = 180; g = 180; b = 180;
			}
		}
	}
	
	//Fundamentals
	public var name:String;
	public var description:Array<String> = new Array<String>();
	public var descriptionsize:Int;
	public var power:Int;
	public var ability:Int;
	public var type:Int;
	public var lethal:Bool;
	public var letter:String;
	public var typical:Int;
	public var multiname:String;
	public var issword:Bool;
	
	public var character:String;
	public var r:Int;
	public var g:Int;
	public var b:Int;
}
