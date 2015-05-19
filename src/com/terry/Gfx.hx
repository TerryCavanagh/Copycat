package com.terry;
	
import openfl._v2.display.Stage;
import openfl.display.*;
import openfl.geom.*;
import openfl.events.*;
import openfl.net.*;
import openfl.text.*;
import openfl.Assets;
import gamecontrol.*;
import com.terry.util.*;
import openfl.Lib;
import openfl.system.Capabilities;

class Gfx {
	public static function init(stage:Stage):Void {
		gfxstage = stage;
	}
	
	public static function createscreen(width:Int, height:Int, scale:Int = 1):Void {
		initgfx(width, height, scale);
		Text.init();
		gfxstage.addChild(screen);
	}
	
	//Initialise arrays here
	public static function initgfx(width:Int, height:Int, scale:Int):Void {
		//We initialise a few things
		screenwidth = width; screenheight = height;
		screenwidthmid = Std.int(screenwidth / 2); screenheightmid = Std.int(screenheight / 2);
		
		devicexres = Std.int(flash.system.Capabilities.screenResolutionX);
		deviceyres = Std.int(flash.system.Capabilities.screenResolutionY);
		screenscale = scale;
		
		trect = new Rectangle(); tpoint = new Point();
		tbuffer = new BitmapData(1, 1, true);
		ct = new ColorTransform(0, 0, 0, 1, 255, 255, 255, 1); //Set to white
		fademode = 0; fadeamount = 0; fadeaction = "nothing";
		
		backbuffer = new BitmapData(screenwidth, screenheight, false, 0x000000);
		screenbuffer = new BitmapData(screenwidth, screenheight, false, 0x000000);
		textboxbuffer = new BitmapData(screenwidth, screenheight, false, 0x00000000);
		
		drawto = backbuffer;
		
		screen = new Bitmap(screenbuffer);
		screen.width = screenwidth * scale;
		screen.height = screenheight * scale;
		
		fullscreen = false;
		
		test = false; teststring.push("TEST = True");
	}
	
	public static function cleartest():Void {
		teststring = new Array<String>();
	}
	
	public static function addtest(t:String):Void {
		teststring.push(t);
		test = true;
		if (teststring.length > 20) {
			teststring.reverse();
			teststring.pop();
			teststring.reverse();
		}
	}
	
	public static function settest(t:String):Void {
		teststring[0] = t;
		test = true;
	}
	
	public static function settrect(x:Int, y:Int, w:Int, h:Int):Void {
		trect.x = x;
		trect.y = y;
		trect.width = w;
		trect.height = h;
	}
	
	public static function settpoint(x:Int, y:Int):Void {
		tpoint.x = x;
		tpoint.y = y;
	}
	
	public static function changetileset(tilesetname:String):Void {
		if(currenttilesetname != tilesetname){
			currenttileset = tilesetindex.get(tilesetname);
			currenttilesetname = tilesetname;
		}
	}
	
	public static function fastblit(tilesetname:String):Void {
		tiles[tilesetindex.get(tilesetname)].fastblit = true;
	}
	
	public static function maketiles(imagename:String, width:Int, height:Int):Void {
		buffer = new Bitmap(Assets.getBitmapData("data/graphics/" + imagename + ".png")).bitmapData;
		
		var tiles_rect:Rectangle = new Rectangle(0, 0, width, height);
		tiles.push(new Tileset(imagename, width, height));
		tilesetindex.set(imagename, tiles.length - 1);
		currenttileset = tiles.length - 1;
		
		var tilerows:Int;
		var tilecolumns:Int;
		tilecolumns = Std.int((buffer.width - (buffer.width % width)) / width);
		tilerows = Std.int((buffer.height - (buffer.height % height)) / height);
		
		for (j in 0 ... tilerows) {
			for (i in 0 ... tilecolumns) {
				var t:BitmapData = new BitmapData(width, height, true, 0x000000);
				settrect(i * width, j * height, width, height);
				t.copyPixels(buffer, trect, tl);
				tiles[currenttileset].tiles.push(t);
			}
		}
	}	
	
