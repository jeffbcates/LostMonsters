//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces
#import "ScoreMenuScene.h"
#import "ScoresScene.h"
#import "MainMenu.h"
#import "config.h"
#import "Settings.h"
#import "Score.h"

// HelloWorld implementation
@implementation ScoresScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ScoresScene *layer = [ScoresScene node];
	
	//background clouds are on a seperate layer
	//so they don't move while the menu moves
	//AboutBackground *back = [AboutBackground node];
	
	
	// add layer as a child to scene
	//[scene addChild: back];
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//can be overridden - get the score type to display
-(NSString *) scoreType {
	//default - frantic
	return @"franticScores";
}

//can be overridden - get the score type to display
-(NSString *) title {
	//default - frantic
	return @"Scores";
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
	[background setPosition:ccp(screenSize.width/2,screenSize.height/2)];
	[self addChild:background];	
	//[background setScale:2.1];
	//[self setContentSize:CGSizeMake(320+32, 480+48)];
	
	
	//make the whole scene have waves - just for fun
	[self runAction:[CCRepeatForever actionWithAction:[CCLiquid actionWithWaves:3 amplitude:2.25 grid:ccg(2, 2) duration:5.0f]]];
	
	//main menu wiggles
	//[[super addTextActor:ccp(screenSize.width/2,screenSize.height-80+20) :[self title] :@"CCZoinks":48:LM_ORANGE] addBehavior:[ShadowText alloc]];
	[[super addTextActor:ccp(screenSize.width/2,screenSize.height-100+20) :@"High Scores" :@"CCZoinks":48:LM_ORANGE] addBehavior:[ShadowText alloc]];
	
	//get scores and score times from settings
	NSMutableArray *scores = [Settings getArray:[self scoreType]];
	
	//run through all scores
	//each score is of type "Score" and contains a date and a numeric value
	for (uint c = 0; c < [scores count]; c++ ) {
		//get this score
		Score *score = [Score fromString:[scores objectAtIndex:c]];
		NSString *description = [score formatted];
		
		//for fun - alternate colors and sizes
		int size = (c % 2 == 0 ) ? 32 : 24;
		ccColor3B color = ( c % 2 == 0 ) ? LM_BLUE : LM_GREEN;
		
		//add a menu actor for this score
		[self menuActor:description :ccp(screenSize.width/2,300-c*30):0.4f+c*.1:size:color];
	}
	
	//the back option
	//[[self menuActor:@"Back" :ccp(screenSize.width/2,60):1.0f:32:LM_ORANGE] addBehavior:[[[TouchLoadScene alloc] withScene:[ScoreMenuScene class]] withRandomTransition]];

	//when the entire layer gets touched we go back
	//[super addBehavior:[[[TouchLoadScene alloc] withScene:[ScoreMenuScene class]] withRandomTransition]];
	
}

//actors do not respond to touch in this scene
-(bool) enableActorTouch {
	return false;
}

//when the user touches, lets go back to main
-(void) onTouchEnded:(CGPoint)location {
	//return to the main
	//optionally... after a delay
	//TEMP: for now just go back to main menu 
	[[CCDirector sharedDirector] replaceScene:
	 [CCSplitRowsTransition transitionWithDuration:0.5f scene:(CCScene *)[ScoreMenuScene scene]]];
	
}

@end
