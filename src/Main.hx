package;

import openfl.display.*;
import config.*;
import gamecontrol.*;
import com.terry.*;

class Main extends Sprite {
	public function new () {
		super();
		
		Key.init(this.stage);
		Mouse.init(this.stage);
		Help.init();
		Lerp.init();
		Music.init();
		World.init();
		Gfx.init(this.stage);
		Obj.init();
		
		Game.init();
		Localworld.init();
		Draw.init();
		
		Coreloop.init(this.stage);
		
		Init.init();
	}
}