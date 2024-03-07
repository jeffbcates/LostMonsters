//
//  Leaderboard Scene
//  Lost Monsters
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces
#import "Settings.h"
#import "OpenFeint/OpenFeint.h"
#import "LeaderboardsScene.h"
#import "ScoreMenuScene.h"
#import "achievements.h"
#import "config.h"

// HelloWorld implementation
@implementation LeaderboardsScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	LeaderboardsScene *layer = [LeaderboardsScene node];
	
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

//show a specific leaderboard
-(void) showHighScores {[LGSocialGamer showLeaderboard:LEADERBOARD_HIGHSCORE];}
-(void) showSingleLevelScores {[LGSocialGamer showLeaderboard:LEADERBOARD_SINGLELEVEL];}
-(void) showMultipliers {[LGSocialGamer showLeaderboard:LEADERBOARD_MULTIPLIER];}
-(void) showCombos {[LGSocialGamer showLeaderboard:LEADERBOARD_COMBO];}

//this is the "receive social bonus" method
-(void) receiveSocialBonus {
	//play a sound to the user know
	if ( [Settings getSoundEnabled] ) [[SimpleAudioEngine sharedEngine] playEffect:@"points.mp3"];
	
	//since we are not currently playing, just add to bonus setting
	[Settings incrementBonus];
}

// initialize your instance here
-(void) startScene {
	//we are now the social delegate:
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
	[[super addTextActor:ccp(screenSize.width/2,screenSize.height-80) :@"Leaderboards" :@"CCZoinks":50:LM_ORANGE] addBehavior:[ShadowText alloc]];
	
	//high scores
	//single level scores
	[[self menuActor:@"High Scores" :ccp(screenSize.width/2,300):0.6f:LM_BLUE] addBehavior:[NamedBehavior MenuClick:@selector(showHighScores)]];
	
	//single level scores
	//[[self menuActor:@"Single Level Scores" :ccp(screenSize.width/2,250):0.7f:LM_GREEN] addBehavior:[NamedBehavior MenuClick:@selector(showSingleLevelScores)]];
	
	//multipliers
	[[self menuActor:@"Super Multipliers" :ccp(screenSize.width/2,250):0.8f:LM_GREEN] addBehavior:[NamedBehavior MenuClick:@selector(showMultipliers)]];
	
	//best combo ever
	[[self menuActor:@"Best Combo Ever" :ccp(screenSize.width/2,200):0.9f:LM_BLUE] addBehavior:[NamedBehavior MenuClick:@selector(showCombos)]];

	//our back button
	[[self menuActor:@"Back" :ccp(screenSize.width/2,60):1.0f:32:LM_ORANGE] addBehavior:[[[TouchLoadScene alloc] withScene:[ScoreMenuScene class]] withRandomTransition]];
	
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
