//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces

#import "TitleScreen.h"
#import "PickConstants.h"
#import "MainMenu.h"
#import "Window.h"
#import "Settings.h"


//testing:
#import "AnimHelper.h"

// HelloWorld implementation
@implementation TitleScreen

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	TitleScreen *layer = [TitleScreen node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//load main menu
-(void) loadMenu {	
	[[CCDirector sharedDirector] replaceScene:
	 //CCZoomFlipXTransition
	 //CCSplitColsTransition
	 [CCFadeTRTransition transitionWithDuration:1.0f scene:
	  
	  (CCScene *)[MainMenu sceneNoMusic]]];	
}

//here we setup the splash screen
//then on touch we launch the main menu
-(void) startScene {
	//play the men music
	//music is already playing
	//not so stinking loud:
	[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:[[SimpleAudioEngine sharedEngine] backgroundMusicVolume]*0.25];	
	
	//only play background music if enabled
	if ( [Settings getMusicEnabled] ) [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu-song-128.mp3" loop:false];

	
	//play the menu music
	//[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu-song-128.mp3" loop:false];
	
	const int ofx = 1;
	const int ofy = 1;
	
	
	//load the block sheet for all sprites in this menu layer
	menuSheet = [self spriteSheetWithFrame:@"title.png":@"title.plist"];
	[self addChild:menuSheet];
	
	//add the background sprite
	CCSprite *background = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"title-background.png"]];
	background.position = ccp(screenSize.width/2,screenSize.height/2);	
	[menuSheet addChild:background];
	
	//add the touch screen
	CCSprite *touchScreen = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"touch-screen.png"]];
	touchScreen.position = ccp(screenSize.width/2,180);	
	[menuSheet addChild:touchScreen];
	
	//there is now a text component to the logo "lost" without the O (window)
	CCSprite *lostText = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Logo-Text.png"]];
	[lostText setPosition:ccp(screenSize.width/2+11+ofx,340+10+ofy)];	
	[menuSheet addChild:lostText];
	

	//there are 25 frames of animation for the logo
	//load them here and start the animation
	//at the end of animation we should fade the "touch here" in
	CCAnimation *logoAnim = [CCAnimation animationWithName:@"logo"];
	[logoAnim setDelay:0.04f];	

	for (int c = 1; c <= 25; c++ ) {
		//add this frame to the animation
		[logoAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Birdseye-Intro-%i.png",c]]];
	}
	
	//there are a few more frames for the boarded window falling down
	//this will be replaced with an action to save space
	
	/*
	 CCAnimation *logoBoardedAnim = [CCAnimation animationWithName:@"logoBoarded"];
	 [logoBoardedAnim setDelay:0.04f];	
	//normal:
	for (int c = 1; c <= 6; c++ ) {
		//add this frame to the animation
		//[logoBoardedAnim addFrameWithFilename:[NSString stringWithFormat:@"Door-Animation-%i.png",c]];
		[logoBoardedAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Door-Animation-%i.png",c]]];
	}
	*/
	
	//create the logo sprite
	logo = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Birdseye-Intro-1.png"]];
	[logo setPosition:ccp(screenSize.width/2-11+ofx,340+45+ofy)];
	[menuSheet addChild:logo];
	
	//create the boarded window which will fall onto birds eye
	//but its hidden for now
	CCSprite *boardedWindow = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"boarded-window.png"]];
	[boardedWindow setPosition:ccp(screenSize.width/2-15+ofx-1,340+37+ofy-1)];
	[menuSheet addChild:boardedWindow];
	[boardedWindow setScale:5.0f];
	[boardedWindow setVisible:false];
	
	//run an action so the boarded window appears when birds eyes animation stops
	//and it scales down, so it looks like it falls on him
	[boardedWindow runAction:
	[CCSequence actions:
		[CCDelayTime actionWithDuration:0.04*25], //delay while birds eye animation gos along
		[CCShow action], //instantly show the boarded window
		[CCScaleTo actionWithDuration:0.25 scale:0.8],
		[CCScaleTo actionWithDuration:0.05 scale:1.0],
		[CCDelayTime actionWithDuration:0.25],
	 
		//show the open feint dialog
		[CCCallFunc actionWithTarget:self selector:@selector(loadMenu)],
		nil
	]
	];
	
	//run the animation on the sprite
	[logo runAction:
	[CCSequence actions:
		[CCAnimate actionWithAnimation:logoAnim restoreOriginalFrame:false],				
		[CCDelayTime actionWithDuration:0.1f],
	 
		[CCHide action], //hide birds eye while the window drops onto of him
		//[CCAnimate actionWithAnimation:logoBoardedAnim restoreOriginalFrame:false],
		//[CCDelayTime actionWithDuration:0.5f],
	 
		//show open feint here 
		//[CCCallFunc actionWithTarget:self selector:@selector(showOF)],
		nil
	]];
	
	/*
	//test for slot machine
	CCSpriteSheet *slotSheet = [self spriteSheetWithFrame:@"menu.png":@"menu.plist"];
	[self addChild:slotSheet];
	Window *slotMachine = [Window alloc];
	[slotMachine fromFile:@"slot-machine.plist" :slotSheet];
	*/
	
}

/***SCENE SETTINGS***/

-(void) onTouchBegan:(CGPoint)location {
	//cancel the logo action and load the menu now
	[logo stopAllActions];

	//just continue
	[self loadMenu];
}


@end
