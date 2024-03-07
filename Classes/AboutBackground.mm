//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces
#import "AboutBackground.h"

// HelloWorld implementation
@implementation AboutBackground

// initialize your instance here
-(void) startScene {
	//load the block sheet for all sprites in this menu layer
	menuSheet = [self spriteSheetWithFrame:@"main-menu.png":@"main-menu.plist"];
	[self addChild:menuSheet];
	
	//load the background image
	CCSprite *background = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Main-Background.png"]];
	background.position = ccp(screenSize.width/2,screenSize.height/2);	
	[self addChild:background];	
	
	//when the entire layer gets touched we go back
	//[super addBehavior:[[TouchLoadScene alloc] withScene:[MainMenu class]]];
	
}

//actors do not respond to touch in this scene
-(bool) enableActorTouch {
	return false;
}

@end

