//
//  LogoScene.mm
//  testapp
//
//	this does the fist bump punch in face action
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces

#import "LogoScene.h"
#import "PickConstants.h"
#import "FontManager.h"
#import "Settings.h"

//the scene we load
#import "TitleScreen.h"
#import "MainMenu.h"

// HelloWorld implementation
@implementation LogoScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LogoScene *layer = [LogoScene node];
	
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) punchSound {
	//cancel this method
	[self unschedule:@selector(punchSound)];
	
	//play our punch sound
	//this needs to be removed and have a scene that does the punching
	if ( [Settings getSoundEnabled]) [[SimpleAudioEngine sharedEngine] playEffect:@"punch.mp3"];	

}

-(void) stars {
	//unschedule ourselves
	[self unschedule:@selector(stars)];
	
	//kick of stars at the position of the owner
	//and they should have the correct width/height
	//based on how many blocks were zapped
	CCQuadParticleSystem *cpf = [CCQuadParticleSystem particleWithFile:@"Star.plist"];
	cpf.autoRemoveOnFinish = true;
	[self addChild:cpf];
	
}

-(void) loadMenu {
	//unschedule ourselves
	[self unschedule:@selector(loadMenu)];

	//load the main menu
	[[CCDirector sharedDirector] replaceScene:
	 //CCZoomFlipXTransition
	 //CCSplitColsTransition
	 [CCTurnOffTilesTransition transitionWithDuration:0.5f scene:
	  
	  (CCScene *)[TitleScreen scene]]];
	
	
}


//this method preloads certain assets
//of course this could be an entire seperate class
-(void) preloadAssets {
	//preload the punch sound - this also initializes the sound engine
	//this needs to be removed and have a scene that does the punching
	[[SimpleAudioEngine sharedEngine] preloadEffect:@"punch.wav"];	
	
	//this can be moved to a config object or something
	//preload our fonts
	//[[FontManager sharedManager] loadFont:@"BadaBoom BB"];
	//[[FontManager sharedManager] loadFont:@"CCZoinks"];
	
	
	//this is silly, but this is how we load fonts
	//because if we just call "loadFont" on CCZoinks it craps out
	//and i don't want to figure that out right now - this will work fine
	/*
	CCLabel *f2 = [CCLabel labelWithString:@"load font" fontName:@"CCZoinks" fontSize:24];
	CCLabel *f1 = [CCLabel labelWithString:@"load font" fontName:@"BadaBoom BB" fontSize:24];
	[f1 setPosition:CGPointMake(10, 240)];
	[f2 setPosition:CGPointMake(10, 200)];
	[self addChild:f1];
	[self addChild:f2];
	*/
	
	/*
	
	 //create the "menu" menu
	//and tell it to load the main menu when the user clicks on it
	Actor *menu = [self addTextActor:ccp(10, screenSize.height-16):@"menu":@"BadaBoom BB":24:ccc3(244,121,32)];
	[[menu mainSprite] setAnchorPoint:ccp(0,0.5)];	
	*/
	
	
}

// initialize your instance here
-(void) startScene {
	
	//create the background actor (without fist)
	//and the fist actor
	CCSprite *background = [CCSprite spriteWithFile:@"LEFTY-GAMES-BACKGROUND.png"];
	CCSprite *fist = [CCSprite spriteWithFile:@"LEFTY-GAMES-FIST.png"];
	
	//they should both be centered
	//fist.position = ccp(screenSize.width/2+14,screenSize.height/2+7);
	fist.position = ccp(screenSize.width/2-2,screenSize.height/2+2);
	background.position = ccp(screenSize.width/2,screenSize.height/2);
	
	//add both to our scene
	[self addChild:background];
	[self addChild:fist];
	
	//preload assets
	[self preloadAssets];
	
	//what's the starting scale?
	float startScale = [fist scale];
	
	//make the fist punch
	/*
	[fist runAction:[CCSequence actions:
					 [CCScaleTo actionWithDuration:0.3f scale:startScale * 0.8f],
					 [CCScaleTo actionWithDuration:0.15f scale:startScale * 10.0f],
					 [CCScaleTo actionWithDuration:0.15f scale:startScale],
					 nil
	]];
	*/
	
	//testing - how to create ccsequence without variadic "actions" function
	CCScaleTo *s1 = [CCScaleTo actionWithDuration:0.3f scale:startScale * 0.8f];
	CCScaleTo *s2 = [CCScaleTo actionWithDuration:0.15f scale:startScale * 10.0f];
	CCScaleTo *s3 = [CCScaleTo actionWithDuration:0.15f scale:startScale];
	CCSequence *s = [CCSequence actionOne: [CCSequence actionOne:s1 two:s2] two: s3];
	[fist runAction:s];

	

	//schedule punch sound after it gets full screen
	[self schedule:@selector(punchSound) interval:0.45f];
	
	//schedule punch sound after it gets full screen
	//[self schedule:@selector(stars) interval:0.6f];

	//schedule menu scene to load shortly after this thing is done
	[self schedule:@selector(loadMenu) interval:2.0f];
}

@end
