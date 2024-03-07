//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//

//social integration
#import "achievements.h"


// Import the interfaces
#import "Frantic.h"
#import "FranticScene.h"
#import "MainMenu.h"
#import "PickConstants.h" //constants specific to the pick version of the game
#import "Levels.h"
#import "config.h"
#import "Settings.h"
#import "CountManager.h"

//define the different highlight 
#define BRICK_NORMAL ccc3(160,160,160)
#define BRICK_HIGHLIGHT ccc3(230,230,230)
#define BRICK_COLLECT ccc3(255,255,255)

//quick define to compare two CGRect values for equality
#define rectsMatch(a,b) (a.origin.x == b.origin.x && a.origin.y == b.origin.y && a.size.width == b.size.width && a.size.height == b.size.height)

//this defines how random the starting point of the board timer is
#define BLOCKTIMER_RANDOMSTART 5

//tags for various sprites on each block
#define WINDOW_SPRITE_TAG 2
#define MONSTER_SPRITE_TAG 1

//simple calculation for pan
#define CALCULATE_PAN(x) ((x-160.0f)/160.0f)

//there are a certain # of practice levels
#define PRACTICE_LEVELS 5

//the delay int he beginning of a level before you are allowed
//to cancel the little help finger ( so user doesn't accidently cancel)
#define FINGER_CANCEL_DELAY 0.2f

//macro to offset a CGPoint by a certain amount
#define CGOffsetPoint(p,hor,ver) CGPointMake(p.x+hor, p.y+ver)

//the quick fire delay is how long you have to make another
//connection before the quick fire thing expires
#define QUICK_FIRE_DELAY 1.5f

//how often do new monsters get introduced?
#define LEVELS_PER_TYPE 5

//how many custom starting levels are there where we don't apply levels per type but
//instead rapidly introduce monsters as part of the learning
//(i.e. first 4 monsters in first 4 levels, rest every introduced 10 levels)
//this should be at least 1
#define SKIP_LEVELS_PER_TYPE 1

//special types of blocks
#define COIN_BLOCK_TYPE -1
#define BOMB_BLOCK_TYPE -2

//tags defined for behaviors
#define BOARD_TIMER_BEHAVIOR 1
#define BOARDTIMER_STEP 0.25f
#define MAX_BOARDSTEP 40
#define MIN_BOARDSTEP 20

#define BOARD_TIMER_DIVISOR 2

/*
 CALCULATION FOR BOARD TIMER LOGIC:
( MAX_BOARDSTEP - level / 5 ) * (1 / BOARDTIMER_STEP)
( 30 - 25 / 2 ) * ( 1 / 0.25 ) = (30 - 12.5 ) * ( 4 ) = 70 (17.5 seconds)

 
*/

//this defines how long it takes for a window to get boarded on the slowest level
#define BLOCKS_PER_LEVEL_PER_TYPE 4
#define RAINBOW_BLOCK_TYPE 8

//lives / etc
#define START_GAME_LIVES 3

//these define the min max and redux of lock state per level
#define MIN_LOCK_DELAY 5.0
#define MAX_LOCK_DELAY 20.0
#define LOCK_DELAY_PER_LEVL 0.5


// HelloWorld implementation
@implementation Frantic

/***PUBLIC METHODS***/


//this will play a sound associated with a location on the board
-(bool) playDirectionalSound:(NSString *) soundName: (CGPoint) location {
	//we could do different things based on the actor
	//for now just play a test sound
	if ( soundEnabled) {
		//determine the pan based on the monster location on the board
		
		//determine a slightly random pitch and gain
		//so they don't all sound exactly the same
		float fxGain = 0.25f + CCRANDOM_0_1() * 0.1f; //anywhere between 0.25 and 0.35
		float fxPitch = 1.0f + CCRANDOM_0_1() * 0.25f; // anywhere between 1.0 and 1.25
		float fxPan = CALCULATE_PAN(location.x);
		
		//do not play the sound if it is out of range
		if ( fxPan < -1 || fxPan > 1 ) {
			DLOG(@"frantic.playRandomSound(): Pan Outside Bounds?");
			return false;
		}
		
		//gain is volume - cut in half for these sounds so they aren't so damn loud		
		[[SimpleAudioEngine sharedEngine] playEffect:soundName pitch:fxPitch pan:fxPan gain:fxGain];
		return true;
		
	} else {
		return false;
	}
	
}

//this will perform an ambient effect on the given actor
-(void) randomEffect:(Actor *) actor {
	Actor* randomActor = actor;
	
	//is this a valid type actor?
	if ( [randomActor getType] <= 0 || [randomActor getType] > 12) {
		//try again in a second (will also get a random spot/etc
		[self schedule:@selector(ambientEffect) interval:0.5f];
		return;
	}
	
	//the first 7 sounds are reserved for "ambient noise"
	//the last 2 sounds are reserved for "teasing"
	//play a random ambient sound effect
	int teaseIndex = CCRANDOM_0_1() * 6 + 1;
	NSString *teaseSound = [NSString stringWithFormat:@"monster-rand-%i.mp3",teaseIndex];
	
	//trigger the tease operation on that monster
	CCAnimation *n0;
	
	if ( CCRANDOM_0_1() > 0.5) {
		//play one of the random animations
		n0 = [randAnims objectAtIndex:[randomActor getType]-1];
		
	} else {
		//play a tease animation
		n0 = [teaseAnims objectAtIndex:[randomActor getType]-1];

	}
	
	CCAnimate *a0 = [CCAnimate actionWithAnimation:n0 restoreOriginalFrame:false];
	
	//run the animation on the actor
	[[[randomActor mainSprite] getChildByTag:1] runAction:a0];
	
	
	//play the sound directionally (and slighly randomly)
	[self playDirectionalSound:teaseSound:[[randomActor mainSprite] position]];
}

//this just schedules the ambient effect
-(void) ambientEffect:(bool) scheduleOnly {
	//there should not be more than 1 ambient sound effect going at once
	//so, just push off the schedule for a few seconds and try again
	//or if there are no currently available actors
	if ( ambientPlaying > 3 || [counter onBoard] == 0 || activeBalls == 0 ) {
		//reschedule for a later check
		[self schedule:@selector(ambientEffect) interval:3.0f];
		return;
	}
	
	//if we are not just scheduling then we should play the effect
	if ( !scheduleOnly) {
		//get a random monster that is active - we are going
		//to perform the animation here as well
		int randomSpot = CCRANDOM_0_1() * activeBalls;
		CGPoint randomPoint = activeSpots[randomSpot];
		Actor *randomActor = playboard[(int)randomPoint.y][(int)randomPoint.x];
		[self randomEffect:randomActor];
	}
	
	//finally, reschedule the ambient effect
	//for a random time in the future
	//somewhere between 4 and 8 seconds
	float nextEffectTime = CCRANDOM_0_1() * 4.0f + 4.0f;
	[self schedule:@selector(ambientEffect) interval:nextEffectTime];
	
	
}

//this is the new and improved way to do ambiant sounds and animations
//basically this method is just like "spawn" where it reschedules itself
//at a random frequency
-(void) ambientEffect {
	//don't just schedule only
	[self ambientEffect:false];
}

//this method is called when an ambient effect is done executing
//this decrements the "active effects" count
-(void) unscheduleAmbientEffect:(CCSprite *) sender:(Actor *) target  {
	//there is one fewer active ambient effect

	
}

//this is a quck check method - what's the physical count on the board
-(int) checkPhysicalCount:(int) blockType {
	//our actual count
	int physicalCount = 0;
	
	//run through all blocks on the board and physically check them
	for (int r = 0; r < ROWS; r++ ) {
		for (int c = 0; c < COLS; c++ ) {
			if ( [playboard[r][c] getType] == blockType ) physicalCount++;
		}
	}
	//return that value
	return physicalCount;
	
}

//return our count of valid types (speeds things up in some loops in spinboard)
-(int) activeTypes {
	return [counter max];
}

//overridden - this gets called from spin board
-(void) syncCounts {
	//sync all types with count manager
	//now that we know the correct counts on the board
	for (int c = 1; c <= [counter max]; c++ ) {
		[counter syncWithBoard:c:blocksOnBoard[c]];
	}
	
}


//this method checks for a strange instance
//where collected blocks is greater than deployed blocks
//that shouldn't be the case
-(void) checkDeployedBlocks:(int) blockType:(int) lastCount {
	//get the values we want to check
	int collected = [counter collected:blockType];
	int deployed = [counter deployed:blockType];
	int max = [counter max:blockType];
	int physicalCount = [self checkPhysicalCount:blockType];
	
	//display all that crap	
	NSLog(@"TYPE[%i], COL(%i) + DEP(%i) =  MAX=%i, LAST=%i, P=%i",blockType,collected,deployed,max,lastCount,physicalCount);
}

//



//return prefix for thought ful or frantic mode used in savings settings
-(NSString *) modePrefix {
	return ((_thoughtful)?@"thoughtful":@"frantic");
}

//convert an int array to a string delimited by commas
-(NSString *) arrayToString:(int[]) list:(int) listSize {
	//local declarations
	NSString *results = [NSString stringWithFormat:@"%i",list[0]];
	
	//add the rest of the items
	for (int c = 1; c < listSize; c++ ) {
		//add this item to results
		results = [results stringByAppendingFormat:@",%i",list[c]];
	}
	
	//return that formatted string
	return results;		
}

//convert an int array to a string delimited by commas
-(void) arrayFromString:(int[]) list:(NSString *) stringVal {
	//local declarations
	NSArray *values = [stringVal componentsSeparatedByString:@","];
	
	//update each value in the array with value from string
	for (uint c = 0; c < [values count]; c++ ) {
		//add this item to results
		list[c] = [[values objectAtIndex:c] intValue];
	}
}

//save the current level to user settings
-(void) saveLevel {
	//don't save if the game is over
	//it has already been saved as "start over" mode
	if (gamesOver) return;
	
	//save easy stuff (numbers, etc)
	[Settings setInt:[NSString stringWithFormat:@"%@LevelNumber",[self modePrefix]]:level];
	[Settings setInt:[NSString stringWithFormat:@"%@Lives",[self modePrefix]] :lives];
	[Settings setInt:[NSString stringWithFormat:@"%@Points",[self modePrefix]] :[pointTracker getPoints]];
	[Settings setInt:[NSString stringWithFormat:@"%@LastPoints",[self modePrefix]] :[menu getLastPoints]];	
	
	//save other counts
	[Settings setInt:[NSString stringWithFormat:@"%@ActiveBalls",[self modePrefix]]:activeBalls];
	[Settings setInt:[NSString stringWithFormat:@"%@AvailCount",[self modePrefix]] :availCount];
	
	
	//save the board in its current state (at end of level its blank, if they hit menu button who knows)
	[Settings setObject:[NSString stringWithFormat:@"%@Board",[self modePrefix]]:[self readBoard]];
	
	//save various count arrays for monsters
	[Settings setObject:[NSString stringWithFormat:@"%@MaxBlocks",[self modePrefix]] :[counter maxToString]];
	[Settings setInt:[NSString stringWithFormat:@"%@MaxTypeCount",[self modePrefix]] :[counter max]];

	[Settings setObject:[NSString stringWithFormat:@"%@AvailTypes",[self modePrefix]] :[counter availToString]];
	[Settings setInt:[NSString stringWithFormat:@"%@AvailTypeCount",[self modePrefix]] :[counter avail]];

	[Settings setObject:[NSString stringWithFormat:@"%@PausedTypes",[self modePrefix]] :[counter pausedToString]];
	[Settings setInt:[NSString stringWithFormat:@"%@PausedTypeCount",[self modePrefix]] :[counter paused]];

	[Settings setObject:[NSString stringWithFormat:@"%@WaitingTypes",[self modePrefix]] :[counter waitingToString]];
	[Settings setInt:[NSString stringWithFormat:@"%@WaitingTypeCount",[self modePrefix]] :[counter waiting]];

	[Settings setObject:[NSString stringWithFormat:@"%@BlocksCollected",[self modePrefix]] :[counter collectedToString]];
	[Settings setObject:[NSString stringWithFormat:@"%@BlocksDeployed",[self modePrefix]] :[counter deployedToString]];
	
	//commit to resident memory
	[Settings sync];
}

