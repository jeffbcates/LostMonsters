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
//#import "GameKitHelper.h"

/***MENU IMPLEMENTATION***/

@interface TitleScreen : BehavioralLayer <BehavioralLayer> { /*, GameKitHelperProtocol> {*/
	//sprite sheet for this menus assets
	CCSpriteSheet *menuSheet;
	CCSprite *logo;
	
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
