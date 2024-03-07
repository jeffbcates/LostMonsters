//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces
#import "OptionScene.h"
#import "Settings.h"
#import "config.h"

// HelloWorld implementation
@implementation OptionScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	OptionScene *layer = [OptionScene node];
	
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//show open feint settings
-(void) showOF {
	[LGSocialGamer showOpenFeint];
}

//add an actor with a size
//add a scene actor that flys in from left
-(Actor *) menuActor:(NSString *) title:(CGPoint) location:(float) startDelay:(int) textSize:(ccColor3B) textColor:(CGPoint) anchor {
	//create the actor with a position off screen to left
	Actor * newMenu = [super addTextActor:ccp(-50,240) :title :@"CCZoinks":textSize:textColor];
	
	//anchor on left
	[[newMenu mainSprite] setAnchorPoint:anchor];
	
	//make it exactly off screen by its width
	[newMenu mainSprite].position = ccp(0-[newMenu mainSprite].contentSize.width,240);	
	
	//start an action to slide in right away
	[[newMenu mainSprite] runAction: [CCSequence actions:
									  [CCDelayTime actionWithDuration:startDelay],	 
									  [CCMoveTo actionWithDuration:0.1f position:location],
									  nil
									  ]];
	
	//return that actor
	return newMenu;
}
	

//add an actor without a size
-(Actor *) menuActor:(NSString *)title :(CGPoint)location :(float)startDelay {
	//just pick a size
	return [self menuActor:title:location:startDelay:36:LM_BLUE:CGPointMake(0.5, 0.5)];
};

//update sound
-(void) toggleSound:(Actor *) soundMenu {
	//play a sound so they can hear the change
	//if they turned on the sound
	if ( [Settings getSoundEnabled] ) {
		[[SimpleAudioEngine sharedEngine] playEffect:@"points.wav"];
	}
	
	//sync user settings
	[Settings sync];
}

//give the user some feedback when they change the music setting
-(void) toggleMusic:(Actor *) soundMenu {
	//if we are no longer playing background music
	//make sure we stop it right now
	if (! [Settings getMusicEnabled] )  {
		//if its playing now make sure it stop it
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	} else {
		//start playing the menu music
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu-song-128.mp3"];
	}
	
	//sync user settings
	[Settings sync];
}

//update auto tweeting
-(void) toggleAutoTweet:(Actor *) soundMenu {
	//disable or enable the sound engine 
	//[[SimpleAudioEngine sharedEngine] setEnabled:[Settings getSoundEnabled]];
	
	//play a sound so they can hear the change
	//[[SimpleAudioEngine sharedEngine] playEffect:@"points.wav"];
	
	//sync user settings
	[Settings sync];
}

//this is the "receive social bonus" method
-(void) receiveSocialBonus {
	//play a sound to the user know
	if ( [Settings getSoundEnabled] ) [[SimpleAudioEngine sharedEngine] playEffect:@"points.mp3"];
	
	//since we are not currently playing, just add to bonus setting
	[Settings incrementBonus];
}

// initialize your instance here
-(void) startScene {
	//we are now the social delegate
	[LGSocialGamer setSocialDelegate:self];
	
	//load the block sheet for all sprites in this menu layer
	menuSheet = [self spriteSheetWithFrame:@"main-menu.png":@"main-menu.plist"];
	[self addChild:menuSheet];
	
	//load the background image
	CCSprite *background = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Main-Background.png"]];
	background.position = ccp(screenSize.width/2,screenSize.height/2);	
	[self addChild:background];	
	
	//main menu wiggles
	Actor *title = [super addTextActor:ccp(screenSize.width/2,screenSize.height-80) :@"OPTIONS" :@"CCZoinks":72:LM_ORANGE];
	[title addBehavior:[ShadowText alloc]];
	
	//make the whole scene have waves - just for fun
	[self runAction:[CCRepeatForever actionWithAction:[CCLiquid actionWithWaves:3 amplitude:2.25 grid:ccg(2, 2) duration:5.0f]]];

	//x position of all options should line up with left of the title
	float leftPos = [[title mainSprite] position].x - [[title mainSprite] contentSize].width/2;
	
	
	//create other menus
	[self menuActor:@"sounds" :ccp(leftPos,300):0.5f:36:LM_BLUE:CGPointMake(0, 0.5)];


	//the "on" item	
	NSString *soundOn = ([Settings getSoundEnabled] ) ? @"on" : @"off";
	[[self menuActor:soundOn :ccp(leftPos+200,300):0.55f:36:LM_GREEN:CGPointMake(0.5, 0.5)] addBehavior:
		[[[ToggleSetting alloc] 
			withSetting:@"soundEnabled":[Settings getSoundEnabled]] //this updates in user defaults for us
			withSelector:self:@selector(toggleSound:)] //call our method to actually change sound settings
	];	
	
	
	//should we play music?
	[self menuActor:@"music" :ccp(leftPos,220):0.6f:36:LM_BLUE:CGPointMake(0, 0.5)];
	
	//the "on" item	
	NSString *musicOn = ([Settings getMusicEnabled] ) ? @"on" : @"off";
	[[self menuActor:musicOn :ccp(leftPos+200,220):0.65f:36:LM_GREEN:CGPointMake(0.5, 0.5)] addBehavior:
	 [[[ToggleSetting alloc] 
	   withSetting:@"musicEnabled":[Settings getMusicEnabled]] //this updates in user defaults for us
	  withSelector:self:@selector(toggleMusic:)] //call our method to actually change sound settings
	 ];	
	
	//configure OpenFeint settings
	[[self menuActor:@"OpenFeint":ccp(screenSize.width/2,140):0.7:36:LM_BLUE:CGPointMake(0.5,0.5)] addBehavior:[NamedBehavior MenuClick:@selector(showOF)]];
		
	//[[super addTextActor:ccp(screenSize.width/2,160) :@"OpenFeint" :@"CCZoinks":36:LM_BLUE] addBehavior:[NamedBehavior MenuClick:@selector(showOF)]];
	

	//the back button takes us back
	[[self menuActor:@"back" :ccp(screenSize.width/2,60):0.8f:36:LM_ORANGE:CGPointMake(0.5, 0.5)] addBehavior:[[TouchLoadScene alloc] withScene:[MainMenu class]]];
	
	//when the entire layer gets touched we go back
	//[super addBehavior:[[TouchLoadScene alloc] withScene:[MainMenu class]]];
	
}

//actors do not respond to touch in this scene
-(bool) enableActorTouch {
	return true;
}

@end