//load us from the saved level
-(void) loadLevel {
	//get various settings, including level # and lives
	level = [Settings getInt:[NSString stringWithFormat:@"%@LevelNumber",[self modePrefix]]:1];
	
	//you can't save on level 1 - this is a quick solution
	//to knowing when we should reset everything
	if ( level > 1 ) {
		//get lives
		lives = [Settings getInt:[NSString stringWithFormat:@"%@Lives",[self modePrefix]]:3];
		
		//get the points for the level
		int savedPoints = [Settings getInt:[NSString stringWithFormat:@"%@Points",[self modePrefix]] :0];
		[pointTracker addPoints:savedPoints];
		
		//get the # of points for last level
		int lastPoints = [Settings getInt:[NSString stringWithFormat:@"%@LastPoints",[self modePrefix]] :0];
		[menu setLastPoints:lastPoints];
	}
	
}

//clear the level as game is over
-(void) clearLevel {
	//the level number is now 1 - this indicates starting over
	[Settings setInt:[NSString stringWithFormat:@"%@LevelNumber",[self modePrefix]] :1];
	
	//the # of lives is now 3
	[Settings setInt:[NSString stringWithFormat:@"%@Lives",[self modePrefix]]:3];	
	
	//commit settings
	[Settings sync];
}

//match behaviors between two actors
//this is not really automatic maybe it could be eventually
-(void) syncBehaviors:(Actor *) actor : (Actor *) clone {
	//this is simple, the main sprite contains the step as its tag
	//just copy - no matter what it will match everything else / etc
	[[clone mainSprite] setTag:[[actor mainSprite] tag]];

	//if this is a bomb make sure that it starts pulsating
	if ( [clone getType] == COIN_BLOCK_TYPE ) {
		//this should trigger
		[clone setType:[clone getType] withForce:true];
	}
	
	//make sure we match the frame of the window we are cloing
	//that way the boarded windows stay...
	CCSprite *actorWindow = (CCSprite *)[[actor mainSprite] getChildByTag:WINDOW_SPRITE_TAG];
	CCSprite *cloneWindow = (CCSprite *)[[clone mainSprite] getChildByTag:WINDOW_SPRITE_TAG];
	
	//NOTE: we should only duplicate the text rect if it is one of the 3 "tease" windows
	//otherwise don't worry about it
	if (	rectsMatch([actorWindow textureRect] , windowTeaseRect1) ||
			rectsMatch([actorWindow textureRect] , windowTeaseRect2) ||
			rectsMatch([actorWindow textureRect] , windowTeaseRect3) 
	) {
		[cloneWindow setTextureRect:[actorWindow textureRect]];	
	}
	
}