	public static function addimage(imagename:String, filename:String):Void {
		buffer = new Bitmap(Assets.getBitmapData(filename)).bitmapData;
		imageindex.set(imagename, images.length);
		
		var t:BitmapData = new BitmapData(buffer.width, buffer.height, true, 0x000000);
		settrect(0, 0, buffer.width, buffer.height);			
		t.copyPixels(buffer, trect, tl);
		images.push(t);
	}
	
	public static function imagealignx(x:Int):Int {
		if (x == CENTER) return Gfx.screenwidthmid - Std.int(images[imagenum].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return images[imagenum].width;
		return x;
	}
	
	public static function imagealigny(y:Int):Int {
		if (y == CENTER) return Gfx.screenheightmid - Std.int(images[imagenum].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return images[imagenum].height;
		return y;
	}
	
	public static function imagealignonimagex(x:Int):Int {
		if (x == CENTER) return Std.int(images[imagenum].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return images[imagenum].width;
		return x;
	}
	
	public static function imagealignonimagey(y:Int):Int {
		if (y == CENTER) return Std.int(images[imagenum].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return images[imagenum].height;
		return y;
	}
	
	public static function drawimage(x:Int, y:Int, imagename:String):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		shapematrix.identity();
		shapematrix.translate(x, y);
		backbuffer.draw(images[imagenum], shapematrix);
	}
	
	public static function drawimage_scale(x:Int, y:Int, imagename:String, scale:Float, transx:Int, transy:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		transx = imagealignonimagex(transx); transy = imagealignonimagey(transy);
		
		shapematrix.identity();
		shapematrix.translate(-transx, -transy);
		shapematrix.scale(scale, scale);
		shapematrix.translate(x + transx, y + transy);
		drawto.draw(images[imagenum], shapematrix);
	}
	
	public static function drawimage_freescale(x:Int, y:Int, imagename:String, xscale:Float, yscale:Float, transx:Int, transy:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		transx = imagealignonimagex(transx); transy = imagealignonimagey(transy);
		
		shapematrix.identity();
		shapematrix.translate(-transx, -transy);
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x + transx, y + transy);
		drawto.draw(images[imagenum], shapematrix);
	}
	
	public static function drawimage_rotate(x:Int, y:Int, imagename:String, rotate:Int, transx:Int, transy:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		transx = imagealignonimagex(transx); transy = imagealignonimagey(transy);
		
		shapematrix.identity();
		shapematrix.translate(-transx, -transy);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.translate(x + transx, y + transy);
		drawto.draw(images[imagenum], shapematrix);
	}
	
	public static function drawimage_scale_rotate(x:Int, y:Int, imagename:String, scale:Float, rotate:Int, transx:Int, transy:Int):Void {
		drawimage_freescale_rotate(x, y, imagename, scale, scale, rotate, transx, transy);
	}
	
	public static function drawimage_freescale_rotate(x:Int, y:Int, imagename:String, xscale:Float, yscale:Float, rotate:Int, transx:Int, transy:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		transx = imagealignonimagex(transx); transy = imagealignonimagey(transy);
		
		shapematrix.identity();
		shapematrix.translate(-transx, -transy);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x + transx, y + transy);
		drawto.draw(images[imagenum], shapematrix);
	}
	
	public static function drawimage_col(x:Int, y:Int, imagename:String, col:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		
  	shapematrix.identity();
		shapematrix.translate(x, y);
		ct.color = col;
		drawto.draw(images[imagenum], shapematrix, ct);
	}
	
	public static function drawimage_scale_col(x:Int, y:Int, imagename:String, scale:Float, transx:Int, transy:Int, col:Int):Void {
		drawimage_freescale_col(x, y, imagename, scale, scale, transx, transy, col);
	}
	
	public static function drawimage_freescale_col(x:Int, y:Int, imagename:String, xscale:Float, yscale:Float, transx:Int, transy:Int, col:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		transx = imagealignonimagex(transx); transy = imagealignonimagey(transy);
		
		shapematrix.identity();
		shapematrix.translate(-transx, -transy);
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x + transx, y + transy);
		ct.color = col;
		drawto.draw(images[imagenum], shapematrix, ct);
	}
	
