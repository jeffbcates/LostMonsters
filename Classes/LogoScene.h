//
//  LogoScene.h
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
//scene stuff and everything else
#import "BehavioralLayer.h"


/***MENU IMPLEMENTATION***/

@interface LogoScene : BehavioralLayer <BehavioralLayer> {
	//scene level actors
	CCSpriteSheet *blockSheet;
	
	
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@end