//this method creates all the teasing animations for us
-(void) createTeaseAnimations {
	
	//initialize the array
	teaseAnims = [[CCArray alloc] init];
	
	//run through all monsters
	for (uint c = 1; c <= MAX_BLOCK_TYPES; c++ ) {
		//create this animation
		CCAnimation *teaseAnim = [CCAnimation animationWithName:[NSString stringWithFormat:@"monster-%i-t",c]];
		[teaseAnim setDelay:1.0];
		//[teaseAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-1.png",c]]];
		[teaseAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-t.png",c]]];
		
		[teaseAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-1.png",c]]];	
		
		//add this animation to our animation array
		[teaseAnims addObject:teaseAnim];		
	}
	
	//testing: what is wrong with teaseAnims?
	//create this animation
	CCAnimation *teaseAnim = [CCAnimation animationWithName:[NSString stringWithFormat:@"monster-%i-t",12]];
	[teaseAnim setDelay:1.0];
	//[teaseAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-1.png",12]]];
	[teaseAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-t.png",12]]];
	[teaseAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-1.png",12]]];	
	//add this animation to our animation array
	[teaseAnims addObject:teaseAnim];		
	
	
	//that's it - now we have a single set of teaser animations for all monsters
}


//this method creates all the teasing animations for us
-(void) createRandomAnimations {
	
	//initialize the array
	randAnims = [[CCArray alloc] init];
	
	//run through all monsters
	for (uint c = 1; c <= 12; c++ ) {
		//create this animation
		CCAnimation *randAnim = [CCAnimation animationWithName:[NSString stringWithFormat:@"monster-%i-r",c]];
		[randAnim setDelay:0.15];
		
		
		//we don't know how many frames there are for this animation
		//so here we keep adding until we get a nil frame... that means that's it
		int f = 0;
		CCSpriteFrame *frame = nil;
		
		while ( f == 0 || frame != nil ) {
			//get this frame
			f++;
			frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-%i.png",c,f]];
			
			//if valid, add it to the animation
			if ( frame != nil ) [randAnim addFrame:frame];
			
		}
		//we should repeat the first frame at the end
		[randAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-1.png",c]]];	
		
		//add this animation to our animation array
		[randAnims addObject:randAnim];
	}
	
	//that's it - now we have a single set of "organic" animations for all monsters, varying # of frames
	//but we have it all worked out here
}

//this method gets called to play a random sound to accompany the random animatinos
-(void) playRandomSound:(Actor *) ownerActor:(NSNumber *) actionNumber {
	//only fire the tease sound if we are an actual type
	if ( [ownerActor getType] <= 0 ) return;
	
	//when we duplicate the monster windows and have them offscreen (for sliding)
	//they should not play a sound because you can't see them
	//so quit if x / y values are outside bounds
	CGPoint pos = [[ownerActor mainSprite] position];
	if ( pos.x < 0 || pos.x > 320 || pos.y < 0 || pos.y > 480 ) return;
	
	//get a random tease sound
	int teaseIndex = CCRANDOM_0_1() * 4 + 1;
	NSString *teaseSound = [NSString stringWithFormat:@"monster-rand-%i.mp3",teaseIndex];
	
	//we could do different things based on the actor
	//for now just play a test sound
	if ( soundEnabled) {
		//determine the pan based on the monster location on the board
		
		//determine a slightly random pitch and gain
		//so they don't all sound exactly the same
		float fxGain = 0.25f + CCRANDOM_0_1() * 0.1f; //anwyereh between 0.25 and 0.35
		float fxPitch = 1.0f + CCRANDOM_0_1() * 0.25f; // anywhere between 1.0 and 1.25
		float fxPan = CALCULATE_PAN(pos.x);
		
		//the pan should never be outside of bounds
		//if it is then don't even play
		if ( fxPan < -1 || fxPan > 1 ) {
			return;
		}
		
		//gain is volume - cut in half for these sounds so they aren't so damn loud		
		[[SimpleAudioEngine sharedEngine] playEffect:teaseSound pitch:fxPitch pan:fxPan gain:fxGain];
	}
	
	
}

//this gets called all the time - and defines what behaviors exist on a bdelock
//this function adds behaviors to the given actor and returns the actor
-(void) blockBehaviors:(Actor *) actor {
	//quick check - don't add behaviors to an actor that already has them
	if ( [[actor behaviors] count] > 0 ) return;
	
	/*
	//create the random action behavior
	//and it should be disabled to start
	RandomAction *birdRand  = [(RandomAction *)[RandomAction alloc] autorelease];
	//don't play a sound here, instead let ambient sound handle it
	//[birdRand withSelector:self:@selector(playRandomSound::)];
	[birdRand setEnabled:false];
	
	//get a placeholder teaser and organic animation for the actor
	//CCAnimation *teaseAnim = (CCAnimation *)[teaseAnims objectAtIndex:0];
	CCAnimation *randAnim = (CCAnimation *)[randAnims objectAtIndex:0];
	
	//create the animate actions for both teasers and random animations
	//CCAnimate * teaseAnimAction = [CCAnimate actionWithAnimation:teaseAnim restoreOriginalFrame:false];
	CCAnimate * randAnimAction = [CCAnimate actionWithAnimation:randAnim restoreOriginalFrame:false];
	
	//add both the random and teaser animations to the random action
	//make these very infrequent since there are so many blocks on the screen
	//we don't want too many of them firing at once
	[birdRand withAction:randAnimAction:16.0:32.0];
	//[birdRand withAction:teaseAnimAction:16.0:32.0];	

	//set the target to the specific child sprite that is the bird
	//TAG 1 is the monster
	[birdRand withTarget:(CCSprite *)[[actor mainSprite] getChildByTag:1]];
	*/
	
	//add our behaviors
	actor = [actor withBehaviors:
	 [[TrackLinked behavior] withWildCard:RAINBOW_BLOCK_TYPE], //tracks linked actors
	 //[[LinkStateChange alloc] withState:3], //this is the "bomb block" behavior
	 [[(LinkedTypes *)[[LinkedTypes alloc] withSelector:self:@selector(HandleLinkType:)] withCascade:true] withTargetState:1], //updates actor state when linked items of same type are present
	 //[LinkedWords alloc], //changes state of actors when they are linked (triggering stateful behaviors)
	 [[[AutoPoint behavior] withTracker:points] withState:1],
	 
	 
	 //this behavior handles the "organic" animations and sounds that come from monsters during the level
	 //birdRand,	 

	 [[(FloatySpawn *)[[FloatySpawn behavior] withState:1] withChildByTag:1] withSelector:self:@selector(floatyFrame:)],
	 //[[[StateParticle alloc] withState:1] withFile:@"Point.plist"],
	 //[[Animate alloc] withState:1],
	 
	 //when we are collected - that is when we reduce the # of deployed blocks
	 //that way we always have an accurate count (instead of relying on the deployed block count)
	 [(StateAction *)[[StateAction behavior] withState:1] 
		withAction:[CCCallFuncND actionWithTarget:self selector:@selector(collectBlock::) data:actor]],

	 //we should fire off a particle effect when we are collected (collection state is 1)
	 [[[StateParticle behavior] withFile:@"StarPoints.1.3G.plist"] withState:1],

	
	 //while the actor is a bomb it should pulsate
	 //but not the whole sprite - only the bomb
     /*
	 [[[[StateAction behavior] whileType:COIN_BLOCK_TYPE] withTarget:[[actor mainSprite] getChildByTag:MONSTER_SPRITE_TAG] ] withAction:
	  [CCRepeatForever actionWithAction:[NamedAction Pulsate]]
	 ],
	 */
	 
	 //timed fire behavior is what boards up windows
	 //we use this behavior instead of an action because we can
	 //sync multiple of these together (i.e. when you slide a block and the screen wraps
	 //the copy needs to match timer for boarding up the window
	 //[[[[TimedFire alloc] withSelector:self :@selector(boardTimer:) :5.0f ] whileNotType:0] whileState:0],
	 
	 
	 //this resets the board timer when the user collects a block
	 [
	  [[StateAction behavior] withType:0] withAction:
		[CCCallFuncND actionWithTarget:self selector:@selector(boardTimerReset::) data:actor]
	 ],
	 
	 //
	 
	 //this action is a countdown to returning a block back to blank state
	 //this means you only have so long to collect each block
	 [[[
	   [[StateAction behavior] withAfterType:0] withAction:
	   [CCRepeatForever actionWithAction:
		   [CCSequence actions:
			[CCDelayTime actionWithDuration:BOARDTIMER_STEP],
			[CCCallFuncND actionWithTarget:self selector:@selector(boardTimer::) data:actor],
			nil
			]
		
		]
		] whileState:0] withTag:BOARD_TIMER_BEHAVIOR],
	 nil
	 ];
	//*/
	//we are done return the actor
	//return actor;
}

//this method fires when the user collects a block
-(void) collectBlock:(id) sender:(Actor *) actor {
	//collect this block by "undeploying" it
	int actorType = [actor getType];
	[counter collectBlock:actorType];
	//NSLog(@"COLLECT[%i] - 1 = %i",actorType,[counter onBoard:actorType]);
    
}
	 
//this method returns the proper frame for our floaty spawn behavior
//for monsters that is the monster on a cloud, for collectables its just the collectable image
-(CCSpriteFrame *) floatyFrame:(Actor *) actor {
	NSString *monsterFrameName = nil;	
	if ( [actor getType] < 0 ) {
		//this is a heart or other special block
		monsterFrameName = [NSString stringWithFormat:@"collectable%i.png",[actor getType]];
	} else {
		//this is an actual monster - use its floaty image
		monsterFrameName = [NSString stringWithFormat:@"monster-%i-float.png",[actor getType]];
	}
	
	
	//return the correct frame based on the type of the actor
	return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:monsterFrameName];
}

//this method fires every 1 second while counting combos
//and once it reachs a max then all the combos are collected at once
-(void) quickFireClick {
	//increment the internal counter
	quickFireCounter++;
	DLOG(@"quickFireClick(): Start");
	//if we hit the magic #
	//note: if in thoughtful mode as soon as this gets called we are done
	//because this is fired every time in thoughtful mode
	//let's be sure to check the quick fire count before firing this
	if ( countingQuickFires && ( quickFireCounter >= QUICK_FIRE_DELAY || _thoughtful ) ) {
		//unschedule this method
		[self unschedule:@selector(quickFireClick)];
		
		//that's it - here we should collect all combos that were valid
		//we are no longer counting combos
		countingQuickFires = false;

		//if there was actually some "action"
		//with quick fires
		if ( quickFires > 1 ) { 
			//whatever the collected score
			//multiple that times the # of quickfires
			int currentScore = [pointTracker getPoints] - quickFireStartScore;
			currentScore *= (quickFires - 1 ) ;
			
			//now add those points
			[pointTracker addPoints:currentScore];
			
			//here we should let the user know how many quick fires they got
			//CGPoint pos = lastTouch; //[[linkTypeBehavior owner] mainSprite].position;
			CGPoint pos = CGPointMake(screenSize.width/2, screenSize.height/2);
			
			
			//let the user know how much of a multiplier they got
			[alertManager triggerAlert:[NSString stringWithFormat:@"%ix Multiplier",quickFires]:pos];
			
			//update best multiplier for this level in the play menu
			[menu updateBestMultiplier:quickFires];
			
			//trigger the first multiplier achievement
			[LGSocialGamer achieve:ACHIEVE_FIRSTMULTIPLIER percentComplete:100];			
			
		}
		
	}
	DLOG(@"quickFireClick(): End");
}

//this returns the # of blocks on the board given a block type
-(int) blocksOnBoard:(int) blockType {
	//alright - this is screwed up so lets actually count the blocks on the board
	//for now - not
	int onBoard = [counter onBoard:blockType];
	
	//return that value
	return onBoard;
}


//this method gets called after a delay for all blocks that get populated
//if the block is still a valid type
//NOTE: be sure to unschedule this selector once the block is collected
-(void) restoreBlankBlock:(CCSprite *) sender: (Actor *) block:(int) newState {
	//this method only gets fired when the actor is definately
	//in need of going back to blank state
	int blockType = [block getType];
	
	
	//when we restore a blank block
	//the block is "undeployed"
	[counter undeployType:blockType];
	
	//did we just make the deployed coutn less than the collectedc ount?
	if ( [counter deployed:blockType] < [counter collected:blockType] ) {
		DLOG(@"BLOCKS DEPLOYED IS NOW LESS THAN COLELCTED???");
	}
	
	//unpause the block if its paused
	//this method will check first so we don't need to
	[counter unpauseType:blockType];
	
	
	//update the actors type back to a blank block
	[block setState:newState];
	[block setType:0];
	
	//run animation to close window and board it up
	[super setSpriteColor:block:false];
}

//this method gets called after a delay for all blocks that get populated
//if the block is still a valid type
//NOTE: be sure to unschedule this selector once the block is collected
-(void) restoreBlankBlock:(CCSprite *) sender: (Actor *) block {
	//restore the block with state 2 - locked - the default
	[self restoreBlankBlock:sender:block:2];
}



//this resets the board timer when we collect a block
-(void) boardTimerReset:(CCSprite *) sender : ( Actor *) actor  {
	//get a random starting point
	int tagStart = CCRANDOM_0_1() * BLOCKTIMER_RANDOMSTART;
	
	//sprite tag tracks how many times we got called	
	[sender setTag:tagStart];
}

-(void) popTeaseSound {	
	//there is one fewer tease sound playing
	if ( teasesPlaying > 0 ) teasesPlaying--;
}

//this will push/play a tease sound but only if there are not already too many going at once
//that way the board doesn't get too crazy
-(void) pushTeaseSound:(Actor *) monster {
	//quit if too many tease sounds are playing at once
	if ( teasesPlaying > 3 ) return;
	
	//pick a random sound to play (there are only 3 of these guys)
	int randomSound = CCRANDOM_0_1() * 2 + 1;
	
	//play a sound letting the user know they are in trouble
	if ( [self playDirectionalSound:[NSString stringWithFormat:@"monster-tease-%i.mp3",randomSound]:[[monster mainSprite] position]] ) {
		//decrement tease sound in a few seconds
		[self schedule:@selector(popTeaseSound) interval:2.5f];
		teasesPlaying++;
	}
	
}

//this will push/play a tease sound but only if there are not already too many going at once
//that way the board doesn't get too crazy
-(void) pushWorkSound:(Actor *) monster {
	//quit if too many tease sounds are playing at once
	if ( teasesPlaying > 3 ) return;
	
	//pick a random sound to play (there are only 3 of these guys)
	int randomSound = CCRANDOM_0_1() * 3 + 1;
	
	//there should be a bit of a delay between playing sounds
	//even though the sound is ony 1 second long, we spread them out for 5 seconds
	//so there isn't too much
	if ( [self playDirectionalSound:[NSString stringWithFormat:@"monster-board-%i.mp3",randomSound]:[[monster mainSprite] position]] ) {
		//decrement tease sound in a few seconds
		int randInterval = CCRANDOM_0_1() * 2 * 4;
		[self schedule:@selector(popTeaseSound) interval:randInterval];
		teasesPlaying++;
	}
	
}

//this sets the monster tease frame
//note that now we are setting it on the window NOT THE MONSTER
-(void) setMonsterTeaseFrame:(Actor *) monsterActor:(int) teaseFrameIndex {
	//get the monster type (we use in both cases)
	int monsterType = [monsterActor getType];
	
	
	//for the first frame we just show the monster tongue
	if ( teaseFrameIndex == 1 ) {
		//always stick out the tongue!
		CCSprite *monster = (CCSprite *)[[monsterActor mainSprite] getChildByTag:MONSTER_SPRITE_TAG];
		//also trigger a quick tongue motion for the monster
		//this is instead of creating a full blown animation act9ion
		[monster setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-t.png",monsterType]]];
		
	} else {
		CCSprite *window = (CCSprite *)[[monsterActor mainSprite] getChildByTag:WINDOW_SPRITE_TAG];
		[window setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"window-tease-%i.png",teaseFrameIndex-1]]];
	}
	
}
		
//this restores blocks to the boarded up step where appropriate
-(void) boardTimer:(CCSprite *) sender : ( Actor *) actor  {
	//do nothing in thoughtful mode
	if ( _thoughtful ) return;
	
	//do nothing until after level 6	
	if (level <= PRACTICE_LEVELS) return;
	
	//HACK - very quick fix cuz this thing is running on blocks that have been recycled
	if ( [actor getType] == 0 || [actor getState] != 0 ) return;
	
	//sprite tag tracks how many times we got called
	int step = [sender tag];
	step++;
	[sender setTag:step];
	
	//what step do we board at?
	float boardstep = (MAX_BOARDSTEP-level/BOARD_TIMER_DIVISOR)*(1/BOARDTIMER_STEP);
	
	//don't go below the minimum amount
	if ( boardstep  < MIN_BOARDSTEP * (1/BOARDTIMER_STEP)) boardstep = MIN_BOARDSTEP * (1/BOARDTIMER_STEP);
	
	//in thoughtful mode it takes a LONG time to board
	//for now - thoughtful doesn't change board step timer
	//boardstep = (_thoughtful ) ? boardstep * 3 : boardstep;
	
	//testing: pulsate for this # of times f
	//[sender runAction:[NamedAction Pulsate:0.2f:step]];	
	int singleStep = boardstep / 4;
	
	//int delta = (boardstep-step)/2;
	
	//do not let divide by zero
	//delta = (delta == 0 ) ? 1 : delta;
	
	
	//here - we should also set the state or something
	//so that duplicates of this sprite show the correct frame and other animations
	//put this frame back

	//first animation
/*	if ( step == singleStep * 1 ) {
		//should we stick out our tongue or what
		if ( CCRANDOM_0_1() > 0.5) {
			//play a different random effect
			[self randomEffect:actor];
			
		} else {
			//update the frame of the monster
			[self setMonsterTeaseFrame:actor:1];
			
			//schedule a random tease sound
			//but this thing will prevent too many tease sounds from getting called at once
			//otherwise it sounds a bit creepy
			[self pushTeaseSound:actor];
		}
		
		
	} else*/ if ( step == singleStep * 1 ) {
		//tease 2
		//update the frame of the monster
		[self setMonsterTeaseFrame:actor:2];
		
		//schedule a random tease sound
		//but this thing will prevent too many tease sounds from getting called at once
		//otherwise it sounds a bit creepy
		[self pushWorkSound:actor];
	} else if ( step == singleStep * 2 ) {
		//tease 3		
		//update the frame of the monster
		[self setMonsterTeaseFrame:actor:3];
		
		//schedule a random tease sound
		//but this thing will prevent too many tease sounds from getting called at once
		//otherwise it sounds a bit creepy
		[self pushWorkSound:actor];
	} else if ( step == singleStep * 3 ) {
		//tease 4
		//update the frame of the monster
		[self setMonsterTeaseFrame:actor:4];
		
		//schedule a random tease sound
		//but this thing will prevent too many tease sounds from getting called at once
		//otherwise it sounds a bit creepy
		[self pushWorkSound:actor];
	} else if ( step >= boardstep ) {
		//TODO: make the board timer get harder for increasing levels
		
		//yep - let's do that and reset our step
		[self restoreBlankBlock:nil:actor];
		[sender setTag:0];
		
		//play a sound so the user knows they suck
		if ( soundEnabled) [[SimpleAudioEngine sharedEngine] playEffect:@"window-shut.mp3"];
		
		//boards are closing, don't show the finger anymore
		[self removeFinger];
	}

	/*
	//what is the remainder when dividing by the delta
	if ( step % delta == 0 ) {
		CCSprite *monster = (CCSprite *)[sender getChildByTag:1];
		//[monster runAction:[NamedAction Wiggle]];
		
		//testing: set frame instead of using an animation
		int monsterType = [actor getType];
		
		[monster setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-t.png",monsterType]]];
		
		//trigger the tease operation on that monster
		//CCAnimation *n0 = [teaseAnims objectAtIndex:[actor getType]-1];
		//CCAnimate *a0 = [CCAnimate actionWithAnimation:n0 restoreOriginalFrame:false];
		//[[[actor mainSprite] getChildByTag:1] runAction:a0];
		
		//schedule a random tease sound
		//but this thing will prevent too many tease sounds from getting called at once
		//otherwise it sounds a bit creepy
		[self pushTeaseSound:actor];
	}
	*/
	
	//are we at the step to board up the block?
	//TODO: make the timer for boards get harder as the levels progress
	//as the levels get higher the step gets lower
}

//update paused as needed
-(void) updatePaused {
	//update counter paused types
	[counter updatePausedTypes];
	
	//now if there are no paused and no available then we are done
	if ( [counter avail] + [counter paused] <= 0 ) {
		//when no more vail blocks - cancel spawning
		[super stopSpawning];
	}
	
}

//this determines if there is an available block type
//using our counter - if there isn't one we should not pop a
//block off the available block type list
-(bool) availBlockType {
	//we should only spawn a block if there are types available
	return ( [counter avail] > 0 ) ;
}

//overriden standard way to determine block type
//because we also randomly set the state to something
//if this function returns false it is because we don't want a block created
//right now (even though spawn may still be running)
-(bool) determineBlockType:(Actor *) block {
	//this updates available types and paused types
	//this will also unschedule the spawn method
	//if needed
	
	//NOTE: we update before checking if there are available
	//because this check may move blocks from paused state
	//to the available state and if all blocks are paused
	//then this will never get called if after the avail check
	//[self updatePausedTypes];
	[self updatePaused];
	

	//quit if there are no blocks to spawn
	if ( [counter avail] <= 0) {
		//make sure the block type is not set
		//and exit because we don't have any blocks we can do
		[block setType:0];
		return false;	
	}
	
	//get a random position in the available block types
	int ballType = [counter randomType];
	
	//at this point we have officially "deployed" a block
	[counter deployType:ballType];
	
	//update the block type
	[block setType:ballType];
	
	//some blocks are bomb type blocks
	//for now they are represented by pulsating
	//this is triggered when the state changes
	//we need to also check if the bomb state is allowed right now
	/*
	if ( CCRANDOM_0_1() * 25 < 1 && maxStates > 2) {
		//this is a bomb block
		[block setState:3];
		
		//fix its z-order so it looks good
		[blockSheet reorderChild:[block mainSprite] z:-1];
		
	} else {
		[block setState:0];
	}
	*/
	
	//test:
	return true;
}

//this gets the sprite texture rectangle based ont he ball TYpe
-(CGRect) getBallTextureRect:(int) ballType:(int) ballState {
	//calculate x and y position within the sprite sheet
	int idx = ballType;
	int idy = (ballState == 2) ? 1 : (ballState == 3 ) ? 3 : 0;	
	return CGRectMake(idx*COL_WIDTH,idy*ROW_HEIGHT,COL_WIDTH,ROW_HEIGHT);
}

//this gets the sprite texture rectangle based ont he ball TYpe
-(CGRect) getBallTextureRect:(Actor *) ball {
	//call with our state and type
	return [self getBallTextureRect:[ball getType]:[ball getState]];
}

//get the monster frame given an actor
-(CCSpriteFrame *) monsterFrame:(Actor *) ball {
	//special case for special blocks
	NSString *monsterFrameName = nil;
	if ( [ball getType] < 0 ) {
		//this is a heart or other special block
		monsterFrameName = [NSString stringWithFormat:@"collectable%i.png",[ball getType]];
		
	} else {
		//this is an actual monster
		monsterFrameName = [NSString stringWithFormat:@"monster-%i-1.png",[ball getType]];
	}
	return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:monsterFrameName];
}

//get the window frame given an actor
-(CCSpriteFrame *) windowFrame:(Actor *) ball:(bool) noAnim {
	//declarations
	NSString *windowFrameName = nil;
	
	//figure out the window frame name
	if ( [ball getType] == 0 ) {
		//state 2 is a boarded up window - anything else is open
		if ( [ball getState] == 2 ) {
			if (noAnim) {
				//int boardNumber = CCRANDOM_0_1() * 7 + 1;
				//windowFrameName = [NSString stringWithFormat:@"window-boarded-%i.png",boardNumber];
				windowFrameName = @"window-boarded-1.png";
			} else {
				windowFrameName = @"window-closed.png";
			}
		} else {			
			//blank block always closed window
			if ( noAnim) {
				windowFrameName = @"window-closed.png";
			} else {
				windowFrameName = @"window-open.png";
			}
		}
	} else {
		//state 2 is a boarded up window - anything else is open
		if ( [ball getState] == 2 ) {
			if (noAnim) {
				//int boardNumber = CCRANDOM_0_1() * 7 + 1;
				//windowFrameName = [NSString stringWithFormat:@"window-boarded-%i.png",boardNumber];
				windowFrameName = @"window-boarded-1.png";
			} else {
				windowFrameName = @"window-open.png";
			}
		} else {
			//all other states are open a window
			//note: we keep window closed and use an animation to open it
			if ( noAnim ) {
				windowFrameName = @"window-open.png";
			} else {
				windowFrameName = @"window-closed.png";
			}
		}
		
	}
	
	//return the frame
	return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:windowFrameName];
}

//this returns a sprite frame
-(CCSpriteFrame *) getBallFrame:(Actor *) ball {
	//build a frame name based on the attributes of the ball (state / type)
	return [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"combo-type%i-state%i.png",[ball getType],[ball getState]]];
}