	public static function drawimage_rotate_col(x:Int, y:Int, imagename:String, rotate:Int, transx:Int, transy:Int, col:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		transx = imagealignonimagex(transx); transy = imagealignonimagey(transy);
		
		shapematrix.identity();
		shapematrix.translate(-transx, -transy);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.translate(x + transx, y + transy);
		ct.color = col;
		drawto.draw(images[imagenum], shapematrix, ct);
	}
	
	public static function drawimage_scale_rotate_col(x:Int, y:Int, imagename:String, scale:Float, rotate:Int, transx:Int, transy:Int, col:Int):Void {
		drawimage_freescale_rotate_col(x, y, imagename, scale, scale, rotate, transx, transy, col);
	}
	
	public static function drawimage_freescale_rotate_col(x:Int, y:Int, imagename:String, xscale:Float, yscale:Float, rotate:Int, transx:Int, transy:Int, col:Int):Void {
		imagenum = imageindex.get(imagename);
		
		x = imagealignx(x); y = imagealigny(y);
		transx = imagealignonimagex(transx); transy = imagealignonimagey(transy);
		
		shapematrix.identity();
		shapematrix.translate(-transx, -transy);
		shapematrix.rotate((rotate * 3.1415) / 180);
		shapematrix.scale(xscale, yscale);
		shapematrix.translate(x + transx, y + transy);
		ct.color = col;
		drawto.draw(images[imagenum], shapematrix, ct);
	}
	
	public static function drawtile(x:Int, y:Int, t:Int):Void {
		if (tiles[currenttileset].fastblit) {
			settpoint(x, y);
			drawto.copyPixels(tiles[currenttileset].tiles[t], tiles[currenttileset].tiles[t].rect, tpoint);
		}else{
			x = tilealignx(x); y = tilealigny(y);
			
			shapematrix.identity();
			shapematrix.translate(x, y);
			drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
		}
	}
	
