package gamecontrol;

import com.terry.*;

class Enemyqueue {
	public function new() {
		
	}
	
	public function add(_x:Int, _y:Int, _rule:String, _type:String, _speed:Int, _dir:String):Void {
		x = _x;
		y = _y;
		rule = _rule;
		type = _type;
		speed = _speed;
		dir = _dir;
	}
	
	public var x:Int;
	public var y:Int;
	public var rule:String;
	public var type:String;
	public var speed:Int;
	public var dir:String;
}