//this methods calls animations for the window opening closing etc
-(void) animateActor:(Actor *)actor:(CCSprite *) window {
	//if we are now blank then we should close the window
	if ( [actor getType] == 0 && [actor getState] == 0 ) {
		//this flings the window open
		[window runAction:[CCAnimate actionWithAnimation:animWindowClosing restoreOriginalFrame:false]];
	}
	
	//if we are now blank and boarded up
	if ( [actor getType] == 0 && [actor getState] == 2 ) {
		//close window and board it up
		[window runAction:[CCAnimate actionWithAnimation:animWindowBoarding restoreOriginalFrame:false]];
	}
	
	//this is a collectable block, has an open window as well
	if ( [actor getType] < 0 && [actor getState] == 3 ) {
		//this flings the window open
		[window runAction:[CCAnimate actionWithAnimation:animWindowOpening restoreOriginalFrame:false]];
	}	
	
	//if we are not a blank block - run animation to open the window
	//do not run this animation for boarded up windows
	if ( [actor getType] > 0 && [actor getState] == 0 ) {
		//this flings the window open
		[window runAction:[CCAnimate actionWithAnimation:animWindowOpening restoreOriginalFrame:false]];
	}
	
	//if we are changing to the boarded up window there is an animation for that too
	if ( [actor getType] > 0 && [actor getState] == 2 ) {
		//board up the window
		[window runAction:[CCAnimate actionWithAnimation:animWindowBoarding restoreOriginalFrame:false]];
	}	
	
}

//update the actor sprites based on the actor
-(void) updateActorSprite:(Actor *) actor : (bool) noAnim {
	//since we changed the type - stop the current action
	//RandomAction *ra = (RandomAction *) [actor behavesAs:[RandomAction class]];
	//[ra stop];	
	
	//get main sprite reference
	//and the other two sprites off that one
	CCSprite * bricks = [actor mainSprite];
	CCSprite *monster = (CCSprite *)[bricks getChildByTag:1];
	CCSprite * window = (CCSprite *)[bricks getChildByTag:2];
	CCSpriteFrame *winFrame = [self windowFrame:actor:noAnim];
	
	//cancel any animations currently on the monster and window
	//that way they don't override what we do here
	[monster stopAllActions];
	[window stopAllActions];
	
	//if this is a collectable block, make it pulsate
	if ( [actor getType] == COIN_BLOCK_TYPE ) {
		//pulsate
		[monster runAction:[CCRepeatForever actionWithAction:[NamedAction Pulsate]]];
	}

	//all windows start with display frame
	[window setDisplayFrame:winFrame];
	
	//pick a random board timer starting position
	//so they don't all start at once
	int tagStart = CCRANDOM_0_1() * BLOCKTIMER_RANDOMSTART;
	[[actor mainSprite] setTag:tagStart];
	
	
	//animate if we are animating
	if ( !noAnim) [self animateActor:actor:window];
	
	//update monster and window frames
	[monster setDisplayFrame:[self monsterFrame:actor]];
	
	//if we are animating then we should also play a sound as part of that		
	
	if ( [actor getType] > 0 && !noAnim && soundEnabled) [[SimpleAudioEngine sharedEngine] playEffect:@"popSmall.mp3"];

	/*
	if ( ra) {
	//TEST: update the random action appropriately	
	if ( [actor getType] <= 0 ) {
		[ra setEnabled:false];
		

	} else {
		
		//enable the random action behavior
		[ra setEnabled:true];
		
		//test: get 2 actions
		CCAnimate *a0 = (CCAnimate *)[ra action:0];
		CCAnimate *a1 = (CCAnimate *)[ra action:1];
		
		//get 2 animations
		CCAnimation *n0 = [randAnims objectAtIndex:[actor getType]-1];
		CCAnimation *n1 = [teaseAnims objectAtIndex:[actor getType]-1];
		
		//we should update for both the teaser animations and the "organic" animation
		//NSLog(@"updating type=%i - %@ %@",[actor getType],[n0 name],[n1 name]);
		
		[a0 setAnimation:n0];
		[a1 setAnimation:n1];		
		//NSLog(@"now=%i - %@ %@",[actor getType],[[(CCAnimate *)a0 animation] name],[[(CCAnimate *)a1 animation] name]);
		
	}
	}
	 */
	
}

//higlihght sprite by changing the sprite frame from a dark blue
//to a light blue brick motif
-(void) highlightSprite:(Actor *) actor:(bool) highlighted {
	int brick = (highlighted) ? 2 : 1;
	
	CCSprite * brickSprite = (CCSprite *)[[actor mainSprite] getChildByTag:3];
	[brickSprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"blue-brick-%i-hole.png",brick]]];
    
    //testing: for later
    /*
    if ( highlighted ) {
        [brickSprite setColor:BRICK_HIGHLIGHT];
    } else {
        [brickSprite setColor:BRICK_NORMAL];
    }
    */

}


//create a sprite for the given actor
//this is only called once when the scene starts (per block on the grid)
-(CCSprite *) createActorSprite:(Actor *)newActor:(bool) noAnim {
	//setup the main sprite - this is the brick wall
	CCSprite *bricks = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"blue-brick-1-hole.png"]];
	CGPoint brickCenter = CGPointMake(bricks.contentSize.width/2,bricks.contentSize.height/2);
	
	//TODO: make this better (this is a quick and dirty fix)
	CCSprite *brick2 = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"blue-brick-1-hole.png"]];
    
    //by default darken all the bricks
    //[bricks setColor:BRICK_NORMAL];
    //[brick2 setColor:BRICK_NORMAL];
	
	//there is also a monster
	CCSprite *monster = [CCSprite spriteWithSpriteFrame:[self monsterFrame:newActor]];
	
	//and a window
	CCSprite *window = [CCSprite spriteWithSpriteFrame:[self windowFrame:newActor:noAnim]];	
	
	//get a random starting point
	int tagStart = CCRANDOM_0_1() * BLOCKTIMER_RANDOMSTART;
	[[newActor mainSprite] setTag:tagStart];
	
	//set the locations of the child sprites
	[brick2 setPosition:brickCenter];
	[monster setPosition:brickCenter];
	[window setPosition:brickCenter];
	
	//add those sprites on top of bricks and return bricks
	[bricks addChild:monster z:1 tag:MONSTER_SPRITE_TAG];
	[bricks addChild:brick2 z:2 tag:3];
	[bricks addChild:window z:3 tag:WINDOW_SPRITE_TAG];
	
	//animate if we are animating
	if ( !noAnim) [self animateActor:newActor:window];	
	
	//return bricks with attached monster and window
	return bricks;
}


  
//return level message structure based on current level
-(Level) getLevel:(int) lev {
	//store last time we checked
	static int lastLevelNum=-1;
	static Level lastLevel;
	
	//if current level is not yet cached
	//we should update it here
	if (lastLevelNum == -1 || lastLevelNum != lev) {
		//read through our level message array until we pass our level
		//or we find our level
		int msgID = 0; //default is 0
		for (int c = 0; c <= lev && c < LEVEL_COUNT; c++ ) {
			if ( levels[c].level == lev ) {
				//we found it
				msgID = c;
				break;
			}
		}
		//store that value
		//and remember level # used
		lastLevel = levels[msgID];
		lastLevelNum = lev;
	}
	
	//adjust type count based on calculation where needed
	lastLevel.types = (lastLevel.types > 0 ) ? lastLevel.types : (SKIP_LEVELS_PER_TYPE + lev / LEVELS_PER_TYPE);
	if ( lastLevel.types > 12 ) lastLevel.types = 12;
	
	//return that level
	return lastLevel;
}

//return the current level
-(Level) currentLevel {
	//store last time we checked
	static int lastLevelNum=-1;
	static Level lastLevel;
	
	//if current level is not yet cached
	//we should update it here
	if (lastLevelNum == -1 || lastLevelNum != level) {
		//update cahced value
		lastLevel = [self getLevel:level];
		lastLevelNum = level;
	} 
	
	//return get level with current level
	return lastLevel;
}

//this displays the text between levels
-(void) LevelUpMessage:(int) lev {	
	//display timing for messages
	float dispTime = 0;
	
	//how much we increment display time by
	//note: the time should be slightly more than the delay for the alert manager
	float dispInc = [alertManager totalTime]; 
	
	
	//get the current level
	Level currentLevel = [self getLevel:lev];
	
	//there are simply three messages - schedule them out now
	for (int c = 0; c < LEVEL_MESSAGE_COUNT; c++ ) {
		//trigger this message
		[alertManager triggerAlert:
		 currentLevel.messages[c]:
		 ccp([self screenSize].width/2, [self screenSize].height/2):
		 dispTime
		 ];
		//increment display time
		dispTime += dispInc;
	};
}

//convert a row/col position to a point on the screen
-(CGPoint) rowcolToPoint:(CGPoint) rowcol {
	//create and return a point
	return CGPointMake(rowcol.x * COL_WIDTH - COL_WIDTH/2 + X_SPACE, rowcol.y * ROW_HEIGHT - ROW_HEIGHT / 2 + Y_SPACE_BOTTOM);
}

//allows canceling of the finger help operation
//this gets called after the finger is actually visible
//so that the user doesn't cancel the finger move when they tap
//to go to the next level
-(void) cancelFinger {
	//we can now cancel the finger if we want
	_fingerCanCancel = true;
}

//this actually kills the help actor
-(void) killHelp {
	//kill help if needed
	if ( [menu showingHelp] && _fingerCanCancel) {
		//HACK: now the help text is in the play menu not in our scene
		[menu killHelp];
		//[menu removeActor:helpActor];
		//helpActor = nil;
	}		
}

