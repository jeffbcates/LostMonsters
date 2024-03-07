//
//  Score Menu Scene
//  Lost Monsters
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces
#import "Settings.h"
#import "LGSocialGamer.h"
#import "OpenFeint/OpenFeint.h"
#import "ScoreMenuScene.h"
#import "config.h"
#import "FranticScores.h"
#import "ThoughtfulScores.h"
#import "LeaderboardsScene.h"

// HelloWorld implementation
@implementation ScoreMenuScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ScoreMenuScene *layer = [ScoreMenuScene node];
	
	//background clouds are on a seperate layer
	//so they don't move while the menu moves
	//AboutBackground *back = [AboutBackground node];
	
	
	// add layer as a child to scene
	//[scene addChild: back];
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//add an actor with a size
//add a scene actor that flys in from left
-(Actor *) menuActor:(NSString *) title:(CGPoint) location:(float) startDelay:(int) textSize:(ccColor3B) menuColor {
	//create the actor with a position off screen to left
	
	Actor * newMenu = [super addTextActor:ccp(-50,240) :title :@"CCZoinks":textSize:menuColor];
	
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
-(Actor *) menuActor:(NSString *)title :(CGPoint)location :(float)startDelay:(ccColor3B) menuColor {
	//just pick a size
	return [self menuActor:title:location:startDelay:36:menuColor];
};

//show the leaderboards
-(void) showLeaderboards {
	[LGSocialGamer showLeaderboards];
}

-(void) showAchievements {
	[LGSocialGamer showAchievements];
}
-(void) showFindFriends {
	[LGSocialGamer findFriends];
}


//showt he achievements 

//let the user invite their friends
-(void) showInvite {
	//this is very useful in promoting our game
	
	[LGSocialGamer inviteFriends];
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
	//we are the social delegate
	[LGSocialGamer setSocialDelegate:self];
	
	//load the block sheet for all sprites in this menu layer
	menuSheet = [self spriteSheetWithFrame:@"main-menu.png":@"main-menu.plist"];
	[self addChild:menuSheet];
	
	//load the background image
	CCSprite *background = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Main-Background.png"]];
	[background setPosition:ccp(screenSize.width/2,screenSize.height/2)];
	[self addChild:background];	
	//[background setScale:2.1];
	//[self setContentSize:CGSizeMake(320+32, 480+48)];
	
	
	//make the whole scene have waves - just for fun
	[self runAction:[CCRepeatForever actionWithAction:[CCLiquid actionWithWaves:3 amplitude:2.25 grid:ccg(2, 2) duration:5.0f]]];
	
	//main menu text
	[[super addTextActor:ccp(screenSize.width/2,screenSize.height-80) :@"Social" :@"CCZoinks":72:LM_ORANGE] addBehavior:[ShadowText alloc]];
	
	//this is our offline scores menu
	[[self menuActor:@"Local Scores" :ccp(screenSize.width/2,300):0.6f:LM_BLUE] addBehavior:[[[TouchLoadScene alloc] withScene:[FranticScores class]] withRandomTransition]];
	
	//leaderboards list
	[[self menuActor:@"Global Leaderboards" :ccp(screenSize.width/2,250):0.7f:LM_GREEN] addBehavior:[[[TouchLoadScene alloc] withScene:[LeaderboardsScene class]] withRandomTransition]];
	//[[self menuActor:@"Leaderboards" :ccp(screenSize.width/2,250):0.45f:LM_BLUE] addBehavior:[NamedBehavior MenuClick:@selector(showLeaderboards)]];
	
	//achievements list
	[[self menuActor:@"Achievements" :ccp(screenSize.width/2,200):0.8f:LM_BLUE] addBehavior:[NamedBehavior MenuClick:@selector(showAchievements)]];
	
	//find friends
	[[self menuActor:@"Find Friends" :ccp(screenSize.width/2,150):0.9f:LM_GREEN] addBehavior:[NamedBehavior MenuClick:@selector(showFindFriends)]];

	//Invite Friends To Play
	[[self menuActor:@"Invite Friends" :ccp(screenSize.width/2,100):1.00f:LM_BLUE] withBehaviors:
	 //standard functionality
	 [NamedBehavior MenuClick:@selector(showInvite)],
	 nil
	 ];
	
	
	//our back button
	[[self menuActor:@"Back" :ccp(screenSize.width/2,30):1.1f:32:LM_ORANGE] addBehavior:[[[TouchLoadScene alloc] withScene:[MainMenu class]] withRandomTransition]];
	
	//when the entire layer gets touched we go back
	//[super addBehavior:[[[TouchLoadScene alloc] withScene:[MainMenu class]] withRandomTransition]];
	
}

//actors do not respond to touch in this scene
-(bool) enableActorTouch {
	return true;
}

//when the user touches, lets go back to main
-(void) onTouchEnded:(CGPoint)location {
	//return to the main
}

@end
