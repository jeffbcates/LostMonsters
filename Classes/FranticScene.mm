//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces

#import "FranticScene.h"
#import "PlayMenu.h"


// HelloWorld implementation
@implementation FranticScene

+(id) thoughtfulScene:(bool) thoughtful {
	//we don't need to be a behavioral layer because we are doing
	//nothing but grouping the two sub-layers together
	
	//create the scene
	FranticScene *scene = [FranticScene node];
	//FranticScene *scene = [FranticScene node];
	
	//create the playboard layer
	Frantic *layer = [Frantic node];	
	[layer setThoughtful:thoughtful];
	[layer startMusic];
	
	//create the alert layer
	AlertLayer *alerts = [AlertLayer node];	
	[layer setAlertLayer:alerts];

	//create the menu layer
	PlayMenu *menu = [PlayMenu node];
	
	//save our references
	[scene setMenu:menu];
	[scene setPlayboard:layer];
	[scene setAlertLayer:alerts];
	
	// add layer as a child to scene
	[scene addChild: layer]; //playboard
	[scene addChild:alerts]; //handles alerts
	[scene addChild: menu]; //menu layer shows over the playboard
	
	//link the point tracker in the menu with the playboard
	//so the playboard can call methods on the actor i the menu
	[layer setPoints:[menu getPoints]];
	[layer setStatus:[menu getStatus]];
	
	//store references to each other
	[layer setMenu:menu];
	[menu setPlayboard:layer];
	
	// return the scene
	return scene;
}

+(id) scene {
	return [FranticScene thoughtfulScene:false];
}

//trigger a save
//this should be called when quitting the app
-(void) triggerSave {
	//trgger the save on the menu
	[menu triggerSave];
}

//trigger pause - show the 
-(void) triggerPause {
	//trigger the pause window in the play menu
	[menu triggerPause];
}

/***GETTERS AND SETTERS***/

//frantic
-(Frantic *) playboard{return playboard;}
-(void) setPlayboard:(Frantic *) newPlayboard {playboard = newPlayboard;}

//menu
-(PlayMenu *) menu{return menu;}
-(void) setMenu:(PlayMenu *) newMenu {menu = newMenu;}

//alert layer
-(AlertLayer *) alertLayer{return alertLayer;}
-(void) setAlertLayer:(AlertLayer *) newAlertLayer {alertLayer = newAlertLayer;}

-(void) cleanup {
	//force the playboard to cleanup itself now
	[playboard clean];
	
	//[super dealloc];
}

@end