//this actually kills the help actor
-(void) killFinger {
	//kill help if needed
	if ( [menu showingFinger] && _fingerCanCancel) {
		//HACK: now the help text is in the play menu not in our scene
		[menu killFinger];
		//[menu removeActor:helpActor];
		//helpActor = nil;
	}		
}


//setup the finger
-(void) setupFinger:(CGPoint) startFingerPos:(CGPoint) endFingerPos {	
	//quit if tutorial not enabled
	if ( ![Settings getTutorialEnabled] ) return;
	
	//calculate the locations for the starting and ending
	//based on the given col/row values
	CGPoint startPoint, endPoint;
	
	//convert starting row/col to points on the screen
	startPoint = CGOffsetPoint([self rowcolToPoint:startFingerPos],15,0);
	endPoint = CGOffsetPoint([self rowcolToPoint:endFingerPos],15,0);
	
	//let the menu create the finger
	//so it can appear on top of everything else
	finger = [menu createFinger:startPoint];
	CCSprite *fingerSprite = [finger mainSprite];

	
	//special case for 1 of the training levels
	if ( level == 4 ) {
		//start the action on the finger
		[fingerSprite runAction:
		 [CCRepeatForever actionWithAction:
		  [CCSequence actions:
		   [CCDelayTime actionWithDuration:FINGER_CANCEL_DELAY],
		   [CCCallFunc actionWithTarget:self selector:@selector(cancelFinger)], //touching cancels but wait just a moment for the level to laoad
		   [CCDelayTime actionWithDuration:0.9f],
		   [CCFadeIn actionWithDuration:0.25],
		   [CCDelayTime actionWithDuration:1.0f],
		   
		   //FIRST ROW OF MONSTERS
		   [CCMoveTo actionWithDuration:1.0f position:[self rowcolToPoint:CGPointMake(4, 0)]],
		   [CCFadeOut actionWithDuration:0.4f],
		   
		   //SECOND ROW OF MONSTERS
		   [CCMoveTo actionWithDuration:0 position:[self rowcolToPoint:CGPointMake(3, 2)]],
		   [CCFadeIn actionWithDuration:0.25],
		   [CCMoveTo actionWithDuration:1.0f position:[self rowcolToPoint:CGPointMake(4, 2)]],
		   [CCFadeOut actionWithDuration:0.4f],
		   
		   
		   //THIRD ROW OF MONSTERS
		   [CCMoveTo actionWithDuration:0 position:[self rowcolToPoint:CGPointMake(3, 4)]],
		   [CCFadeIn actionWithDuration:0.25],
		   [CCMoveTo actionWithDuration:1.0f position:[self rowcolToPoint:CGPointMake(4, 4)]],
		   [CCFadeOut actionWithDuration:0.4f],
		   
		   [CCDelayTime actionWithDuration:3.0f],
		   [CCMoveTo actionWithDuration:0 position:startPoint],
		   nil
		   ]
		  ]];
		
	} else if (startPoint.x == endPoint.x && startPoint.y == endPoint.y) {
		//try to make a tappijg motion
		[fingerSprite runAction:
		 [CCRepeatForever actionWithAction:
		  [CCSequence actions:
		   [CCDelayTime actionWithDuration:FINGER_CANCEL_DELAY],	   
		   [CCCallFunc actionWithTarget:self selector:@selector(cancelFinger)], //touching cancels but wait a sec first (so menu touch doesn't cancel)
		   [CCDelayTime actionWithDuration:0.9f],	   
		   [CCFadeIn actionWithDuration:0.25],
		   [CCDelayTime actionWithDuration:1.0f],
		   [CCScaleTo actionWithDuration:0.25f scale:1.1],
		   [CCScaleTo actionWithDuration:0.25f scale:1.0],
		   [CCDelayTime actionWithDuration:0.5f],
		   //[CCScaleTo actionWithDuration:0.25f scale:1.1],
		   //[CCScaleTo actionWithDuration:0.25f scale:1.0],
		   [CCFadeOut actionWithDuration:0.4f],
		   [CCDelayTime actionWithDuration:2.0f],
		   nil
		   ]
		  ]];
		
	} else {
		//start the action on the finger
		[fingerSprite runAction:
		 [CCRepeatForever actionWithAction:
		  [CCSequence actions:
		   [CCDelayTime actionWithDuration:FINGER_CANCEL_DELAY],	   
		   [CCCallFunc actionWithTarget:self selector:@selector(cancelFinger)], //touching cancels but wait a sec first (so menu touch doesn't cancel)
		   [CCDelayTime actionWithDuration:0.9f],	   
		   [CCFadeIn actionWithDuration:0.25],
		   [CCDelayTime actionWithDuration:1.0f],
		   [CCMoveTo actionWithDuration:1.0f position:endPoint],
		   [CCFadeOut actionWithDuration:0.4f],
		   [CCDelayTime actionWithDuration:5.0f],
		   [CCMoveTo actionWithDuration:0 position:startPoint],
		   nil
		   ]
		  ]];
	}
	
	
}


//show the help text
-(void) showHelpText:(NSString *) helpText {
	//quit if tutorial not enabled
	if ( ![Settings getTutorialEnabled] ) return;
	
	//we are showing help
	//so finger can't cancel yet
	_fingerCanCancel = false;

	//show help (use menu)
	[menu showHelp:helpText];
	
	
	
	/*
	//kill existing help actor if needed (canceling not relevant here)
	[self killHelp];
	
	//test: help as an image overlay
	CCSprite *helpSprite = [CCSprite spriteWithFile:@"helptext-1.png"];
	[helpSprite setPosition:ccp(160,240)];
	[menu addChild:helpSprite];
	helpActor = [[Actor alloc] init:menu];	
	[menu addActor:helpActor];
	
	//create a new text actor for the help
	//HACK: add the help actor to the menu layer instead of our layer
	//so that the behaviors that require the tick event will work properly
	//helpActor = [menu addTextActor:CGPointMake(160,440) :helpText :@"CCZoinks" :28 :LM_LIGHTORANGE:CGSizeMake(306,440):UITextAlignmentCenter];
	//[[helpActor mainSprite] setAnchorPoint:CGPointMake(0.5, 1.0)];
	
	//shadowtext behavior creates a slight shadow on the text making it pop out better
	//[helpActor addBehavior:[ShadowText alloc]];
	
	//the help only sticks around a little while then goes away
	[[helpActor mainSprite] setOpacity:0.0];
	
	[[helpActor mainSprite] runAction:
		 [CCSequence actions:
		  [CCDelayTime actionWithDuration:1.0f],
		  [CCFadeIn actionWithDuration:0.50f],
		  [CCDelayTime actionWithDuration:12.3f],
		  [CCFadeOut actionWithDuration:0.5f],
		  [CCCallFunc actionWithTarget:self selector:@selector(removeHelpText)], //this will also clean up our reference properly
		  nil		
		  ]
	 
	];
	
*/
}
	

//clean up help text if needed
-(void) removeHelpText {
	//kill the finger
	if ( [menu showingHelp] && _fingerCanCancel) {
		[menu fadeHelp];
	}
}


//make the finger and help fade out
-(void) removeFinger {
	//kill the finger
	if ( [menu showingFinger]  && _fingerCanCancel) {
		//Fade To is better than FadeOut, because it starts at the current opacity
		[menu fadeFinger];
		/*
		[[finger mainSprite] runAction:[CCSequence actions:
			[CCFadeTo actionWithDuration:0.5 opacity:0],
			[CCCallFunc actionWithTarget:self selector:@selector(killFinger)],
			nil
		]];
		*/
	}
	//that's it
}

//kill the finger when the user touches the screen
-(void) onTouchBegan:(CGPoint)location {
	//kill the finger and help text
	[self removeFinger];
	[self removeHelpText];
	
	//testing: - fire off 3 at once
	/*
	[alertManager triggerAlert:@"TEST HERE 1" :location];
	[alertManager triggerAlert:@"TEST HERE 2" :location];
	[alertManager triggerAlert:@"TEST HERE 3" :location];
	[alertManager triggerAlert:@"TEST HERE 4" :location];
	[alertManager triggerAlert:@"TEST HERE 5" :location];
	*/
	
	//do the regular stuff
	[super onTouchBegan:location];
}

//kill the finger when the user touches the screen
//we do this here - so we get them coming and going
//because it is possible the user literaly started moving the second the game started
//we don't want to discount the move, the total move should take be slow enough to catch though
-(void) onTouchEnded:(CGPoint)location {
	//kill the finger and help text
	[self removeFinger];
	[self removeHelpText];
	
	//do the regular stuff
	[super onTouchEnded:location];
}

//this spawns the freebie heart/hammer for user
//just for getting this far
/*
 -(void) spawnFreebie {
	//determine a random block type - usually coin
	int bonusBlockType = COIN_BLOCK_TYPE;
	//CCRANDOM_0_1() *  BOMB_BLOCK_TYPE;
	
	//testing: load a coin block when they get a combo
	[super spawnCollectable:bonusBlockType];	
}
*/

//this fills the whole board with random blocks
-(void) fillBoard {
	//declarations
	bool initBoard = false;
	
	//display level up message
	[self LevelUpMessage:level];
	//setup the initial playboard
	Level currentLevel = [self currentLevel];
	
	//start by creating all the actors (but black)
	//then we will randomly turn some of them colored
	for (int y = 0; y < ROWS; y++ ) {
		for (int x = 0; x < COLS; x++ ) {
			//get a random ball type (from our list of not so random letters from our word list)
			int ballType = 0;
			int ballState = -1;
			
			//CCRANDOM_0_1()*BALL_TYPES+1;
			//ballType = 0; //start with a blank cavnas
			
			//zero is a black ball - place holder for other balls
			//calculate coords of this sprite
			CGPoint newcoords = CGPointMake(X_SPACE+x*COL_WIDTH,Y_SPACE_BOTTOM+y*ROW_HEIGHT);
			
			//if the current level has a defined board
			//we will use that definition here
			if (currentLevel.board[y][x] != 0) {
				//yup - we defined a board for this level so don't trigger
				//a mass spawn in the beginning of the level
				//update bal type to this value
				//but remember to reduce the available count
				//for this block type				
				ballType = currentLevel.board[y][x];
				initBoard = true;
				
				//-3 is a special case - thsi is a boarded wndow
				if ( ballType == -3 ) {
					//boarded window
					ballType = 0;
					ballState = 2; 
				} if ( ballType == COIN_BLOCK_TYPE ) {
					//note: all collectables are ball state 3
					ballState = 3; 
				}
				
				//this is considered deploying a block
				if ( ballType > 0 ) [counter deployType:ballType];
				
				

			}
			
			//use existing reference if available
			//if not - then create a new one and save into playboard
			Actor *bubble = playboard[y][x];
			if (!bubble) {
				//start with an empty block
				bubble = [super addNewSpriteWithCoords:newcoords :ballType:false];
				
				playboard[y][x] = bubble;
				[self blockBehaviors:bubble];
			} else {
				//only update sprite image if it is differnt than the current one
				//that way we don't have closed windows opening and reclosing every lev3el
				//and boarded windows won't do the same either
				if ( [bubble getType] != ballType || ballState != -1) { 
					//make the existing block empty
					[bubble setType:ballType];
					//testing: do not overwrite existing state - instead leave those locked blocks forever
					//[bubble setState:0];
					
					//set state if not default (-1)
					if ( ballState != -1 ) [bubble setState:ballState];
					
					//update the sprite color/image					
					[super setSpriteColor:bubble:false];
					
				}
				
			}
			
			//there is either 1 more active bubble or 1 more available location
			if ( ballType == 0 ) availCount++;
			if ( ballType != 0) activeBalls++; //there is 1 more active ball
			
		}
	}
    
    //visit all blocks on the board - update links, fades collectables, etc
	
	//update the available count
    [super visitBlocks:false:false:true];
	//[self updateAvailCount];
	
	//update links for all blocks
    [super visitBlocks:false:true:false];
	//[self updateLinks];	
	
	//start with a completely and totally available playboard
	//availCount =  ROWS*COLS;
	
	//if this level has a "help finger" show it	
	if ( ! ( currentLevel.fingerStart.x == 0 && currentLevel.fingerStart.y == 0 ) ) {
		//setup the finger for this level
		[self setupFinger:currentLevel.fingerStart:currentLevel.fingerEnd];
	}
	
	//if this level has help text - show that too
	if ( currentLevel.helpText != nil ) {
		//setup the finger for this level
		[self showHelpText:currentLevel.helpText];
	}

	//spawn a bomb every 5th level after level #5
	if ( level % 5 == 0 && level > 5) {
		[self spawnCollectable:COIN_BLOCK_TYPE];
	}
	
	//only trigger a mass spawn when we did not start with an initial board
	//start by triggering a mass spawn
	if (!initBoard) {
		//trigger a mass spawn to get the level started
		//but do after a slight delay because all the scheduling and whatnot is not yet up and running
		[super performSelector:@selector(triggerMassSpawn) withObject:nil afterDelay:5.0f];
		definedBoard = false;
		
	} else {
		definedBoard = true;
	}
}

