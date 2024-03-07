//
//  HelloWorldScene.h
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc. All rights reserved.
//
//	this is updated - right now


// When you import this file, you import all the cocos2d classes
//scene stuff and everything else
#import "BehavioralLayer.h"


/***OUR SCENES***/
#import "Frantic.h"
#import "PlayMenu.h"
#import "AlertLayer.h"

/***MENU IMPLEMENTATION***/

@interface FranticScene : CCLayer {
	AlertLayer *alertLayer;
	Frantic *playboard;
	PlayMenu *menu;
}

//our layers
@property (nonatomic, assign) Frantic *playboard;
@property (nonatomic, assign) PlayMenu *menu;
@property (nonatomic, assign) AlertLayer *alertLayer;

//trigger the paused menu and save (for quitting the app)
//this is called when the user returns from exiting the app and is in the middle of a level
-(void) triggerPause;
-(void) triggerSave;


//return the sceen
+(id) scene;

//return the sceen with thoughtful option set
+(id) thoughtfulScene:(bool) thoughtful;

@end
