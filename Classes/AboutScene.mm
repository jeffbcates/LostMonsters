//
//  About Scene
//  Lost Monsters
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces
#import "AboutScene.h"
#import "config.h"
#import "Settings.h"
#import "ScoresScene.h"
#import "LGSocialGamer.h"

// HelloWorld implementation
@implementation AboutScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	AboutScene *layer = [AboutScene node];
	
	//background clouds are on a seperate layer
	//so they don't move while the menu moves
	//AboutBackground *back = [AboutBackground node];
	
	
	// add layer as a child to scene
	//[scene addChild: back];
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//create a menu actor with the given sprite
-(Actor *) menuActor:(CCSprite *) actorSprite:(CGPoint) location:(float) startDelay {
	//create the actor with a position off screen to left	
	Actor * newMenu = [[Actor alloc] init:self];
	[newMenu setMainSprite:actorSprite];
	[self addChild:actorSprite];
	[self addActor:newMenu];
	
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

//facebook click
-(void) faceClick {
	[LGSocialGamer showFaceBook];
	/*http://www.facebook.com/leftygames*/
	[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString: @"http://www.facebook.com/leftygames"]];
}

//twitter click
-(void) twitterClick {
	[LGSocialGamer showTwitter];
	/*<a href="http://www.twitter.com/leftygames"><img src="http://twitter-badges.s3.amazonaws.com/t_logo-a.png" alt="Follow leftygames on Twitter"/></a>*/
	[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString: @"http://www.twitter.com/leftygames"]];

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
	[[super addTextActor:ccp(screenSize.width/2,screenSize.height-80) :@"ABOUT" :@"CCZoinks":72:LM_ORANGE] addBehavior:[ShadowText alloc]];
	
	//create other menus
	//[self menuActor:@"DESIGN" :ccp(screenSize.width/2,300):0.4f:LM_BLUE];
	//[self menuActor:@"Jeff Cates, Nick Lay" :ccp(screenSize.width/2,270):0.5f:24:LM_GREEN];
	[self menuActor:@"CODE" :ccp(screenSize.width/2,260+70):0.6f:LM_BLUE];
	[self menuActor:@"Jeff Cates" :ccp(screenSize.width/2,230+70):0.7f:24:LM_GREEN];
	[self menuActor:@"ART" :ccp(screenSize.width/2,180+70):0.8f:LM_BLUE];
	[self menuActor:@"Nick Lay" :ccp(screenSize.width/2,150+70):0.9f:24:LM_GREEN];
	[self menuActor:@"SPECIAL THANKS" :ccp(screenSize.width/2,100+70):1.0f:LM_BLUE];
	[self menuActor:@"Julia and Liby Cates" :ccp(screenSize.width/2,70+70):1.1f:24:LM_GREEN];
	
	//the "follow us" text
	[self menuActor:@"follow us:" :ccp(screenSize.width*0.25,90):1.1f:24:LM_GREEN];
	
	//setup the twitter button
	CCSprite *twitSprite = [CCSprite spriteWithFile:@"twitter.png"];
	Actor * twitActor = [self menuActor:twitSprite :ccp(screenSize.width*0.75f+30,90):1.2f];
	[twitActor 	addBehavior:[(TouchSelector *)[[TouchSelector alloc] withTouch] withSelector:self :@selector(twitterClick)]];

	//setup the facebook button
	CCSprite *faceSprite = [CCSprite spriteWithFile:@"facebook.png"];
	Actor * faceActor = [self menuActor:faceSprite :ccp(screenSize.width*0.75f-50,90):1.2f];
	[faceActor 	addBehavior:[(TouchSelector *)[[TouchSelector alloc] withTouch] withSelector:self :@selector(faceClick)]];

	
	//the back button takes us back
	[[self menuActor:@"back" :ccp(screenSize.width/2,30):1.3f:36:LM_ORANGE] addBehavior:[[TouchLoadScene alloc] withScene:[MainMenu class]]];
	
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