//this fills the whole board with random blocks
-(void) loadBoard {
	//declarations
	bool initBoard = true;
	definedBoard = false; //not relevant here
	
	//display level up message
	[self LevelUpMessage:level];	

	//setup the initial playboard
	Level currentLevel = [self currentLevel];
	
	//get the board from settings
	NSString *boardDef = [Settings getString:[NSString stringWithFormat:@"%@Board",[self modePrefix]] :nil];
	
	//quit if nil - this should not be
	if (boardDef == nil) return;
	
	//split that board defintion into seperate strings for each row
	NSArray *rows = [boardDef componentsSeparatedByString:@"~"];
	
	//row through all rows
	for (uint y = 0; y < [rows count]; y++ ) {
		//now split this row into the columns
		NSArray *cols = [(NSString *)[rows objectAtIndex:y] componentsSeparatedByString:@"|"];
		
		//run through all those columns
		for (uint x = 0; x < [cols count]; x++ ) {
			//each of this is a string defining the block
			NSArray *attribs = [(NSString *) [cols objectAtIndex:x] componentsSeparatedByString:@","];
			
			//get the type and state of the block
			int ballType = [[attribs objectAtIndex:0] intValue];
			int ballState = [[attribs objectAtIndex:1] intValue];
			
			//zero is a black ball - place holder for other balls
			//calculate coords of this sprite
			CGPoint newcoords = CGPointMake(X_SPACE+x*COL_WIDTH,Y_SPACE_BOTTOM+y*ROW_HEIGHT);
			
			//if the current level has a defined board
			//we will use that definition here
			//blocksDeployed[ballType]++;
			initBoard = true;
			
			//use existing reference if available
			//if not - then create a new one and save into playboard
			Actor *bubble = playboard[y][x];
			if (!bubble) {
				//start with an empty block
				bubble = [super addNewSpriteWithCoords:newcoords :ballType:false];
				playboard[y][x] = bubble;
				[self blockBehaviors:bubble];
			} 
			
			//set the state of the bubble and update its color (actually that's the graphics)
			[bubble setType:ballType];
			[bubble setState:ballState];
			[super setSpriteColor:bubble :false];
			
			//there is either 1 more active bubble or 1 more available location
			//if ( ballType == 0 ) availCount++;
			//if ( ballType != 0) activeBalls++; //there is 1 more active ball
			
		}
	}
	
	//update links for all blocks
	//[self updateLinks];	
    
    //visit all blocks on the board - update links, fades collectables, etc
    [super visitBlocks:false:true:false];


	
	//never trigger a mass spawn here because we just loaded a saved board
	
}

//remaining moves is easy
-(int) remainingMoves {
	//run through all block types
	int results = 0;
	for (int c = 1; c <= BALL_TYPES; c++ ) {
		if ( [counter deployed:c] - [counter collected:c] >= 4) {
			results++;
		}
	}
	
	//return what we found
	return results;
	
}

//returns the status of blocks (but never above max)
-(int) blockStatus:(int) blockType {
	int results = [counter collected:blockType];
	results = (results > [counter max:blockType]) ? [counter max:blockType] : results;
	return results;
}

//this method prints out all diagnostic information about the counters
-(void) diag {
	//go through each block type
	//and print its counts
	for (int c = 1; c <= BALL_TYPES; c++ ) {
		//print this block
		[self checkDeployedBlocks:c :0];
		
	}
	
	//print waiting types
	NSLog(@"***********************************");
	NSLog(@"max: %@",[counter maxToString]);
	NSLog(@"waiting: %@",[counter waitingToString]);
	NSLog(@"paused: %@",[counter pausedToString]);
	NSLog(@"avail: %@",[counter availToString]);
	NSLog(@"deployed: %@",[counter deployedToString]);
	NSLog(@"collected: %@",[counter collectedToString]);
	NSLog(@"***********************************");
}


//this method resets statuses on the menu
//we have it here so we can call delayed if we need
-(void) resetStatuses {
	//clear all statuses
	[menu clearStatuses];
	
	//run through all current statuses
	for (int c = 1; c <= BALL_TYPES; c++ ) {
		//get the new status
		float newStatus = [self blockStatus:c];		
		
		//only add the status if it should be added
		if ( newStatus < [counter max:c] ) {
			//add this status and set it at the correct current state
			//as well as the correct min and max values
			[menu addStatus:c];
			[menu resetStatus:c :0 :[counter max:c]];
			[menu updateStatus:c :newStatus];			
		}
	}
	

	
}

//this method loads types from settings instead of initializing them
-(void) loadTypes:(int) lev {
	//get current level (save for later)	
	Level currentLevel = [self getLevel:lev];
	
	//load static int values
	int maxTypeCount = [Settings getInt:[NSString stringWithFormat:@"%@MaxTypeCount",[self modePrefix]] :0];
	int availTypeCount = [Settings getInt:[NSString stringWithFormat:@"%@AvailTypeCount",[self modePrefix]] :0];
	int waitingTypeCount = [Settings getInt:[NSString stringWithFormat:@"%@WaitingTypeCount",[self modePrefix]] :0];		
	int pausedTypeCount = [Settings getInt:[NSString stringWithFormat:@"%@PausedTypeCount",[self modePrefix]] :0];
	
	//update other counters
	activeBalls = [Settings getInt:[NSString stringWithFormat:@"%@ActiveBalls",[self modePrefix]]:0];
	availCount = [Settings getInt:[NSString stringWithFormat:@"%@AvailCount",[self modePrefix]] :0];
	
	//load the corresponding arrays from settings
	[counter maxFromString:[Settings getString:[NSString stringWithFormat:@"%@MaxBlocks",[self modePrefix]]:@""]:maxTypeCount];
	[counter collectedFromString:[Settings getString:[NSString stringWithFormat:@"%@BlocksCollected",[self modePrefix]] :@""]];
	[counter deployedFromString:[Settings getString:[NSString stringWithFormat:@"%@BlocksDeployed",[self modePrefix]] :@""]];
	
	//while setting the array we also set the counts
	[counter availFromString:[Settings getString:[NSString stringWithFormat:@"%@AvailTypes",[self modePrefix]] :@""]:availTypeCount];
	[counter waitingFromString:[Settings getString:[NSString stringWithFormat:@"%@WaitingTypes",[self modePrefix]] :@""]:waitingTypeCount];
	[counter pausedFromString:[Settings getString:[NSString stringWithFormat:@"%@PausedTypes",[self modePrefix]] :@""]:pausedTypeCount];
	

}

//this initializes a level that was not saved
//but is being created from scratch
-(void) initializeTypes:(int) lev {
	//get current level (save for later)	
	Level currentLevel = [self getLevel:lev];

	//the number of available blocks for this level
	//this may be calculated if the level defines it as zero
	int levelBlocks = (currentLevel.maxBlocks > 0 ) ? currentLevel.maxBlocks : BLOCKS_PER_LEVEL_PER_TYPE * lev;
	
	//initialize types on the count manager
	[counter initializeTypes:currentLevel.types:levelBlocks];
	
}

//setup statuses and other stuff
-(void) setupStatuses {
	//reset statuses for the level right away
	//in case the user collects a monster before a delayed fire would get called
	[self resetStatuses];
		
	
	//reschedule spawning
	[self resume];
	
	//update paused states
	[self updatePaused];
	
	//trigger lives
	[menu updateLives:lives];
	
	
}

//this configures the gameboard for a given level
-(void) configureLevel:(int) lev {
	
	//when the level starts we can't already have quick fires
	countingQuickFires = false;
	quickFires = 0;
	quickFireCounter = 0;
	
	//get current level (save for later)	
	Level currentLevel = [self getLevel:lev];
	
	//reset all the counters for the level
	[super resetCounters:currentLevel.maxInterval:currentLevel.minInterval:currentLevel.minSpawn:currentLevel.maxSpawn];
	
	//reset the count manager
	[counter reset:currentLevel.types];
	
	//save max states for level
	maxStates = currentLevel.states;
	
	//update ball types based on current level
	BALL_TYPES = currentLevel.types;	
}

//this method starts spawning if appropriate
-(void) startSpawning {
	//don't start spawning if still on the "defined" board
	if ( definedBoard) return;
	
	//should we even bother scheduling the spawn?
	//for now thoughtful doesn't change spawn timing
	if ([counter avail] > 0 && !_thoughtful) {
		//schedule the spawn bubble (unless we 
		[self spawnBubble];
	}
	
}

//this method will resume the level playing
//you would call this after the user clicks on the
//level up message to continue
-(void) advanceLevel {
	//clear the # of bombs this level	
	bombsCollected = 0;
	
	//move to the next level
	level++;
	
	//resume playing the regular music
	//[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"troublemaker.mp3"];
	
	//configure the current level
	[self configureLevel:level];
	[self initializeTypes:level];
	[self setupStatuses];
	
	//fill the board with some starting sprites
	[self fillBoard];
	
	//reset all statuses
	//this gets called in setup statuses
	//[self resetStatuses];
	
	//schedule spawning
	[self startSpawning];
	
}

//this determines the # of total remaining blocks of any type (or zero for all types)
-(int) remainingBlocks:(int) blockType {
	//the return count
	int results = 0;
	
	if (blockType == 0) {
		//run through all block types
		for (int c = 1; c <= BALL_TYPES; c++ ) {
			//remaining blocks of this type is deployed minus collected
			if ( [counter collected:c] < [counter max:c]) {
				results += [counter max:c] - [counter collected:c];
			}
		}
	} else {
		//remaining blocks of this type is deployed minus collected
		if ( [counter collected:blockType] < [counter max:blockType] ) {
			results = [counter max:blockType] - [counter collected:blockType];
		}
	}	
	
	//return what we found
	return results;
}

//use a life
-(void) useLife {
	
	//for now - let the user know we are using a life
	//[alertManager triggerAlert:@"USING A LIFE" :CGPointMake(160.0f,240.0f)];
	
	//we have one less life
	//make sure the player can see it too 
	lives--;
	[menu updateLives:lives];
	
}