	public static function tilealignx(x:Int):Int {
		if (x == CENTER) return Gfx.screenwidthmid - Std.int(tiles[currenttileset].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return tiles[currenttileset].width;
		return x;
	}
	
	public static function tilealigny(y:Int):Int {
		if (y == CENTER) return Gfx.screenheightmid - Std.int(tiles[currenttileset].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return tiles[currenttileset].height;
		return y;
	}
	
	public static function tilealignontilex(x:Int):Int {
		if (x == CENTER) return Std.int(tiles[currenttileset].width / 2);
		if (x == LEFT || x == TOP) return 0;
		if (x == RIGHT || x == BOTTOM) return tiles[currenttileset].width;
		return x;
	}
	
	public static function tilealignontiley(y:Int):Int {
		if (y == CENTER) return Std.int(tiles[currenttileset].height / 2);
		if (y == LEFT || y == TOP) return 0;
		if (y == RIGHT || y == BOTTOM) return tiles[currenttileset].height;
		return y;
	}
	
	public static function drawtile_scale(x:Int, y:Int, t:Int, scale:Float, transx:Int, transy:Int):Void {
		if (!tiles[currenttileset].fastblit) {
			x = tilealignx(x); y = tilealigny(y);
			transx = tilealignontilex(transx); transy = tilealignontilex(transy);
			
			shapematrix.identity();
			shapematrix.translate(-transx, -transy);
			shapematrix.scale(scale, scale);
			shapematrix.translate(x + transx, y + transy);
			drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
		}else {
			settpoint(x, y);
			drawto.copyPixels(tiles[currenttileset].tiles[t], tiles[currenttileset].tiles[t].rect, tpoint);
		}
	}
	
	public static function drawtile_freescale(x:Int, y:Int, t:Int, xscale:Float, yscale:Float, transx:Int, transy:Int):Void {
		if (!tiles[currenttileset].fastblit) {
			x = tilealignx(x); y = tilealigny(y);
			transx = tilealignontilex(transx); transy = tilealignontilex(transy);
			
			shapematrix.identity();
			shapematrix.translate(-transx, -transy);
			shapematrix.scale(xscale, yscale);
			shapematrix.translate(x + transx, y + transy);
			drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
		}else {
			settpoint(x, y);
			drawto.copyPixels(tiles[currenttileset].tiles[t], tiles[currenttileset].tiles[t].rect, tpoint);
		}
	}
	
	public static function drawtile_rotate(x:Int, y:Int, t:Int, rotate:Int, transx:Int, transy:Int):Void {
		if (!tiles[currenttileset].fastblit) {
			x = tilealignx(x); y = tilealigny(y);
			transx = tilealignontilex(transx); transy = tilealignontilex(transy);
			
			shapematrix.identity();
			shapematrix.translate(-transx, -transy);
			shapematrix.rotate((rotate * 3.1415) / 180);
			shapematrix.translate(x + transx, y + transy);
			drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
		}else {
			settpoint(x, y);
			drawto.copyPixels(tiles[currenttileset].tiles[t], tiles[currenttileset].tiles[t].rect, tpoint);
		}
	}
	
	public static function drawtile_scale_rotate(x:Int, y:Int, t:Int, scale:Float, rotate:Int, transx:Int, transy:Int):Void {
	  drawtile_freescale_rotate(x, y, t, scale, scale, rotate, transx, transy);
	}
	
	public static function drawtile_freescale_rotate(x:Int, y:Int, t:Int, xscale:Float, yscale:Float, rotate:Int, transx:Int, transy:Int):Void {
	  if (!tiles[currenttileset].fastblit) {
			x = tilealignx(x); y = tilealigny(y);
			transx = tilealignontilex(transx); transy = tilealignontilex(transy);
			
			shapematrix.identity();
			shapematrix.translate(-transx, -transy);
			shapematrix.rotate((rotate * 3.1415) / 180);
			shapematrix.scale(xscale, yscale);
			shapematrix.translate(x + transx, y + transy);
			drawto.draw(tiles[currenttileset].tiles[t], shapematrix);
		}else {
			settpoint(x, y);
			drawto.copyPixels(tiles[currenttileset].tiles[t], tiles[currenttileset].tiles[t].rect, tpoint);
		}
	}
	
	public static function drawtile_col(x:Int, y:Int, t:Int, col:Int):Void {
		if (!tiles[currenttileset].fastblit) {
			x = tilealignx(x); y = tilealigny(y);
			
			shapematrix.identity();
			shapematrix.translate(x, y);
			ct.color = col;
			drawto.draw(tiles[currenttileset].tiles[t], shapematrix, ct);
		}else {
			settpoint(x, y);
			drawto.copyPixels(tiles[currenttileset].tiles[t], tiles[currenttileset].tiles[t].rect, tpoint);
		}
	}
	
	public static function drawtile_scale_col(x:Int, y:Int, t:Int, scale:Float, transx:Int, transy:Int, col:Int):Void {
		drawtile_freescale_col(x, y, t, scale, scale, transx, transy, col);
	}
	
	public static function drawtile_freescale_col(x:Int, y:Int, t:Int, xscale:Float, yscale:Float, transx:Int, transy:Int, col:Int):Void {
		if (!tiles[currenttileset].fastblit) {
			x = tilealignx(x); y = tilealigny(y);
			transx = tilealignontilex(transx); transy = tilealignontilex(transy);
			
			shapematrix.identity();
			shapematrix.scale(xscale, yscale);
			shapematrix.translate(x, y);
			ct.color = col;
			drawto.draw(tiles[currenttileset].tiles[t], shapematrix, ct);
		}
	}
	
	public static function drawtile_rotate_col(x:Int, y:Int, t:Int, rotate:Int, transx:Int, transy:Int, col:Int):Void {
		if (!tiles[currenttileset].fastblit) {
			x = tilealignx(x); y = tilealigny(y);
			
			shapematrix.identity();
			shapematrix.translate(-transx, -transy);
			shapematrix.rotate((rotate * 3.1415) / 180);
			shapematrix.translate(x + transx, y + transy);
			ct.color = col;
			drawto.draw(tiles[currenttileset].tiles[t], shapematrix, ct);
		}
	}
	
	public static function drawtile_scale_rotate_col(x:Int, y:Int, t:Int, scale:Float, rotate:Int, transx:Int, transy:Int, col:Int):Void {
	  drawtile_freescale_rotate_col(x, y, t, scale, scale, rotate, transx, transy, col);
	}
	
	
	public static function drawtile_freescale_rotate_col(x:Int, y:Int, t:Int, xscale:Float, yscale:Float, rotate:Int, transx:Int, transy:Int, col:Int):Void {
	  if (!tiles[currenttileset].fastblit) {
			x = tilealignx(x); y = tilealigny(y);
			transx = tilealignontilex(transx); transy = tilealignontilex(transy);
			
			shapematrix.identity();
			shapematrix.translate(-transx, -transy);
			shapematrix.rotate((rotate * 3.1415) / 180);
			shapematrix.scale(xscale, yscale);
			shapematrix.translate(x + transx, y + transy);
			ct.color = col;
			drawto.draw(tiles[currenttileset].tiles[t], shapematrix, ct);
		}	
	}
	
	public static function drawline(x1:Int, y1:Int, x2:Int, y2:Int, r:Int, g:Int, b:Int):Void {
		tempshape.graphics.clear();
		tempshape.graphics.lineStyle(1, RGB(r, g, b));
		tempshape.graphics.lineTo(x2 - x1, y2 - y1);
		
		shapematrix.translate(x1, y1);
		backbuffer.draw(tempshape, shapematrix);
		shapematrix.translate(-x1, -y1);
	}
	
	public static function drawtri(x1:Int, y1:Int, x2:Int, y2:Int, x3:Int, y3:Int, r:Int, g:Int, b:Int):Void {
		drawline(x1, y1, x2, y2, r, g, b);
		drawline(x2, y2, x3, y3, r, g, b);
		drawline(x3, y3, x1, y1, r, g, b);
	}

	public static function drawbox(x1:Int, y1:Int, w1:Int, h1:Int, r:Int, g:Int, b:Int):Void {
		if (w1 < 0) {
			w1 = -w1;
			x1 = x1 - w1;
		}
		if (h1 < 0) {
			h1 = -h1;
			y1 = y1 - h1;
		}
		settrect(x1, y1, w1, 1); backbuffer.fillRect(trect, RGB(r, g, b));
		settrect(x1, y1 + h1 - 1, w1, 1); backbuffer.fillRect(trect, RGB(r, g, b));
		settrect(x1, y1, 1, h1); backbuffer.fillRect(trect, RGB(r, g, b));
		settrect(x1 + w1 - 1, y1, 1, h1); backbuffer.fillRect(trect, RGB(r, g, b));
	}

	public static function cls():Void {
		fillrect(0, 0, screenwidth, screenheight, 0, 0, 0);
	}

	public static function fillrect(x1:Int, y1:Int, w1:Int, h1:Int, r:Int, g:Int = -1, b:Int = -1):Void {
		settrect(x1, y1, w1, h1);
		if (g == -1 && b == -1) {
			backbuffer.fillRect(trect, r);
		}else{
			backbuffer.fillRect(trect, RGB(r, g, b));
		}
	}
	
	public static function draw_default(i:Int):Void {
		Gfx.changetileset(Obj.entities[i].tileset);
		
		fillrect(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, Gfx.tiles[Gfx.currenttileset].width, Gfx.tiles[Gfx.currenttileset].height, 0x0a0b15);
		drawtile_col(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, Obj.entities[i].drawframe, Obj.entities[i].col);
	}
	
	public static function drawentitymessages():Void {
		for (i in 0...Obj.nentity) {
			if (Obj.entities[i].active) {
				if (!Obj.entities[i].invis) {
					if (Obj.entities[i].messagedelay > 0) {
						drawentitymessage(i); 
					}
				}
			}
		}
	}
	
	public static function drawentitymessage(i:Int):Void {
		var x:Int = Obj.entities[i].xp - World.camerax;
		var y:Int = Obj.entities[i].yp - World.cameray - 1;
		var playerx:Int = Obj.entities[Obj.getplayer()].xp - World.camerax;
		var playery:Int = Obj.entities[Obj.getplayer()].yp - World.cameray;
		x = x - Std.int(Obj.entities[i].message.length / 2);
		if (x < 0) x = 0;
		if (x + Obj.entities[i].message.length >= 48) x = 48 - Obj.entities[i].message.length + 1;
		if (y == -1) y = 1;
		if (y == playery) {
			if (playerx >= x && playerx < x + Obj.entities[i].message.length) {
				y += 2;
				if (y >= 18) y = 18;
			}
		}
		
		Draw.terminalprint(x, y, Obj.entities[i].message, Draw.messagecol(Obj.entities[i].messagecol), true);
	}
	
	public static function draw_unknown(i:Int):Void {
		Gfx.changetileset(Obj.entities[i].tileset);
		
		fillrect(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, Gfx.tiles[Gfx.currenttileset].width, Gfx.tiles[Gfx.currenttileset].height, RGB(0, 0, 0));
		drawtile_col(Std.int(Obj.entities[i].xp - World.camerax) * Gfx.tiles[Gfx.currenttileset].width, Std.int(Obj.entities[i].yp - World.cameray) * Gfx.tiles[Gfx.currenttileset].height, "?".charCodeAt(0), 0x888888);
	}
	
	public static function draw_defaultinit(i:Int, xoff:Int, yoff:Int, t:Int):Void {
		Gfx.changetileset("sprites");
		
		drawtile(Std.int(Obj.initentities[i].xp - xoff), Std.int(Obj.initentities[i].yp - yoff), t);
	}
	
	public static function drawentities():Void {
		for (i in 0...Obj.nentity) {
			if (Obj.entities[i].active) {
				if (!Obj.entities[i].invis) {
					if (Obj.entities[i].collidable) {
						Obj.templates[Obj.entindex.get(Obj.entities[i].rule)].drawentity(i);
					}else {
						//Ok, to be akward, check that there's not also something else here
						var doubledrawcheck:Bool = false;
						for (j in 0 ... i) {
							if (Obj.entities[i].xp == Obj.entities[j].xp) {
								if (Obj.entities[i].yp == Obj.entities[j].yp) {
									doubledrawcheck = true;
								}
							}
						}
						if (!doubledrawcheck) {
							if (Obj.entities[i].active) {
								if (!Obj.entities[i].invis) {
									Obj.templates[Obj.entindex.get(Obj.entities[i].rule)].drawentity(i);	
								}
							}
						}
					}
				}
			}
		}
	}
	
	//Fade functions
	public static function processfade():Void {
		if (fademode > FADED_OUT) {
			if (fademode == FADE_OUT) {
				//prepare fade out
				fadeamount = 0;
				fademode = FADING_OUT;
				Lerp.start("fadeout", 20);
			}else if (fademode == FADING_OUT) {
				fadeamount = Lerp.to(0, 100, "fadeout", "sine_out");
				if (Lerp.justfinished("fadeout")) {
					fademode = FADED_OUT; //faded
				}
			}else if (fademode == FADE_IN) {
				//prepare fade in
				fademode = FADING_IN;
				Lerp.start("fadein", 20);
			}else if (fademode == FADING_IN) {
				fadeamount = Lerp.to(100, 0, "fadein", "sine_in");
				if (Lerp.justfinished("fadein")) {
					fademode = FADED_IN; //normal
				}
			}
		}
	}
	
	public static function fadeout(t:String = "nothing"):Void {
		fademode = FADE_OUT;
		fadeaction = t;
	}
	
	public static function fadein():Void {
		fademode = FADE_IN;
	}
	
	public static function getred(c:Int):Int {
		return (( c >> 16 ) & 0xFF);
	}
	
	public static function getgreen(c:Int):Int {
		return ( (c >> 8) & 0xFF );
	}
	
	public static function getblue(c:Int):Int {
		return ( c & 0xFF );
	}
	
	public static function addcolours(one:Int, two:Int):Int {
		var r:Int = getred(one) + getred(two);
		var g:Int = getgreen(one) + getgreen(two);
		var b:Int = getblue(one) + getblue(two);
		
		if (r > 255) r = 255;
		if (g > 255) g = 255;
		if (b > 255) b = 255;
		
		return RGB(r, g, b);
	}
	
	public static function RGB(red:Int, green:Int, blue:Int):Int {
		return (blue | (green << 8) | (red << 16));
	}
	
	public static function RGBA(red:Int, green:Int, blue:Int):Int {
		return (blue | (green << 8) | (red << 16)) + 0xFF000000;
	}
	
	public static function shade(currentcol:Int, a:Float):Int {
		if (a > 1.0) a = 1.0;	if (a < 0.0) a = 0.0;
		return RGB(Std.int((getred(currentcol) * a)), Std.int((getgreen(currentcol) * a)), Std.int((getblue(currentcol) * a)));
	}
	  
	public static function hsl2rgb(h:Float, s:Float, l:Float):Int{
		var q:Float = if (l < 1 / 2)
		{
				l * (1 + s);
		} else
		{
				l + s - (l * s);
		}
		
		var p:Float = 2 * l - q;
		
		var hk:Float = (h % 360) / 360;
		
		var tr:Float = hk + 1 / 3;
		var tg:Float = hk;
		var tb:Float = hk - 1 / 3;
		
		var tc:Array<Float> = [tr,tg,tb];
		for (n in 0 ... tc.length)
		{
				var t:Float = tc[n];
				if (t < 0) t += 1;
				if (t > 1) t -= 1;
				tc[n] = if (t < 1 / 6)
				{
						p + ((q - p) * 6 * t);
				} else if (t < 1 / 2)
				{
						q;
				} else if (t < 2 / 3)
				{
						p + ((q - p) * 6 * (2 / 3 - t));
				} else
				{
						p;
				}
		}
		
		return RGB(Std.int(tc[0] * 255), Std.int(tc[1] * 255), Std.int(tc[2] * 255));
	}
	
	//Render functions
	public static function normalrender():Void {
		backbuffer.unlock();
		
		screenbuffer.lock();
		screenbuffer.copyPixels(backbuffer, backbuffer.rect, tl, null, null, false);
		screenbuffer.unlock();
		
		backbuffer.lock();
	}

	public static function screenrender():Void {
		if (test) {
			for (k in 0 ... teststring.length) {
				for (j in -1 ... 2) {
					for (i in -1 ... 2) {
						Text.print(2 + i, j + Std.int(2 + ((teststring.length - 1 - k) * (Text.height() + 2))), teststring[k], Gfx.RGB(0, 0, 0));
					}
				}
				Text.print(2, Std.int(2 + ((teststring.length-1-k) * (Text.height() + 2))), teststring[k], Gfx.RGB(255, 255, 255));
			}
		}
		
		if (flashlight > 0) { flashlight--; Draw.gfxflashlight(); }
		if (screenshake > 0) {	screenshake--;	Draw.gfxscreenshake();}else{
			normalrender();
		}
	}
	
	public static function setzoom(t:Int):Void {
		screen.width = screenwidth * t;
		screen.height = screenheight * t;
		screen.x = (screenwidth - (screenwidth * t)) / 2;
		screen.y = (screenheight - (screenheight * t)) / 2;
	}
	
	public static function updategraphicsmode():Void {
		//This was always incomplete
		if (fullscreen) {
			//gfx.context.configureBackBuffer(game.fullscreenwidth, game.fullscreenheight, 0, true);
			//stage.fullScreenSourceRect = new Rectangle(0, 0, Gfx.screenwidth, Gfx.screenheight);
			Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			
			var xScaleFresh:Float = cast(devicexres, Float) / cast(screenwidth, Float);
			var yScaleFresh:Float = cast(deviceyres, Float) / cast(screenheight, Float);
			if (xScaleFresh < yScaleFresh){
				screen.width = screenwidth * xScaleFresh;
				screen.height = screenheight * xScaleFresh;
			}else if (yScaleFresh < xScaleFresh){
				screen.width = screenwidth * yScaleFresh;
				screen.height = screenheight * yScaleFresh;
			} else {
				screen.width = screenwidth * xScaleFresh;
				screen.height = screenheight * yScaleFresh;
			}
			screen.x = (cast(devicexres, Float) / 2.0) - (screen.width / 2.0);
			screen.y = (cast(deviceyres, Float) / 2.0) - (screen.height / 2.0);
			//Mouse.hide();
		}else {
			Lib.current.stage.displayState = StageDisplayState.NORMAL;
			screen.width = screenwidth * screenscale;
			screen.height = screenheight * screenscale;
			screen.x = 0.0;
			screen.y = 0.0;
			//gfx.context.configureBackBuffer(gfx.screenwidth, gfx.screenheight, 0, true);
			//stage.displayState = StageDisplayState.NORMAL;
			//Mouse.show();
		}
	}
	
	public static var screenwidth:Int;
	public static var screenheight:Int;
	public static var screenwidthmid:Int;
	public static var screenheightmid:Int;
	public static var screentilewidth:Int;
	public static var screentileheight:Int;
	
	public static var screenscale:Int;
	public static var devicexres:Int;
	public static var deviceyres:Int;
	public static var fullscreen:Bool;
	
	public static var tiles:Array<Tileset> = new Array<Tileset>();
	public static var tilesetindex:Map<String, Int> = new Map<String, Int>();
	public static var currenttileset:Int;
	public static var currenttilesetname:String;
	
	public static var drawto:BitmapData;
	
	public static var images:Array<BitmapData> = new Array<BitmapData>();
	public static var imagenum:Int;
	public static var ct:ColorTransform;
	public static var images_rect:Rectangle;
	public static var tl:Point = new Point(0, 0);
	public static var trect:Rectangle;
	public static var tpoint:Point;
	public static var tbuffer:BitmapData;
	public static var imageindex:Map<String, Int> = new Map<String, Int>();
	
	public static var buffer:BitmapData;
	
	public static var temptile:BitmapData;
	//Actual backgrounds
	public static var backbuffer:BitmapData;
	public static var screenbuffer:BitmapData;
	public static var screen:Bitmap;
	//Tempshape
	public static var tempshape:Shape = new Shape();
	public static var shapematrix:Matrix = new Matrix();
	//Fade Transition (room changes, game state changes etc)
	public static var fademode:Int;
	public static var fadeamount:Int;
	public static var fadeaction:String;
	
	public static var screenshake:Int;
	public static var flashlight:Int;
	
	public static var alphamult:Int;
	public static var textboxbuffer:BitmapData;
	public static var gfxstage:Stage;
	
	public static var test:Bool;
	public static var teststring:Array<String> = new Array<String>();
	
	public static var LEFT:Int = -20000;
	public static var RIGHT:Int = -20001;
	public static var TOP:Int = -20002;
	public static var BOTTOM:Int = -20003;
	public static var CENTER:Int = -20004;
	
	public static var FADED_IN:Int = 0;
	public static var FADED_OUT:Int = 1;
	public static var FADE_OUT:Int = 2;
	public static var FADING_OUT:Int = 3;
	public static var FADE_IN:Int = 4;
	public static var FADING_IN:Int = 5;
}