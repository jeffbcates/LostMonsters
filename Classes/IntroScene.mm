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

#import "IntroScene.h"
#import "Window.h"
#import "FranticScene.h"
#import "Settings.h"

// HelloWorld implementation
@implementation IntroScene

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroScene *layer = [IntroScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

+(id) thoughtfulScene:(bool) thoughtful {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroScene *layer = [IntroScene node];
	[layer setThoughtful:thoughtful];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
	
}


-(void) introSkipped {
	//reset the count for how many times in a row the movie was watched
	[Settings setInt:@"movies" :0];
	[Settings sync];
	
	//quit if already called
	//and don't call again
	if ( _introDone) return;
	_introDone = true;
	
	//if this is the first run
	//now we will allow skipping they saw it at least once
	//NOTE: now we always allow skipping the intro
	/*
	if ( !_allowSkip) {
		[Settings setBool:@"introSkippable" :true];
		[Settings sync];
	}
	*/
	
	//when the window closes we redirect to the frantic scene
	//load the main menu
	[[CCDirector sharedDirector] replaceScene:
	 //CCZoomFlipXTransition
	 //CCSplitColsTransition
	 [CCRadialCWTransition transitionWithDuration:0.5f scene:
	  
	  (CCScene *)[FranticScene thoughtfulScene:_thoughtfulScene]]];
	
}

-(void) introDone {
	//the movie was watched one more time
	[Settings setInt:@"movies" :[Settings getInt:@"movies" :0]+1];
	[Settings sync];
	
	//quit if already called
	//and don't call again
	if ( _introDone) return;
	_introDone = true;
	
	//if this is the first run
	//now we will allow skipping they saw it at least once
	if ( !_allowSkip) {
		[Settings setBool:@"introSkippable" :true];
		[Settings sync];
	}
	
	//when the window closes we redirect to the frantic scene
	//load the main menu
	[[CCDirector sharedDirector] replaceScene:
	 //CCZoomFlipXTransition
	 //CCSplitColsTransition
	 [CCRadialCWTransition transitionWithDuration:0.5f scene:
	  
	  (CCScene *)[FranticScene thoughtfulScene:_thoughtfulScene]]];
}

//set thoughtful scene value
-(void) setThoughtful:(bool) thoughtful {
	_thoughtfulScene = thoughtful;
}

// initialize your instance here
-(void) startScene {
	//play the intro sound / music if appropriate
	if ( [Settings getSoundEnabled] ) [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"intro-128.mp3" loop:false];
	
	//load the block sheet for all sprites in this menu layer
	introSheet = [self spriteSheetWithFrame:@"story.png":@"story.plist"];
	[self addChild:introSheet z:2];
	
	//if this is the first run
	//now we will allow skipping they saw it at least once
	//_allowSkip = [Settings getBool:@"introSkippable" :false];
	
	//QUICKFIX: just always allow skipping the intro now
	_allowSkip = true;
	
	//load the intro window
	//get the # of uynlocked monsters
	//create the window for all monsters
	//this is not actually a window, but we can use functionality in this way
	introMovie = [[Window alloc] init:self];
	[self addActor:introMovie];
	[introMovie fromFile:@"intro-movie.plist":introSheet];
}

//for the movie - actors don't accept touch we handle it
-(bool) enableActorTouch {
	return false;
}

//end the movie early ... when the screen is touched
-(void) onTouchEnded:(CGPoint) position {	
	//quit if we don't allow skipping
	if ( !_allowSkip ) return;
	
	//trigger a fade on all actors in the scene
	for (uint c = 0; c < [actors count]; c++ ) {
		//get the sprite
		CCSprite *s = [(Actor *)[actors objectAtIndex:c] mainSprite];
		
		//if this actor has a sprite - trigger a fade
		if ( s != nil ) {
			//cancel all actions on the actor
			//so we can fade it out
			[s stopAllActions];
			
			//fade the thing
			if ( [s opacity] >= 128 ) {
				//only fade out if we are not dim to begin
				//this is because if our opacity is ZERO and we call fade out
				//the opacity will become 100% then we will fade out from there
				//we don't want that
				[s runAction:[CCFadeOut actionWithDuration:1.0f]];
			} else {
				//unfortunately fade out doesn't do what we would think
				
				[s setVisible:false];
			}
		}
		
	}
	
	
	//end prematurely if the user touches the sceen
	//note: we start slightly before everything is blank
	[self performSelector:@selector(introSkipped) withObject:nil afterDelay:1.0f];
}

@end