//in this version of the game
//a level up results in us reloading the playboard
-(bool) levelUp {
	//get some counts real quickly
	//int lockedCount = [self lockedCount];
    int remainingMoves = [self remainingMoves];
	int remainingCount = [self remainingBlocks:0];
    //int deployedCount = [counter onBoard];
	int lockedCount = [self lockedCount];
    
    //QUICK FIX: count blocks on board using our array not the counter
    //since its not correct
    int deployedCount = 0;
    for (int c = 1; c <= [counter max]; c++ ) {
        deployedCount += blocksOnBoard[c];
    }
	
	//game over if there are no more possible combinations
	if ( lockedCount > ROWS * COLS - 4) {
		//GAME OVER SCENARIO:

		//if ( lockedCount > ROWS*COLS-4 && lives <= 0) {
		//when the game is over we need to clear the level count
		[self clearLevel];
		
		//this is a game over
		//because we only have 4 blocks that aren't locked left
		//they are done
		
		//note: even if in lite mode - the game is not over due to being lite mode
		//so don't show it here
		[self gameOver:false];
		return true;
		
	} else if ( remainingMoves == 0 && deployedCount+lockedCount >= ROWS*COLS  ) {
        //if there are no remaining moves and the # of locked + monsters on board
        //is equal to the # of spots on the board - then we are done
        //oh... and the user doesn't have any bombs
		[self clearLevel];
		[self gameOver:false];
		return true;
    
    } else if ( lockedCount > 1 && availCount <= 0 && lives > 0) {
		//TODO: handle this scenario (no available spots anymore)
		//without using a "life" since that's going to be for busting boards
		
		//clear all boards on the board
		//[self bustBoards];
		
		//its not game over - we just loose a life and keep going		
		//[self useLife];
		return true;
				
	} else if (remainingCount == 0) {
		//before preceeding to next level force the collection timer to stop
		//this ensure we did not miss any opportunities to collect quick fire points (the X2 x3 thing)
		if ( countingQuickFires ) {
			quickFireCounter = QUICK_FIRE_DELAY+1;
			[self quickFireClick];
		}
	
		//make sure the finger is removed and canceled
		[self cancelFinger];
		
		//don't just remove here - kill the bastards! (the level menu will pause actions, and kill doesn't use an action)
		[self killHelp];
		[menu killFinger];
		
		//clear all existing collectables from the level
		[super clearCollectables];
		
		//if we are in the limited version then we
		//check to see if we hit the max # of levels and we stop there
		if ( LITE_VERSION && level >= LITE_LEVEL_LIMIT ) {
			//if ( lockedCount > ROWS*COLS-4 && lives <= 0) {
			//when the game is over we need to clear the level count
			[self clearLevel];
			
			//this is a game over
			//because we only have 4 blocks that aren't locked left
			//they are done
			
			//note: here the game is over due to lite version - shows a different window
			[self gameOver:true];
			
			//quit here
			return true;
			
		}
		
		//save our level here before we even show the level up menu
		//this is cheesey but fine for now
		level++;
		[self saveLevel];
		level--;
		
		//pause this scene
		//[self pause];
		
		//get this new level
		Level newLevel = [self getLevel:level+1];
		
		//we can get a freebie life at the next level
		freebieLifeSpawned = false;
		
		//update the # of coins for this level
		[menu updateCoins:coins];
		
		//start playing the level up music
		//[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"comical-game.mp3"];
		
		//if there is a new block or state pass to messagebox
		if (newLevel.newBlockType != 0 ) {
			//show the level up messageboard on play menu
			[menu showMessageBox:level:newLevel.newBlockType];
		} else if ( (level+1) >= LEVELS_PER_TYPE && (level+1) / LEVELS_PER_TYPE < MAX_BLOCK_TYPES && (level+1) % LEVELS_PER_TYPE == 0 ) {
			//calculate the new block type (shows up every xx levels
			[menu showMessageBox:level: SKIP_LEVELS_PER_TYPE+(level+1) / LEVELS_PER_TYPE];
			
		} else {
			//show the level up messageboard on play menu
			//but not the "introducing" stuff
			[menu showMessageBox:level];
		}
		
		//yes there is a level up
		return true;
	}
	
	//if we get here we did not level up
	return false;
}

