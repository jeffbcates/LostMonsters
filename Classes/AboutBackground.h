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
#import "MainMenu.h"

/***MENU IMPLEMENTATION***/

@interface AboutBackground : BehavioralLayer <BehavioralLayer> {
	//our menu sprite sheet
	CCSpriteSheet *menuSheet;
}

@end

