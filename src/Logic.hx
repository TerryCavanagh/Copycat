package;

import com.terry.*;
import gamecontrol.*;
import config.*;

class Logic {
	public static var player:Int;
	
	public static function titlelogic() {
		Game.menudelay++;
		if (Game.menudelay >= 240) {
			Game.menudelay = 0;
			Game.menuframe = (Game.menuframe + 1) % 3;
 		}
	}
	
	public static function gamelogic() {
		if (Game.exitmenu) {
		
		}else{
			if (Game.messagedelay > 0) Game.messagedelay--;
			
			if (Game.ascenddelay > 0) {
				Game.ascenddelay++;
				
				if (Game.ascenddelay == 2) {
					//Clear away enemies
					for (i in 0 ... Obj.nentity) {
						if (Obj.entities[i].active) {
							if (Obj.entities[i].rule == "enemy") {
								Obj.entities[i].active = false;
							}
						}
					}
					Game.enemyqueuesize = 0;
					
					for (j in 0 ... World.mapheight) {
						for (i in 0 ... World.mapwidth) {
							Localworld.highlightpoint(i, j);
						}
					}
					Localworld.updatelighting();
				}
				
				if (Game.ascenddelay == 120) {
					//Clear away walls
					for (j in 0 ... World.mapheight) {
						for (i in 0 ... World.mapwidth) {
							Localworld.highlightpoint(i, j);
							World.placetile(i, j, Localworld.FLOOR);
						}
					}
					Localworld.updatelighting();
					
					Music.playef("ascend");
				}
				
				if (Game.ascenddelay == 240) {
					Music.playef("ascend");
				}
				
				if (Game.ascenddelay > 240 && Game.ascenddelay < 360) {
					player = Obj.getplayer();
					Game.tx = Obj.entities[player].xp;
					Game.ty = Obj.entities[player].yp;
					
					for (j in 0 ... World.mapheight) {
						for (i in 0 ... World.mapwidth) {
							Localworld.highlightpointoff(i, j);
						}
					}
					Localworld.raytrace(Game.tx, Game.ty, (Help.hueglow + 350) % 360, 20);
					Localworld.raytrace(Game.tx, Game.ty, Help.hueglow, 20);
					Localworld.raytrace(Game.tx, Game.ty, (Help.hueglow + 10) % 360, 20);
					
					Localworld.raytrace(Game.tx, Game.ty, (Help.hueglow+80)%360, 20);
					Localworld.raytrace(Game.tx, Game.ty, (Help.hueglow+90)%360, 20);
					Localworld.raytrace(Game.tx, Game.ty, (Help.hueglow + 100) % 360, 20);
					
					Localworld.raytrace(Game.tx, Game.ty, (Help.hueglow+170)%360, 20);
					Localworld.raytrace(Game.tx, Game.ty, (Help.hueglow+180)%360, 20);
					Localworld.raytrace(Game.tx, Game.ty, (Help.hueglow + 190) % 360, 20);
					
					Localworld.raytrace(Game.tx, Game.ty, (Help.hueglow + 260) % 360, 20);
					Localworld.raytrace(Game.tx, Game.ty, (Help.hueglow+270)%360, 20);
					Localworld.raytrace(Game.tx, Game.ty, (Help.hueglow+280)%360, 20);
				}
				
				if (Game.ascenddelay == 360) {
					Music.playef("bomb");
					//Clear away player
					Obj.entities[Obj.getplayer()].active = false;
					for (j in 0 ... World.mapheight) {
						for (i in 0 ... World.mapwidth) {
							Localworld.highlightpoint(i, j);
						}
					}
					Localworld.updatelighting();
				}
				
				
				if (Game.ascenddelay == 460) {
					Game.changestate(Game.TITLEMODE);
				}
				
				Game.clearhighlight();
			}else if (Game.nukedelay > 0) {
				Game.nukedelay--;
				if (Game.nukedelay == 0) {
					for (j in 0 ... Gfx.screentileheight) {
						for (i in 0 ... Gfx.screentilewidth) {
							Localworld.highlightpoint(i, j);
						}
					}
				}
			}else{
				Game.clearhighlight();
				
				//Deal with turns
				if (Game.turn == "playermove") {
				}
				
				if (Game.turn == "doplayermove") {
					//Ok: the player ALWAYS gets to move first now.
					//First, is there a collision?
					player = Obj.getplayer();
					while (!Obj.entities[player].actionset) Game.figureoutplayermove(player);
					if (Obj.entities[player].actionset && Obj.entities[player].action == "nothing") {
						//Cancel the move, tried to walk into a wall or something.
						Game.turn = "playermove";
						if (Game.currentweapon == "wallgun") {
							Game.tx = Obj.entities[player].xp;
							Game.ty = Obj.entities[player].yp;
							Game.tdir = Obj.entities[player].dir;
							
							Game.tx += Localworld.xstep(Game.tdir);
							Game.ty += Localworld.ystep(Game.tdir);
							
							World.placetile(Game.tx, Game.ty, Localworld.WALL);
						}
					}else {
						//Ok, valid! Move on.
						Game.resetenemymoves();
						Game.turn = "doplayermove2";
					}
				}
				
				if (Game.turn == "doplayermove2") {
					//This does the actual move: puts the player in a new direction/position
					player = Obj.getplayer();
					if (Help.getroot(Obj.entities[player].action, "_") == "move") {
						if (Obj.entities[player].action == "move_up") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.UP;
							Obj.entities[player].yp--;
						}else if (Obj.entities[player].action == "move_down") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.DOWN;
							Obj.entities[player].yp++;
						}else if (Obj.entities[player].action == "move_left") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.LEFT;
							Obj.entities[player].xp--;
						}else if (Obj.entities[player].action == "move_right") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.RIGHT;
							Obj.entities[player].xp++;
						}
					}else if (Help.getroot(Obj.entities[player].action, "_") == "dashmove") {
						if (Obj.entities[player].action == "dashmove_up") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.UP;
							Obj.entities[player].yp--;
						}else if (Obj.entities[player].action == "dashmove_down") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.DOWN;
							Obj.entities[player].yp++;
						}else if (Obj.entities[player].action == "dashmove_left") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.LEFT;
							Obj.entities[player].xp--;
						}else if (Obj.entities[player].action == "dashmove_right") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.RIGHT;
							Obj.entities[player].xp++;
						}
					}else if (Help.getroot(Obj.entities[player].action, "_") == "backwardsmove") {
						if (Obj.entities[player].action == "backwardsmove_up") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.DOWN;
							Obj.entities[player].yp--;
						}else if (Obj.entities[player].action == "backwardsmove_down") { 
							if (Obj.entities[player].canturn) Obj.entities[player].dir = Help.UP;
							Obj.entities[player].yp++;
						}else if (Obj.entities[player].action == "backwardsmove_left") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.RIGHT;
							Obj.entities[player].xp--;
						}else if (Obj.entities[player].action == "backwardsmove_right") { 
							if (Obj.entities[player].canturn) Obj.entities[player].dir = Help.LEFT;
							Obj.entities[player].xp++;
						}
					}else if (Help.getroot(Obj.entities[player].action, "_") == "doublemove") {
						if (Obj.entities[player].action == "doublemove_up") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.UP;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
							Obj.entities[player].yp -= 1;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
							Obj.entities[player].yp -= 1;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
						}else if (Obj.entities[player].action == "doublemove_down") { 
							if (Obj.entities[player].canturn) Obj.entities[player].dir = Help.DOWN;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
							Obj.entities[player].yp += 1;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
							Obj.entities[player].yp += 1;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
						}else if (Obj.entities[player].action == "doublemove_left") { 
							if(Obj.entities[player].canturn) Obj.entities[player].dir = Help.LEFT;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
							Obj.entities[player].xp -= 1;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
							Obj.entities[player].xp -= 1;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
						}else if (Obj.entities[player].action == "doublemove_right") { 
							if (Obj.entities[player].canturn) Obj.entities[player].dir = Help.RIGHT;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
							Obj.entities[player].xp += 1;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
							Obj.entities[player].xp += 1;
							Localworld.highlightpoint(Obj.entities[player].xp, Obj.entities[player].yp);
						}
					}else if (Obj.entities[player].action == "clockwise") { 
						Obj.entities[player].dir = Help.clockwise(Obj.entities[player].dir);
					}else if (Obj.entities[player].action == "anticlockwise") { 
						Obj.entities[player].dir = Help.anticlockwise(Obj.entities[player].dir);
					}
					
					Game.turn = "doplayermove3";
				}
				
				if (Game.turn == "doplayermove3") {
					//Finally, from our new position, do the attack stuff (swords, walls).
					
					//Wall gun places walls in front of player
					if (Game.currentweapon == "wallgun") {
						player = Obj.getplayer();
						Game.tx = Obj.entities[player].xp;
						Game.ty = Obj.entities[player].yp;
						Game.tdir = Obj.entities[player].dir;
						
						Game.tx += Localworld.xstep(Game.tdir);
						Game.ty += Localworld.ystep(Game.tdir);
						
						Game.temp = Game.checkforenemy(Game.tx, Game.ty);
						if (Game.temp >= 0) {
							if(Obj.entities[Game.temp].type == "swordguy"){
								if (Help.oppositedirection(Obj.entities[Game.temp].dir) == Obj.entities[player].dir) {
									Game.killenemy(Game.temp);
									Game.hurtplayer();
									Game.checkifplayerdead();
								}else{
									Game.killenemy(Game.temp);
								}
							}else {
								Game.killenemy(Game.temp);
							}
						}
						if (!Game.gameover) World.placetile(Game.tx, Game.ty, Localworld.WALL);
					}
					
					//Do player sword first
					if (Inventory.itemlist[Inventory.equippedgadget].issword) {
						player = Obj.getplayer();
						Game.tx = Obj.entities[player].xp;
						Game.ty = Obj.entities[player].yp;
						Game.tdir = Obj.entities[player].dir;
						
						if (Obj.entities[player].action == "anticlockwise") {
							Game.tdir = Help.clockwise(Game.tdir);
							Game.temp = Game.checkforenemy(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
							if (Game.temp == -2) {
								World.placetile(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir), Localworld.FLOOR);
								Game.playbreakwall();
							}else if (Game.temp >= 0) {
								Game.killenemy(Game.temp);
							}
							Localworld.highlightpoint(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
							Game.tdir = Help.anticlockwise(Game.tdir);
							Localworld.highlightpoint(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
							
							Game.temp = Game.checkforenemy(Game.tx + Localworld.xstep_between(Game.tdir, Help.clockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.clockwise(Game.tdir)));
							Localworld.highlightpoint(Game.tx + Localworld.xstep_between(Game.tdir, Help.clockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.clockwise(Game.tdir)));
							if (Game.temp == -2) {
								World.placetile(Game.tx + Localworld.xstep_between(Game.tdir, Help.clockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.clockwise(Game.tdir)), Localworld.FLOOR);
								Game.playbreakwall();
							}else if (Game.temp >= 0) {
								Game.killenemy(Game.temp);
							}
						}
						
						if (Obj.entities[player].action == "clockwise") {
							Game.tdir = Help.anticlockwise(Game.tdir);
							Game.temp = Game.checkforenemy(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
							if (Game.temp == -2) {
								World.placetile(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir), Localworld.FLOOR);
								Game.playbreakwall();
							}else if (Game.temp >= 0) {
								Game.killenemy(Game.temp);
							}
							Localworld.highlightpoint(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
							Game.tdir = Help.clockwise(Game.tdir);
							Localworld.highlightpoint(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
							
							Game.temp = Game.checkforenemy(Game.tx + Localworld.xstep_between(Game.tdir, Help.anticlockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.anticlockwise(Game.tdir)));
							Localworld.highlightpoint(Game.tx + Localworld.xstep_between(Game.tdir, Help.anticlockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.anticlockwise(Game.tdir)));
							if (Game.temp == -2) {
								World.placetile(Game.tx + Localworld.xstep_between(Game.tdir, Help.anticlockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.anticlockwise(Game.tdir)), Localworld.FLOOR);
								Game.playbreakwall();
							}else if (Game.temp >= 0) {
								Game.killenemy(Game.temp);
							}
						}
						
						Game.temp = Game.checkforenemy(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
						if (Game.temp == -2) {
							World.placetile(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir), Localworld.FLOOR);
							Game.playbreakwall();
						}else if (Game.temp >= 0) {
							//trace("player has killed enemy " + Std.string(Game.temp) + " with a sword.");
							//If the enemy has their own sword pointing towards you, then we try
							//to push them back.
							if(Obj.entities[Game.temp].type == "swordguy"){
								if (Help.oppositedirection(Obj.entities[Game.temp].dir) == Obj.entities[player].dir) {
									//Attempt to move backwards!
									Game.tdir = Help.oppositedirection(Obj.entities[Game.temp].dir);
									if (Game.checkforenemy(Obj.entities[Game.temp].xp + Localworld.xstep(Game.tdir), Obj.entities[Game.temp].yp + Localworld.ystep(Game.tdir)) == -1) {
										Obj.entities[Game.temp].action = "backwardsdouble" + Game.movestring(Game.tdir);
										Obj.entities[Game.temp].actionset = true;
										//Music.playef("pushback");
										Music.playef("swordclash");
									}else {
										//Move isn't possible - undo it.
										Game.cantmove();
										Game.turn = "playermove";
										Obj.entities[player].action = "cancel";
									}
								}else{
									Game.killenemy(Game.temp);
								}
							}else {
								Game.killenemy(Game.temp);
							}
						}
					}
					
					if (Obj.entities[player].action != "cancel") {
						Game.turn = "figureoutmove";
						//Do bomb stuff now!
						for (i in 0 ... Obj.nentity) {
							if (Obj.entities[i].active) {
								Obj.updateentities(i);
							}
						}
					}
				}
				
				if (Game.turn == "figureoutmove") {
					//Right, now the enemie have their go.
					//trace("Starting new phase: Figuring out moves");
					player = Obj.getplayer();
					Obj.entities[player].action = "nothing";
					Obj.entities[player].actionset = true;
					
					for (i in 0 ... Obj.nentity) {
						if (Obj.entities[i].active) {
							if (!Obj.entities[i].actionset) {
								Game.clearchain();
								while (!Obj.entities[i].actionset) Game.figureoutmove(i);
							}
						}
					}
					
					if (Game.allactionsset()) {
						Game.turn = "domove";
						for (i in 0 ... Obj.nentity) {
							if (Obj.entities[i].active) {
								if (Obj.entities[i].action == "nothing" && Obj.entities[i].rule!="player") {
									//trace("*** ENTITY " + Std.string(i) + " IS DOING NOTHING THIS TURN ***");
									
									if (Game.couldtryagain(i)) {
										//Enemies get another try if they can move
										Game.resetenemymove(i);
										//trace("Can we try again?");
										//Go through list of possible moves. If any of them are a hit, great, we
										//can try again!
										var canmoveagain:Bool = false;
										Game.tx1 = Game.getcurrentx(i); 
										Game.ty1 = Game.getcurrenty(i);
										
										var j:Int = 0;
										while(j < Obj.entities[i].numpossibleactions) {
											if (Obj.entities[i].possibleactions[j] == "move_up") {
												canmoveagain = !Game.couldtry(Game.tx1, Game.ty1 - 1, i);
											}else if (Obj.entities[i].possibleactions[j] == "move_down") {
												canmoveagain = !Game.couldtry(Game.tx1, Game.ty1 + 1, i);
											}else if (Obj.entities[i].possibleactions[j] == "move_left") {
												canmoveagain = !Game.couldtry(Game.tx1 - 1, Game.ty1, i);
											}else if (Obj.entities[i].possibleactions[j] == "move_right") {
												canmoveagain = !Game.couldtry(Game.tx1 + 1, Game.ty1, i);
											}else if (Obj.entities[i].possibleactions[j] == "dashmove_up") {
												canmoveagain = !Game.couldtry(Game.tx1, Game.ty1 - 1, i);
											}else if (Obj.entities[i].possibleactions[j] == "dashmove_down") {
												canmoveagain = !Game.couldtry(Game.tx1, Game.ty1 + 1, i);
											}else if (Obj.entities[i].possibleactions[j] == "dashmove_left") {
												canmoveagain = !Game.couldtry(Game.tx1 - 1, Game.ty1, i);
											}else if (Obj.entities[i].possibleactions[j] == "dashmove_right") {
												canmoveagain = !Game.couldtry(Game.tx1 + 1, Game.ty1, i);
											}else if (Obj.entities[i].possibleactions[j] == "backwardsmove_up") {
												canmoveagain = !Game.couldtry(Game.tx1, Game.ty1 - 1, i);
											}else if (Obj.entities[i].possibleactions[j] == "backwardsmove_down") {
												canmoveagain = !Game.couldtry(Game.tx1, Game.ty1 + 1, i);
											}else if (Obj.entities[i].possibleactions[j] == "backwardsmove_left") {
												canmoveagain = !Game.couldtry(Game.tx1 - 1, Game.ty1, i);
											}else if (Obj.entities[i].possibleactions[j] == "backwardsmove_right") {
												canmoveagain = !Game.couldtry(Game.tx1 + 1, Game.ty1, i);
											}else if (Obj.entities[i].possibleactions[j] == "backwardsdoublemove_up") {
												canmoveagain = !Game.couldtry(Game.tx1, Game.ty1 - 1, i);
											}else if (Obj.entities[i].possibleactions[j] == "backwardsdoublemove_down") {
												canmoveagain = !Game.couldtry(Game.tx1, Game.ty1 + 1, i);
											}else if (Obj.entities[i].possibleactions[j] == "backwardsdoublemove_left") {
												canmoveagain = !Game.couldtry(Game.tx1 - 1, Game.ty1, i);
											}else if (Obj.entities[i].possibleactions[j] == "backwardsdoublemove_right") {
												canmoveagain = !Game.couldtry(Game.tx1 + 1, Game.ty1, i);
											}else if (Obj.entities[i].possibleactions[j] == "doublemove_up") {
												canmoveagain = !Game.couldtry(Game.tx1, Game.ty1 - 2, i);
											}else if (Obj.entities[i].possibleactions[j] == "doublemove_down") {
												canmoveagain = !Game.couldtry(Game.tx1, Game.ty1 + 2, i);
											}else if (Obj.entities[i].possibleactions[j] == "doublemove_left") {
												canmoveagain = !Game.couldtry(Game.tx1 - 2, Game.ty1, i);
											}else if (Obj.entities[i].possibleactions[j] == "doublemove_right") {
												canmoveagain = !Game.couldtry(Game.tx1 + 2, Game.ty1, i);
											}
											j++;
											if (canmoveagain) j = Obj.entities[i].numpossibleactions;
										}
										if (canmoveagain) {
											//trace("*** LET'S TRY AGAIN! ***");	
											Game.turn = "figureoutmove";
										}else {
											//trace("*** CAN'T DO ANYTHING, GIVING UP ***");								
											Obj.entities[i].action = "nothing";
											Obj.entities[i].actionset = true;
											Obj.entities[i].numpossibleactions = 0;
										}
									}
								}
							}
						}
					}
				}
				
				if (Game.turn == "domove") {
					//trace("Entering phase: Do moves!");
					//trace("------------");
					//Do it!
					for (i in 0 ... Obj.nentity) {
						if (Obj.entities[i].active) {
							if (Help.getroot(Obj.entities[i].action, "_") == "move") {
								if (Obj.entities[i].action == "move_up") { 
									if(Obj.entities[i].canturn) Obj.entities[i].dir = Help.UP;
									Obj.entities[i].yp--;
								}else if (Obj.entities[i].action == "move_down") { 
									if(Obj.entities[i].canturn) Obj.entities[i].dir = Help.DOWN;
									Obj.entities[i].yp++;
								}else if (Obj.entities[i].action == "move_left") { 
									if(Obj.entities[i].canturn) Obj.entities[i].dir = Help.LEFT;
									Obj.entities[i].xp--;
								}else if (Obj.entities[i].action == "move_right") { 
									if(Obj.entities[i].canturn) Obj.entities[i].dir = Help.RIGHT;
									Obj.entities[i].xp++;
								}
							}else if (Help.getroot(Obj.entities[i].action, "_") == "backwardsmove") {
								if (Obj.entities[i].action == "backwardsmove_up") { 
									if(Obj.entities[i].canturn) Obj.entities[i].dir = Help.DOWN;
									Obj.entities[i].yp--;
								}else if (Obj.entities[i].action == "backwardsmove_down") { 
									if (Obj.entities[i].canturn) Obj.entities[i].dir = Help.UP;
									Obj.entities[i].yp++;
								}else if (Obj.entities[i].action == "backwardsmove_left") { 
									if(Obj.entities[i].canturn) Obj.entities[i].dir = Help.RIGHT;
									Obj.entities[i].xp--;
								}else if (Obj.entities[i].action == "backwardsmove_right") { 
									if (Obj.entities[i].canturn) Obj.entities[i].dir = Help.LEFT;
									Obj.entities[i].xp++;
								}
							}else if (Help.getroot(Obj.entities[i].action, "_") == "doublemove") {
								if (Obj.entities[i].action == "doublemove_up") { 
									if(Obj.entities[i].canturn) Obj.entities[i].dir = Help.UP;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Obj.entities[i].yp -= 1;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Obj.entities[i].yp -= 1;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
								}else if (Obj.entities[i].action == "doublemove_down") { 
									if (Obj.entities[i].canturn) Obj.entities[i].dir = Help.DOWN;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Obj.entities[i].yp += 1;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Obj.entities[i].yp += 1;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
								}else if (Obj.entities[i].action == "doublemove_left") { 
									if(Obj.entities[i].canturn) Obj.entities[i].dir = Help.LEFT;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Obj.entities[i].xp -= 1;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Obj.entities[i].xp -= 1;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
								}else if (Obj.entities[i].action == "doublemove_right") { 
									if (Obj.entities[i].canturn) Obj.entities[i].dir = Help.RIGHT;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Obj.entities[i].xp += 1;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Obj.entities[i].xp += 1;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
								}
							}else if (Obj.entities[i].action == "clockwise") { 
								Obj.entities[i].dir = Help.clockwise(Obj.entities[i].dir);
							}else if (Obj.entities[i].action == "anticlockwise") { 
								Obj.entities[i].dir = Help.anticlockwise(Obj.entities[i].dir);
							}
						}
					}
					
					for (i in 0 ... Obj.nentity) {
						if (Obj.entities[i].active) {
							if (Help.getroot(Obj.entities[i].action, "_") == "backwardsdoublemove") {
								if (Obj.entities[i].action == "backwardsdoublemove_up") { 
									if(Obj.entities[i].canturn) Obj.entities[i].dir = Help.DOWN;
									Obj.entities[i].yp--;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Game.temp = Game.checkforenemy(Obj.entities[i].xp, Obj.entities[i].yp - 1);
									while (Game.temp == -1 && Game.temp != i) {
										Obj.entities[i].yp--;
										Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
										Game.temp = Game.checkforenemy(Obj.entities[i].xp, Obj.entities[i].yp - 1);
									}
								}else if (Obj.entities[i].action == "backwardsdoublemove_down") { 
									if (Obj.entities[i].canturn) Obj.entities[i].dir = Help.UP;
									Obj.entities[i].yp++;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Game.temp = Game.checkforenemy(Obj.entities[i].xp, Obj.entities[i].yp + 1);
									while (Game.temp == -1 && Game.temp != i) {
										Obj.entities[i].yp++;
										Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
										Game.temp = Game.checkforenemy(Obj.entities[i].xp, Obj.entities[i].yp + 1);
									}
								}else if (Obj.entities[i].action == "backwardsdoublemove_left") { 
									if(Obj.entities[i].canturn) Obj.entities[i].dir = Help.RIGHT;
									Obj.entities[i].xp--;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Game.temp = Game.checkforenemy(Obj.entities[i].xp - 1, Obj.entities[i].yp);
									while (Game.temp == -1 && Game.temp != i) {
										Obj.entities[i].xp--;
										Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
										Game.temp = Game.checkforenemy(Obj.entities[i].xp - 1, Obj.entities[i].yp);
									}
								}else if (Obj.entities[i].action == "backwardsdoublemove_right") { 
									if (Obj.entities[i].canturn) Obj.entities[i].dir = Help.LEFT;
									Obj.entities[i].xp++;
									Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
									Game.temp = Game.checkforenemy(Obj.entities[i].xp + 1, Obj.entities[i].yp);
									while (Game.temp == -1 && Game.temp != i) {
										Obj.entities[i].xp++;
										Localworld.highlightpoint(Obj.entities[i].xp, Obj.entities[i].yp);
										Game.temp = Game.checkforenemy(Obj.entities[i].xp + 1, Obj.entities[i].yp);
									}
								}
							}
						}
					}
					
					for (i in 0 ... Obj.nentity) {
						if (Obj.entities[i].active) {
							if (Help.getroot(Obj.entities[i].action, "_") == "dashmove") {
								if (Obj.entities[i].action == "dashmove_up") { 
									Obj.entities[i].dir = Help.UP;
									Game.dashmove(i);
								}else if (Obj.entities[i].action == "dashmove_down") { 
									Obj.entities[i].dir = Help.DOWN;
									Game.dashmove(i);
								}else if (Obj.entities[i].action == "dashmove_left") { 
									Obj.entities[i].dir = Help.LEFT;
									Game.dashmove(i);
								}else if (Obj.entities[i].action == "dashmove_right") { 
									Obj.entities[i].dir = Help.RIGHT;
									Game.dashmove(i);
								}
							}
						}
					}
					
					Game.turn = "playermove";
					
					if (Game.playerbomb > 0) {
						Game.playerbomb--;
					}
					
					//Builders drop walls!
					for (i in 0 ... Obj.nentity) {
						if (Obj.entities[i].active) {
							if (Obj.entities[i].rule == "enemy") {
								if (Obj.entities[i].type == "swordguy") {
									Game.destroywall(i);
									/*
									player = Obj.getplayer();
									if (Obj.entities[i].xp + Localworld.xstep(Obj.entities[i].dir) == Obj.entities[player].xp) {
										if (Obj.entities[i].yp + Localworld.ystep(Obj.entities[i].dir) == Obj.entities[player].yp) {
											Game.hurtplayer();
											Game.checkifplayerdead();
										}
									}
									*/
								}
								if (Obj.entities[i].type == "builderguy") {
									if (Game.speedframe < 3) {
										Game.placewall(i, 2);
										Game.playbreakwall();
									}else if (Game.speedframe >= 6 && Game.speedframe < 9) {
										Game.placewall(i, 2);
										Game.playbreakwall();
									}
									
									if (Obj.entities[i].action == "nothing") {
										for (j in 0 ... 4) {
											Game.destroywall(i, j);
											Game.playbreakwall();
										}
									}
								}
							}
						}
					}
					
					Localworld.updatelighting();
					//Localworld.swordclink();
					//Localworld.updatefire();
					
					//If the enemy ACTUALLY walks on to the player sword, they should die
					//but this probably shouldn't happen.
					if (Inventory.itemlist[Inventory.equippedgadget].issword) {
						player = Obj.getplayer();
						Game.tx = Obj.entities[player].xp;
						Game.ty = Obj.entities[player].yp;
						Game.tdir = Obj.entities[player].dir;
						
						Game.temp = Game.checkforenemy(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
						if (Game.temp == -2) {
							World.placetile(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir), Localworld.FLOOR);
							Game.playbreakwall();
						}else if (Game.temp >= 0) {
							//trace("player has killed enemy " + Std.string(Game.temp) + " with a sword.");
							Game.killenemy(Game.temp);
						}
					}
					
					for (i in 0 ... Obj.nentity) {
						if (Obj.entities[i].active) {
							if (Obj.entities[i].rule == "enemy" && Obj.entities[i].type == "swordguy") {
								Game.tx = Obj.entities[i].xp;
								Game.ty = Obj.entities[i].yp;
								Game.tdir = Obj.entities[i].dir;
								
								if (Obj.entities[i].action == "anticlockwise") {
									Game.tdir = Help.clockwise(Game.tdir);
									Game.temp = Game.checkforplayerorwall(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
									if (Game.temp == -2) {
										World.placetile(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir), Localworld.FLOOR);
										Game.playbreakwall();
									}else if (Game.temp >= 0) {
										Game.hurtplayer();
										Game.checkifplayerdead();
									}
									Localworld.highlightpoint(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
									Game.tdir = Help.anticlockwise(Game.tdir);
									Localworld.highlightpoint(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
									
									Game.temp = Game.checkforplayerorwall(Game.tx + Localworld.xstep_between(Game.tdir, Help.clockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.clockwise(Game.tdir)));
									Localworld.highlightpoint(Game.tx + Localworld.xstep_between(Game.tdir, Help.clockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.clockwise(Game.tdir)));
									if (Game.temp == -2) {
										World.placetile(Game.tx + Localworld.xstep_between(Game.tdir, Help.clockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.clockwise(Game.tdir)), Localworld.FLOOR);
										Game.playbreakwall();
									}else if (Game.temp >= 0) {
										Game.hurtplayer();
										Game.checkifplayerdead();
									}
								}
								
								if (Obj.entities[i].action == "clockwise") {
									Game.tdir = Help.anticlockwise(Game.tdir);
									Game.temp = Game.checkforplayerorwall(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
									if (Game.temp == -2) {
										World.placetile(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir), Localworld.FLOOR);
										Game.playbreakwall();
									}else if (Game.temp >= 0) {
										Game.hurtplayer();
										Game.checkifplayerdead();
									}
									Localworld.highlightpoint(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
									Game.tdir = Help.clockwise(Game.tdir);
									Localworld.highlightpoint(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
									
									Game.temp = Game.checkforplayerorwall(Game.tx + Localworld.xstep_between(Game.tdir, Help.anticlockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.anticlockwise(Game.tdir)));
									Localworld.highlightpoint(Game.tx + Localworld.xstep_between(Game.tdir, Help.anticlockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.anticlockwise(Game.tdir)));
									if (Game.temp == -2) {
										World.placetile(Game.tx + Localworld.xstep_between(Game.tdir, Help.anticlockwise(Game.tdir)), Game.ty + Localworld.ystep_between(Game.tdir, Help.anticlockwise(Game.tdir)), Localworld.FLOOR);
										Game.playbreakwall();
									}else if (Game.temp >= 0) {
										Game.hurtplayer();
										Game.checkifplayerdead();
									}
								}
								
								Game.temp = Game.checkforplayerorwall(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir));
								if (Game.temp == -2) {
									World.placetile(Game.tx + Localworld.xstep(Game.tdir), Game.ty + Localworld.ystep(Game.tdir), Localworld.FLOOR);
									Game.playbreakwall();
								}else if (Game.temp >= 0) {
									//trace("enemy has killed player? " + Std.string(Game.temp) + " with a sword.");
									Game.hurtplayer();
									Game.checkifplayerdead();
								}
							}
						}
					}
					
					if (Game.health > 0) Game.doenemyattack();
					/*
					if (Game.icecube > 0) {
						Game.icecube--;
						if (Game.icecube == 8) {
							if (Obj.getplayer() > -1) {
								Obj.entities[Obj.getplayer()].setmessage("ICECUBE WEARING OFF...", "player");
							}
						}else if (Game.icecube == 0) {
							Obj.entities[Obj.getplayer()].messagedelay = 0;
						}
					}
					*/
					
					for (i in 0 ... Obj.nentity) {
						if (Obj.entities[i].stunned > 0) Obj.entities[i].stunned--;
					}
					
					Game.updatequeue();
					
					Localworld.updatelighting();
					Localworld.swordclink();
					if (Game.enemycountdown > 0) {
						if (Game.numberofenemies() <= 1) Game.enemycountdown = 0;
						if (Game.score >= 12) {
							if (Game.numberofenemies() <= 2) Game.enemycountdown = 0;
						}
						Game.enemycountdown--;
						if (Game.enemycountdown <= 0) {
							Game.enemywaves();
						}
					}
				}
				
				for (i in 0...Obj.nentity) {
					Obj.animateentities(i);
					if (Obj.entities[i].messagedelay > 0) {
						Obj.entities[i].messagedelay--;
					}
				}
			}
		}
	}
}