//set up all animation frames
-(void) initAnimations {
	//create the window opening animation
	animWindowClosing = [[CCAnimation animationWithName:@"windowClosing"] retain];
	[animWindowClosing setDelay:0.05f];
	[animWindowClosing addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-open.png"]];
	[animWindowClosing addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-opening-2.png"]];
	[animWindowClosing addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-opening-1.png"]];
	[animWindowClosing addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-closed.png"]];
	
	//create the window opening animation
	animWindowOpening = [[CCAnimation animationWithName:@"windowOpening"] retain];
	[animWindowOpening setDelay:0.05f];
	[animWindowOpening addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-closed.png"]];
	[animWindowOpening addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-opening-1.png"]];
	[animWindowOpening addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-opening-2.png"]];
	[animWindowOpening addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-open.png"]];
	
	
	//create the window boarding up animation
	animWindowBoarding = [[CCAnimation animationWithName:@"windowBoarding"] retain];
	[animWindowBoarding setDelay:0.05f];
	[animWindowBoarding addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-open.png"]];
	[animWindowBoarding addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-opening-2.png"]];
	[animWindowBoarding addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-opening-1.png"]];
	[animWindowBoarding addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-closed.png"]];
	[animWindowBoarding addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-boarded-1.png"]];
	
}

//bust a board at a specific position
-(void) bustBoard:(CGPoint) pos {
	//show the new monster in open feint
	//this is a bit of a hack since we don't actually show the "lost" screen for birds eye
	[LGSocialGamer achieve:ACHIEVE_BOARDBUST percentComplete:100];
	
	//play the bust board sound
	//pan the board busting based on the position of the board
	//NOTE: pan is based exactly on location of the board relative to the center of the screen
	if ( soundEnabled) [[SimpleAudioEngine sharedEngine] playEffect:@"bust-board.mp3" pitch:1.0f pan:CALCULATE_PAN(pos.x) gain:0.5f];

	
	//fire a particle efect on the board
	//so the user sees what we are doing
	CCQuadParticleSystem *cp = [CCQuadParticleSystem particleWithFile:@"BustBoards.plist"];
	cp.autoRemoveOnFinish = true;
	cp.position = pos;
	
	//these boards are getting blasted off, so should spin
	cp.startSpin = 250.0f;
	cp.startSpinVar = 50.0f;
	cp.endSpin = 25.0f;
	cp.endSpinVar = 50.0f;
	
	//add to the layer to trigger the effect
	[self addChild:cp];
	
}

//this method removes all boarded windows from the playboard
//and triggers some cool effects on them - making it look like
//the boards were shattered
-(void) bustBoards {

	//go through all windows on the board
	for (int r = 0; r < ROWS; r++ ) {
		for (int c = 0; c < COLS; c++ ) {
			//if this is a boarded window
			//update its state
			if ( [playboard[r][c] getState] == 2 ) {
				//update the window state and trigger animation
				[playboard[r][c] setState:0];
				[self setSpriteColor:playboard[r][c] :true];
				
				//bust a board at this poisiton
				[self bustBoard:[playboard[r][c] position]];
			}
		}
	}
	
	//testing:
	//[alertManager triggerAlert:@"busting boards" :ccp(160,240)];
}


//this function clips a sprite frame to a specified size given the sprite frame and size
-(void) clipFrame:(CCSpriteFrame *) frame:(int) width:(int) height {
	//is this sprite found?
	if ( frame != nil ) {
		//get this sprite frame (first one)
		CGRect fr = [frame rect];
		
		//adjust the sprite frame if its too big for the window
		if ( fr.size.width > width || fr.size.height > height ) {
			//updated sizes
			
			//set the rectangle
			[frame setRect:CGRectMake(fr.origin.x + (fr.size.width-width)/2 - 4 , fr.origin.y+(fr.size.height-height)/2 - 4, width,height )];
		}
	} 
	//that's it
}

//this initializes our playboard
-(void) startScene {
	//if the movie was watched 3 times in a row, they get the achievement
	if ( [Settings getInt:@"movies" :0] == MOVIE_BUFF_GOAL ) {
		//they get this silly little achievement
		[LGSocialGamer achieve:ACHIEVE_MOVIEBUFF percentComplete:100];
	}
	
	//setup the count manager
	counter = [CountManager alloc];
	
	//update sound enabled value from user settings
	soundEnabled = [Settings getSoundEnabled];	
	
	//start the game with a specific # of lives
	//this could vary depending on the difficulty setting, etc
	lives = START_GAME_LIVES;
	
	//set block types and file
	BALL_TYPES = 1;
	BLOCK_FILE = @"NewGrid.png";
	//BLOCK_PLIST = @"sprites.plist";
	
	//start on the first level
	level = 1;
	
	//get teh screen size
	//notice this is a class variable reusable in other functions
	screenSize = [self screenSize];
	
	//start without a mass spawn
	massSpawnCount = 0;
	
	
	//create the texture
	CCTexture2D *sprites = [[CCTextureCache sharedTextureCache] addImage:@"sprites.png"];
	
	//setup sprite frame using that texture
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"sprites.plist" texture:sprites];
	
	//go through all monster frames and clip them here
	//this is just a quick little solution
	//so i don't have to edit them all
	for (uint m = 1; m <= 12; m++ ) {
		//each monster can have any # of sprites
		//lets keep checking until we don't find one
		int frameNum = 0;
		CCSpriteFrame *f = nil;
		
		//is this sprite found?
		while ( f != nil || frameNum == 0 ) {
			//get this sprite frame
			//and clip it
			frameNum++;
			f = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-%i.png",m,frameNum]];
			[self clipFrame:f:42:54];
		}
		
		f = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-t.png",m]];
		[self clipFrame:f:42:54];

		
		/*
		//there are exactly 4 tease animations for each monster
		for (int c = 1; c <= 4; c++ ) {
			//we have identified and adjusted all frames for this monster		
			//don't forget to clip the "tease" frame too
			f = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-t-%i.png",m,c]];
			[self clipFrame:f:42:54];
		}
		*/
	}
	
	
	
	//setup the sprite sheet using the texture as well
	blockSheet = [CCSpriteSheet spriteSheetWithTexture:sprites];

	//Set up sprite
	//blockSheet = [CCSpriteSheet spriteSheetWithFile:BLOCK_FILE capacity:150];
	//blockSheet = [CCSpriteSheet spriteSheetWithTexture:[CCTextureCache sharedTextureCache] textureWithKey:@"sprites.png"];
	[self addChild:blockSheet z:0 tag:1];		
	
	
	//load all teaser animations
	//NOTE: no longer using tease animations, instead slowly incrementing the frame in boardTimer
	[self createTeaseAnimations];
	[self createRandomAnimations];
	
	//initialize animations
	//we retain them and release ourselves
	//because we use the same ones over and over
	[self initAnimations];
	
	//schedule 3 instances of ambient effect to fire continually
	//that way there are always 3 random sprites doing something on the board
	[self ambientEffect:true];
	[self ambientEffect:true];
	[self ambientEffect:true];
	
	//store the window "tease" texture rectangles here for quick comparison when "spinng"
	windowTeaseRect1 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-tease-1.png"].rect;
	windowTeaseRect2 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-tease-2.png"].rect;
	windowTeaseRect3 = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"window-tease-3.png"].rect;
	
	
}


//use this to check teaseAnims....debugging/testing
-(int) checkTeaseAnims {
	return ( teaseAnims == nil ) ? -1 : 1; 
}

//override this method to catch preclick 
//return true to cancel
-(bool) beforeClick {
	DLOG(@"Frantic.beforeClick(): Start");
	//reset combo count
	combos = 0;
	
	//store current points before click
	comboPoints = [pointTracker getPoints];
	
	//don't abort
	return false;
	DLOG(@"Frantic.beforeClick(): End");
}

//override this method to catch post click
-(void) afterClick {
	//how many boarded blocks were there last time?	
	DLOG(@"Frantic.afterClick(): Start");
	static int boardedBlocks = 0;
	int currentBoardedBlocks = [self lockedCount];
	
	//HACK: adjust counts now
	for (int c = 1; c <= [counter max]; c++ ) {
		[counter adjust:c];
	}
	
	//get remaining moves count
	int remainingMoves = [self remainingMoves];
	int remainingBlocks = [self remainingBlocks:0];
		
	//did their actions result in no more remaining moves?	
	//if so we give them credit here and it will be doubled if they
	//happened to do a combo to get it
	
	//NOTE: DO NOT GIVE THEM CREDIT IF THE EMPTY BOARD IS BECAUSE
	//WINDOWS WERE GETTING BOARDED
	
	//AND: DON'T TRIGGER MASS SPAWN ON DEFINED BOARD OR WHEN THERE ARE NO MORE BLOCKS TO SPAWN
	if ( remainingMoves	== 0 && ![super massSpawning] && remainingBlocks > 0 && !definedBoard ) {
		//here we are doing a mass spawn - not a level up
		//they only get a mass spawn trigger when there are still possible blocks
		//because if they just cleared the level that doesn't deserve extra points 
		//(only when they are faster than the computer should they get points)
		
		//just give hell now
		[super triggerMassSpawn:MASS_SPAWN_COUNT];
		
	}
	
	//we found at least 1 combo
	if (combos > 1) {
		//determine points added in this click event and multiply by combo value
		int bonus = ([pointTracker getPoints] - comboPoints) * combos;
		
		//now we need to add those points to tracker
		[pointTracker addPoints:bonus];
		
		//and display a combo message		
		CGPoint pos = lastTouch;
		[alertManager triggerAlert:[NSString stringWithFormat:@"Combo x%i",combos] :pos];
		
		//trigger the first combo achievement
		[LGSocialGamer achieve:ACHIEVE_FIRSTCOMBO percentComplete:100];
		
		//update best combo
		[menu updateBestCombo:quickFires];
		
		//OF integration - submit sweet combo score to OF
		//[OFHighScoreService setHighScore:quickFires forLeaderboard:OFLB_COMBO onSuccess:OFDelegate() onFailure:OFDelegate()];
		
		
		//they got this one - lets see what happens
		//100% is the correct amont
		//[gkHelper reportAchievementWithID:[NSString stringWithFormat:@"lostmonsters.combox%i",combos] percentComplete:100];
		
		//spawn a collectable for each combo
		//this means a single combo gets one coin
		//but a triple combo gets 2 coins, etc
		//if ( combos > 1 ) {
			//determine a random block type - usually coin
			int bonusBlockType = COIN_BLOCK_TYPE;
			//CCRANDOM_0_1() *  BOMB_BLOCK_TYPE;
			
			//testing: load a coin block when they get a combo
			[super spawnCollectable:bonusBlockType];
	}
	
	//play a sound if we had at least 1 combo collected
	//but if we didn't and we are in thoughtful mode then
	//we should spawn another bubble
	//meaning - in thoughtful mode we don't spawn when blocks are collected
	if ( combos >= 1 ) {
		//play a regular sound
		if ( soundEnabled) [[SimpleAudioEngine sharedEngine] playEffect:@"points2.mp3"];
	} else if ( _thoughtful  ) {
		//only in thoughtful mode - we finally didn't create a quickfire connection
		[self quickFireClick];
		
		//if there are still blocks to spawn, do that now
		//spawn.... note if in thoughtful mode
		//each call to spawn does not schedule another spawn
		if ( remainingBlocks > 0 ) [self spawnBubble]; 
	}
	
	
	//store the current # of boarded blocks
	boardedBlocks = currentBoardedBlocks;	
	DLOG(@"Frantic.afterClick(): End");
}

//this is a delayed handle link type behavior
-(void) DelayedHandleLinkType:(LinkedTypes *) linkTypeBehavior {
	//schedule the handle link type behavior
	[self performSelector:@selector(HandleLinkType:) withObject:linkTypeBehavior afterDelay:5.0f];
}

//this selector gets fired from linked type counter
//for specific types of blocks
//this gets called when a set of blocks registers points
-(void) HandleLinkType:(LinkedTypes *) linkTypeBehavior {
	//we started the function
	DLOG(@"HandleLinkType():Start");
	
	//if we got this far we should not have any level help showing
	[self cancelFinger];
	[self removeFinger];
	[self removeHelpText];
	
	//if this is the first collection on a defined board
	//we need to schedule spawning
	//don't do this until there are no blocks at all on the board
	if ( definedBoard == true ) {
		//if we have cleared all items on the baord, or there are less than 4 items
		//left, let's start spawning
		if ( [counter onBoard] == 0 || [self remainingMoves] <= 0 ) {		
			//this allows the user to complete a "help" task before
			//getting overwhelmed by spawning monsters
			//we really only use this on learning levels
			definedBoard = false;
			[self startSpawning];
		}
	}
	
	//if we are not already in a quick fire counting, start it now
	if ( !countingQuickFires ) {
		//reset and schedule everything
		countingQuickFires = true;
		quickFireCounter = 0;
		quickFires = 1;
		quickFireStartScore = [pointTracker getPoints];
		
		//if we are in frantic mode you have 1 second to complete a connection
		//but in thoughtful mode you simply keep going until a move doesn't result in a connection
		if ( !_thoughtful) [self schedule:@selector(quickFireClick) interval:1.0f];
		
	} else {
		//we have collected another quick fire
		quickFires++;
		
		//extend the time until collection
		quickFireCounter -= QUICK_FIRE_DELAY;
		
		//CGPoint pos = lastTouch; //[[linkTypeBehavior owner] mainSprite].position;
		CGPoint pos = CGPointMake(screenSize.width/2, screenSize.height/2);
		
		//trigger an alert for the level up
		[alertManager triggerAlert:[NSString stringWithFormat:@"X%i",quickFires]:pos];
		
		
	}
	
	//this may qualify as a combo move
	combos++;
	
	//add up this type of block
	int lastType = [[linkTypeBehavior owner] getType];
	int lastCount = [linkTypeBehavior LastLinkCount];
	
	//abort for types less than zero - these are collectable
	//and shouldn't get linked here
	if ( lastType < 0 ) return;
		
	//testing: update pause type before updating status
	//that way we catch any adjustments in monster count
	//immediately
	[self updatePaused];

	//update status of this block type
	int typeStatus = [counter max:lastType];
	[menu updateStatus:lastType :[self blockStatus:lastType]:typeStatus];
	
	//get the physical block count
	//and adjust so that deployed is never less than collected plus physical	
	
	//if we have collected every block deployed and deployed the # of blocks we intended
	if ( [counter done:lastType] ) { 
		//play a sound to indicate this type has been cleared
		if ( soundEnabled) [[SimpleAudioEngine sharedEngine] playEffect:@"light-applause.mp3"];		
		
		//pop the block type we are done with it
		[menu popStatus:lastType];

		//pop the waiting type
		//so it starts doing things
		[counter popWaitingType];
		
	} else {
		[menu checkStatus:lastType];
	}
	
	
	//each link type has a different set of random sayings
	const int sayingCount = 3;
	const int badgeCount = 3;
	NSString *sayings[badgeCount][sayingCount] = {
		{@"NICE",@"SWEET",@"GREAT"},
		{@"AWESOME",@"WICKED",@"SUPER"},
		{@"INCREDIBLE",@"SUPER-STAR",@"WAY TO GO"}
	};
	
	
	//get link count
	int linkCount = lastCount;
	
	//handle larger link counts
	if ( linkCount >=5 ) {
		//adjust down for too many blocks at once
		if ( linkCount > 7 ) linkCount = 7;
		
		//get a random saying		
		NSString *saying = sayings[linkCount-5][(int) ( CCRANDOM_0_1() * sayingCount ) ];
		
		//get a starting location for the alert
		//this is the last place the user touched
		
		//CGPoint pos = lastTouch; //[[linkTypeBehavior owner] mainSprite].position;
		CGPoint pos = [[linkTypeBehavior owner] mainSprite].position;
		
		//adjust as needed so the position of the alert is visible and not

		
		//give some extra points
		[pointTracker addPoints:linkCount*linkCount];
		
		//trigger an alert for the level up
		[alertManager triggerAlert:saying:pos];
		
	}
	
	//testing: trigger after click here
	//[self afterClick];
	DLOG(@"HandleLinkType():done");
}


//update the alert layer reference
-(void) setAlertLayer:(BehavioralLayer *) alertLayer {
	//HACK: add the alert manager to the alert layer
	//because it allows tick method, whereas our scene does not	
	//the scene has an alert manager behavior
	//so we can easily display alerts all over the screen
	alertManager = [[[[TriggerAlert alloc] withLimit:CGRectMake(
		ALERT_SPACE_X + X_SPACE, 
		ALERT_SPACE_Y + Y_SPACE_BOTTOM, 
		screenSize.width - (ALERT_SPACE_X+X_SPACE)*2, 
		screenSize.height - (ALERT_SPACE_Y*2+Y_SPACE_BOTTOM+Y_SPACE_TOP)
		)] withFont:@"BadaBoom BB" :56 :LM_ORANGE] withZ:1];
	
	 [alertLayer addBehavior:alertManager];
	 //[self addBehavior:alertManager];
	 }

//update play menu reference
-(void) setMenu:(PlayMenu *) newMenu {
	//call parent
	[super setMenu:newMenu];
	
	//load the correct saved level here
	[self loadLevel];
	
	//are we restoring a saved board?
	bool savedBoard = (level != 1);
    
    //testing: 
    lives = 10;
	
	//for testing:
	//lives = 50; 
	//level = 55; //testing
	
	//here we could load an existing level from configuration settings	
	[menu setLevel:level];
	
	//configure level 1 since this is the first time we have a ref to the menu
	[self configureLevel:level];
	
	//get the # of bonus bombs from menu actions
	lives += [Settings useBonus];
	
	//NOW: we are the social gamer delegate
	[LGSocialGamer setSocialDelegate:self];
	
	//if our level is level 1 then no board was saved
	if ( !savedBoard) {
		//on the first level we just fill the board
		[self initializeTypes:level];	
		[self setupStatuses];
		[self fillBoard];
	} else {
		//if we are here we have obviously loaded a saved level
		//so lets pull it up on the board
		[self loadTypes:level];
		[self setupStatuses]; //sets up all statuses properly
		[self loadBoard];

		//testing:
		//[self diag];
		
		
	}
	
	//start spawning if we should
	[self startSpawning];
	
	//and start ambient sound if we should
	[self ambientEffect];
	
}

//override set status logic
-(void) setStatus:(Actor *)pointActor {
	//call parent method
	//and then reset status tracker
	[super setStatus:pointActor];
	[statusTracker resetStatus:0 :[self blockStatus:1]];
}

//clean up our mess
//we are doing it this way because dealloc doesn't get called
//when expected - probably because there are too many cross-references to objects
//all over the place
-(void) clean {
	//save our current level to memory
	[self saveLevel];
	
	//release our animations
	[teaseAnims release];
	[randAnims release];
	[animWindowClosing release];
	[animWindowOpening release];
	[animWindowBoarding release];
	
	//call parent
	[super clean];
}

//this method determines if the user can click a specific block type
- (bool) canClickBlock:(Actor *) block {
	//we can as long as we have at least one life
	//but this will use a life
	return (lives > 0 ) ;
}

//click a specific type of block
-(void) clickBlock:(Actor *) block {
	//is this a boarded up window?
	if ( [block getType] == 0 && [block getState] == 2 ) {
		//update state
		Actor *target = playboard[activeRow][activeCol];
		[target setState:0];
		
		//redraw the sprite
		//TODO: we need to show an animation of the window cracking
		//or even cooler each tap blows off one board (so 3 taps to open)
		[self updateActorSprite:target :false];
		
		//use a life and bust the board
		[self useLife];
		[self bustBoard:[target position]];
	}
}


//this is where we collect different types of blocks
-(void) collectBlock:(int)blockType {
	//for now - as long as this is type -1 (heart) - then add a life
	switch (blockType) {
		case COIN_BLOCK_TYPE:
			//this is wonderful...
			if ( soundEnabled) [[SimpleAudioEngine sharedEngine] playEffect:@"points.mp3"];
			
			//add a heart/hammer or whatever it is
			lives++;
			[menu updateLives:lives];
			
			//there is one more bomb this level
			bombsCollected++;
			
			//did we hit the bombs collected achievement this level
			if ( bombsCollected >= 3) {
				//they get this silly little achievement
				[LGSocialGamer achieve:ACHIEVE_BOMBERMAN percentComplete:100];
				
			}
			
			
			//coins++;
			break;
		case BOMB_BLOCK_TYPE:
			//clear all boards from the board
			[self bustBoards];
			break;
		default:
			break;
	}
}


/***SCENE SETTINGS***/

//get or set sound enabled
-(void) setSoundEnabled:(bool) enabled {
	//just update internal value that's it
	soundEnabled = enabled;
}

//start our music
-(void) startMusic {
	//since the intro was playing music, make sure to stop it here
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	
	//start our background music for the level
	if ( [Settings getMusicEnabled] ) {
		if (_thoughtful ) {
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"slowplay-song-128.mp3" loop:true];
			
		} else {
			[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"gameplay-song-128.mp3" loop:true];
		}
	}
}

//return the thoughtful setting
-(bool) thoughtful {
	//return our internal value
	return _thoughtful;
}

//call this method to set the game in thoughtful mode
//which is a slower easier way of playing
-(void) setThoughtful:(bool) thoughtful {
	//update the value
	_thoughtful = thoughtful;
}

//this method will write out the board in a format that can be saved in settings
//and will write it out exactly in its current state (block types, states, and timers)
-(NSString *) readBoard {
	//declarations
	NSString *results = @"";
	
	//run through all rows
	for (int r = 0; r < ROWS; r++ ) {
		//run through all] columns in this row
		for (int c = 0; c < COLS; c++ ) {
			//get this block
			Actor *block = playboard[r][c];
			
			//append this cells information
			results = [results stringByAppendingFormat:@"%i,%i",[block getType],[block getState]];
			
			//columns are seperated by pipes
			if ( c < COLS-1 ) results = [results stringByAppendingString:@"|"];
			
		}
		//rows are seperated by tilde
		if ( r < ROWS-1 ) results = [results stringByAppendingString:@"~"];
		
	}
	//return that string
	return results;
}

//this method is triggered only when a successful social action (brag/invite)
//was completed
-(void) receiveSocialBonus {
	//since we are in the game, just update lives right now
	lives++;
	[menu updateLives:lives];
	
}

//give the layer a name (more for debugging than anything else right now)
-(NSString *) name {
	return @"FranticLayer";
}

@end

