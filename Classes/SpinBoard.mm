//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces

#import "SpinBoard.h"
#import "MainMenu.h"
#import "PickConstants.h" //constants specific to the pick version of the game
#import "PlayMenu.h"
#import "Settings.h"

#define SLIDE_TOLERANCE 10
#define RECYCLE_ACTORS true

// HelloWorld implementation
@implementation SpinBoard

//helps speed up loops that count through types
//by returning the active block type (instead of max)
//should override
-(int) activeTypes {
	return _MAX_BLOCK_TYPES;
}
	

//call this function to push a position onto the stack of available (because it got removed)
-(void) pushSpot:(CGPoint) xy {
	//there is one more spot
	//update its value
	availCount++;
	activeBalls--;
}

//override this bad boy to cause sprites to hightlight in the column and row that's slideable
//by defualt we do nothing
-(void) highlightSprite:(Actor *) actor:(bool) highlighted {
}

//override this for specific logic after updated available counts
-(void) syncCounts {
	
}

//TODO: updateAvailCount is called too many times per cycle, why so many times?
//update available count
/*
-(void) updateAvailCount {
	//clear our current list of onboard counts	
	//note: using BALL_TYPES as that's the actual max # of lbocks
	//on the board for this particular level
	int maxCount = BALL_TYPES; //[self activeTypes];
	for (int c = 1; c <= maxCount; c++ ) {
		blocksOnBoard[c] = 0;
	}
	
	//since the available spot locations always
	//change, here we need to update the available spots array
	//TODO: move this somewhere more efficient (so its updated less frequently)
	int a = 0; //available spots index
	int t = 0; //taken spot index
	for (int c = 0; c < COLS; c++ ) {
		for (int r = 0; r < ROWS; r++ ) {
			//is this spot available?
			//note: it is not available if it is a blank block with a locked state
			if ( [playboard[r][c] getType] == 0 && [playboard[r][c] getState] == 0) {
				availSpots[a] = CGPointMake(c,r);
				a++;
			} else if ( [playboard[r][c] getType] > 0 ) {
				//count this spot but only if the state is not 1 (which is collecting)
				if ( [playboard[r][c] getState] != 1 ) blocksOnBoard[[playboard[r][c] getType]]++;
				
				//this is a taken spot
				activeSpots[t] = CGPointMake(c,r);
				t++;
			} else if ( [[playboard[r][c] mainSprite] color].r == 0 &&
					   [[playboard[r][c] mainSprite] color].g == 0 &&
					   [[playboard[r][c] mainSprite] color].b == 0 ) {
				//this condition should not exist
				//NSLog(@"issue");
			}
			
		}
	}	
	
	//now that we've updated our available count
	//let's sync that back with count manager (or whatever) here
	[self syncCounts];
	
	//testing:
	availCount = a;
	activeBalls = COLS*ROWS-availCount;
	
}
*/

//use this function to pop a random position off the available stack to use it
-(CGPoint) popRandomSpot {
	
	//get a random location in the available spot array
	int randLoc = CCRANDOM_0_1() * availCount;
	CGPoint results = availSpots[randLoc];
	
	//remove that spot from the array
	//and there is one fewer spot now
	for (int c = randLoc+1; c < availCount; c++ ) {
		//move this spot down once
		availSpots[c-1] = availSpots[c];
	}
	availCount-=1;	
	
	//add this new spot to the active spot list
	activeBalls++;
	activeSpots[activeBalls-1] = results;
	
	//return that spot we found
	return results;
}

-(void) updateActorSprite:(Actor *) actor : (bool) noAnim {
	//override me
}

//this method sets a sprite color based on given type
-(void) setSpriteColor:(Actor *) ball : (bool) noAnim {
	//the color of the sprite is actually based on the position in the sprite sheet
	//[[ball mainSprite] setTextureRect:[self getBallTextureRect:ball]];
	//[[ball mainSprite] setDisplayFrame:[self getBallFrame:ball]];
	
	//this is now all we need
	//it will update everything else for us
	[self updateActorSprite:ball:noAnim];
	
}

//when a new block gets spawned
//this method is called to shake things up a big
//it determines the type and state of the new block
//based on whatever variables we want (depends on game implmentation)
-(bool) determineBlockType:(Actor *) block {
	//this can be overridden
	//for now we just select a random one
	[block setType:CCRANDOM_0_1() * BALL_TYPES];
	return true;
}


//this gets the sprite texture rectangle based ont he ball TYpe
-(CGRect) getBallTextureRect:(Actor *) ball {
	//this is a placeholder
	return CGRectMake(0,0,0,0);
}

//this returns a sprite frame
-(CCSpriteFrame *) getBallFrame:(Actor *) ball {
	//override me
	return nil;
}


-(CCSprite *) createActorSprite:(Actor *)newActor:(bool) noAnim {
	//override me
	return nil;
}

//add a new sprite actor at the given coords
-(Actor *) addNewSpriteWithCoords:(CGPoint)p:(int) ballType:(int) ballState:(bool) noAnim {
	//just randomly picking one of the images
	//if ( ballType != -1) idx = ballType;	
	
	//create the new actor
	Actor *newActor = [[[Actor alloc] init:self] autorelease];
	[newActor setState:ballState];
	[newActor setTag:0];
	
	//actor stores the sprite body, type, and state	
	[newActor setType:ballType];

	//call method to create a new sprite based on an actor
	CCSprite *sprite = [self createActorSprite:newActor:noAnim];
	
	//CCSprite *sprite = [CCSprite spriteWithSpriteSheet:blockSheet rect:[self getBallTextureRect:newActor]];
	//CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[self getBallFrame:newActor]];
	
	//they should all be on the same z-order
	[blockSheet addChild:sprite]; 
	//[self setSpriteColor:newActor:noAnim];
	
	sprite.position = ccp( p.x, p.y);
	
	[newActor setMainSprite:sprite];	
	
	//add this actor to the actor array
	[actors addObject:newActor];
	
	//return the actor we created
	return newActor;
}

//add a new sprite with coords but default state
-(Actor *) addNewSpriteWithCoords:(CGPoint)p:(int) ballType : (bool) noAnim {
	return [self addNewSpriteWithCoords:p:ballType:0:noAnim];
};


//recycle an actor (don't just delete it)
-(void) recycleActor:(Actor *) actor {
	//quit if passed null - not valid for us
	if ( actor == nil ) return;	
	
	//if the recycle bin is not creatd
	//we need to do that now
	if ( actorRecycleBin == nil ) actorRecycleBin = [[CCArray alloc] init];
	
	//are we recycling actors?
	if ( RECYCLE_ACTORS ) {
		//disable the thing
		[actor setType:0];
		[actor setState:0];
		[actor setEnabled:false];
		
		//add it to our recycling array
		[actorRecycleBin addObject:actor];
	} else {
		//just remove it instead of recycling
		[self removeActor:actor];
	}
	
}

//return a recycle actor if there is one available, otherwise create a new one
-(Actor *) recycledActorWithCoords:(CGPoint)p:(int) actorType:(int) actorState:(bool) noAnim {
	//our return actor
	Actor *results;
	
	//create the recycle bin if needed
	if ( actorRecycleBin == nil ) actorRecycleBin = [[CCArray alloc] init];
	
	//do not allow an invalid combination of state/actor
	//if we are duplicting a block that happens to be "floating away" right now
	actorState = ( actorState == 1 ) ? 0 : actorState;
	
	//is there an actor to recycle?
	//but never recycle if that default is set
	if ( [actorRecycleBin count] > 0 && RECYCLE_ACTORS ) {
		//pop the last one off
		results = [[actorRecycleBin lastObject] retain];
		
		//here is another little quirk - we have this board timer
		//that decides when to slam boards shut - well if an actor
		//gets recycled the board timer should get reset
		//the timer uses the tag of the main sprite to do so.
		[[results mainSprite] setTag:0];

		//now update its state, type, and position
		//note: that if its recycled it is disabled
		[results setType:actorType];
		[results setState:actorState];
		[[results mainSprite] setPosition:p];
		[results setEnabled:true];
		
		
		//now that we updated the actor type/state
		//lets update the sprite frame so it looks correctly
		[self setSpriteColor:results :noAnim];
		
		//remove the actor from the recycle bin
		[actorRecycleBin removeLastObject:false];

	} else {
		//create a new actor since we don't already have one
		results = [self addNewSpriteWithCoords:p :actorType :actorState:noAnim];
	} 
	
	//return the actor we created or recycled
	return results;
}


//this method gets called when the game is over
//if lite is true - the game is over only because we completed all lite levels

-(void) gameOver:(bool) lite {
	//the game is over
	gamesOver = true;
	
	//TEMP: play a sound
	[[SimpleAudioEngine sharedEngine] playEffect:@"gameOver.mp3"];
	
	//stop spawning
	[self stopSpawning];
	
	//push high score if appropriate to appropriate high score list
	if ( _thoughtful ) {
		[Settings pushScore:[pointTracker getPoints]:@"thoughtfulScores"];
	} else {
		[Settings pushScore:[pointTracker getPoints]:@"franticScores"];
	}
	
	//call the game over method on the play menu
	[menu gameOver:[pointTracker getPoints]:lite];
}

//count the # of blocks that are locked on the board
-(int) lockedCount {
    return _lockedCount;
}



//this method gets called when we move up a level
-(bool) levelUp {
	//this needs to be overridden
	return false;
}

//create a bubble with a pre-defined block type
-(void) spawnCollectable:(int) blockType {
	//update available spot list and count
	//[self updateAvailCount];
    [self visitBlocks:false :false :true];
	
	//we can't do it if there are no spaces available
	if ( availCount <= 0) {
		return;
	};
	
	//get an available random spot
	//and get a random color and type for the ball
	int row,col;	
	CGPoint newSpot = [self popRandomSpot];
	row = newSpot.y;
	col = newSpot.x;	
	
	//testing?
	if ([ playboard[row][col] getType] != 0) {
		//there is a problem we are trying to spawn
		//in a position already taken
		//NSLog(@"ISSUE!");
		newSpot = [self popRandomSpot];		
		row = newSpot.y;
		col = newSpot.x;
	}
	
	//get the block reference
	Actor *block = playboard[row][col];
	
	//we set the block type and state
	[block setType:blockType];
	[block setState:3];
	
	//update sprite color
	[self setSpriteColor:block:false];
	
}

//this determines if there is a block type available (override)
-(bool) availBlockType {
	return true;
}

//this just creates random bubbles (not scheduling them)
-(void) createBubble {
	//update available spot list and count
	//[self updateAvailCount];
    //[self visitBlocks:false :false :true];
    
	//we are immediately done if no space is available
	if ( availCount <= 0) {
		//instead of game over - should call level up method
		//which will handle game over or reduce lives / etc
		//[self gameOver];
		[self levelUp];
		return;
	};
	
	//quit if there is not an available block type to spawn
	//(so we don't count the block as spawned by accident
	if ( ![self availBlockType] ) {
		return;
	}
	
	//get an available random spot
	//and get a random color and type for the ball
	int row,col;	
	CGPoint newSpot = [self popRandomSpot];
	row = newSpot.y;
	col = newSpot.x;

	//testing?
	if ([ playboard[row][col] getType] != 0) {
		//there is a problem we are trying to spawn
		//in a position already taken
		newSpot = [self popRandomSpot];		
		row = newSpot.y;
		col = newSpot.x;
	}
	
	//determine block type
	if ( ! [self determineBlockType:playboard[row][col]] ) {
		//quit - we don't want to spawn a block
		return;
	};
	
	//we should only increment block type after we are sure we are going to do it
	//update sprite color
	[self setSpriteColor:playboard[row][col]:false];
	
	
	//update row and col slider copy of ball if in a row or column slide
	if (validTouch && ( activeRow == row || activeCol == col ) ) {
		//if this is the active row
		if ( row == activeRow) {
			//find the duplicates and update them as well
			for (int c = 0; c < SLIDER_COLS; c++ ) {
				if ( [rowSlider[c] tag] == col+100 || [rowSlider[c] tag] == col+200) {
					//this is a dup, update it
					[rowSlider[c] setType:[ playboard[row][col] getType]];
					[self setSpriteColor:rowSlider[c]:true];
				}
			}
		}
		
		//if this is the active column
		if ( col == activeCol) {
			//find the duplicates and update them as well
			for (int c = 0; c < SLIDER_ROWS; c++ ) {
				if ( [colSlider[c] tag] == row+100 || [colSlider[c] tag] == row+200) {
					//this is a dup, update it
					[colSlider[c] setType:[ playboard[row][col] getType]];
					[self setSpriteColor:colSlider[c]:true];
				}
			}
		}
		
	}
	
}

-(void) fadeBlock:(Actor *) block {
	//abort if block is nil
	//it could have been killed before we got called
	if (block == nil) return;
	
	//be sure to update the sprite type (incase its a lock block image)
	//[[block mainSprite] setTextureRect:CGRectMake(0,0,COL_WIDTH,ROW_HEIGHT)];
	
	//return type and state to a blank block
	[block setType:0];
	[block setState:0];
	
	//call to update monster and window sprites
	[self updateActorSprite:block:false];
}

//this method updates types of blocks to zero
//when the state matches the one specified
/*
-(void) fadeBlocks:(int) state {
	//run through all rows
	for (int y = 0; y < ROWS; y++ ) {
		for (int x = 0; x < COLS; x++ ) {
			//is this block in our state?
			if ([playboard[y][x] getState] == state) {
				//fade this bitch to black
				[self fadeBlock:playboard[y][x]];
			}
		}
	}
}
*/

//this method updates the links on a single block in the level
-(void) updateBlockLinks:(Actor *) block:(int)x:(int)y {
    //get this actor and link behavior
    Actor *cur = block;
    TrackLinked *linked = (TrackLinked *)[cur behavesAs:[TrackLinked class]];
    
    //if no behavior exists, create one
    //and get an updated reference to it
    if (linked == nil) { 
        //initialize behaviors on the actor				
        //and reget the linked behavior from the actor now that its created
        [self blockBehaviors:cur];
        linked = (TrackLinked *)[cur behavesAs:[TrackLinked class]];
    }
    
    //set all links to null to start
    //this is important because the blocks could have shifted
    //or had a reference to a different block to the right or left
    [linked clearLinks];
    
    //setup links to each direction as we can
    if ( x > 0) [linked setLeft:playboard[y][x-1]];
    if ( y > 0 ) [linked setUp:playboard[y-1][x]];
    if ( x < COLS-1 ) [linked setRight:playboard[y][x+1]];
    if ( y < ROWS-1 ) [linked setDown:playboard[y+1][x]];

}

//this method visits all the blocks on the board
//and calls the standard set of methods on each
//so we only have a single n*n operation here
-(void) visitBlocks:(bool) shouldFade:(bool)shouldUpdateLinks:(bool)shouldUpdateCounts {
	//clear our current list of onboard counts	
	//note: using BALL_TYPES as that's the actual max # of lbocks
	//on the board for this particular level
	int maxCount = BALL_TYPES; //[self activeTypes];
    
    //recount locked count
    _lockedCount = 0;
    
    //if updating counts - setup that now
    if ( shouldUpdateCounts ) {
        for (int c = 1; c <= maxCount; c++ ) {
            blocksOnBoard[c] = 0;
        }
    }
	
	//since the available spot locations always
	//change, here we need to update the available spots array
	//TODO: move this somewhere more efficient (so its updated less frequently)
	int a = 0; //available spots index
	int t = 0; //taken spot index
    
	//run through all rows
	for (int y = 0; y < ROWS; y++ ) {
		for (int x = 0; x < COLS; x++ ) {
            /***UPDATE LOCKED COUNT***/            
            _lockedCount += ([(Actor *)playboard[y][x] getState] == 2) ? 1 : 0;            
            
            /***UPDATE BLOCK LINKS***/
            if (shouldUpdateLinks) [self updateBlockLinks:playboard[y][x] :x:y];            
            
            /***FADE BLOCKS***/
            
			//is this block in our state?
            if ( shouldFade ) {
                if ([playboard[y][x] getState] == 1) {
                    //fade this bitch to black
                    [self fadeBlock:playboard[y][x]];
                }
            }
                        
            /***UPDATE AVAIL COUNT***/
            if ( shouldUpdateCounts ) {
                //is this spot available?
                //note: it is not available if it is a blank block with a locked state
                if ( [playboard[y][x] getType] == 0 && [playboard[y][x] getState] == 0) {
                    availSpots[a] = CGPointMake(x,y);
                    a++;
                } else if ( [playboard[y][x] getType] > 0 ) {
                    //count this spot but only if the state is not 1 (which is collecting)
                    if ( [playboard[y][x] getState] != 1 ) blocksOnBoard[[playboard[y][x] getType]]++;
                    
                    //this is a taken spot
                    activeSpots[t] = CGPointMake(x,y);
                    t++;
                } else if ( [[playboard[y][x] mainSprite] color].r == 0 &&
                           [[playboard[y][x] mainSprite] color].g == 0 &&
                           [[playboard[y][x] mainSprite] color].b == 0 ) {
                    //this condition should not exist
                    //NSLog(@"issue");
                }
            }
            
		}
	}
    
    /***UPDATE AVAIL COUNT LOGIC***/
    
	//now that we've updated our available count
	//let's sync that back with count manager (or whatever) here
	[self syncCounts];
	
	//testing:
	availCount = a;
	activeBalls = COLS*ROWS-availCount;
    

}

//this stops spawning
-(void) stopSpawning {
	_spawnInterval = 0;
	[self unschedule:@selector(spawnBubble)];
}

//this method creates a single random bubble in a random available position
-(void) spawnBubble {
	//do not spawn when the game is paused
	if ( [self paused] ) return;
	
	//this cannot fire while we are in a touch began
	//or touch ended method (between them firing is fine)
	//this is a quick fix... i suppose we could do it differently
	//but this will work just fine for our needs
	//trying to get this app out
	if (inTouchBegan || inTouchEnded ) {
		//just wait a second and try again
		[self schedule:@selector(spawnBubble) interval:0.05];
		_spawnInterval = 0.05;
		return;
	}
	
	//DEBUG START OF METHOD MESSAGING
	DLOG(@"SpinBoard.spawnBubble: Start");
	
	//track the # of bubbles that have been spawned
	static int spawnedBubbles = 0;
	static int spawnCount = 0; //this is how many bubbles getting spawned at this time
	
	//one more spawned
	spawnedBubbles++;
	
	//we need to automatically unpause the layer
	//if we got here - because this needs to be scheduled
	//we don't want an error
	if ([super paused]) [super resume];
	
	//if this is the first call spawn count is zero
	if ( spawnCount == 0 ) {
		//determine a random spawn count
		//but never zero
		spawnCount = CCRANDOM_0_1() * (maxSpawn-minSpawn);
		spawnCount+= minSpawn;		
	}
	
	//we launch five in a row or whatever that # is...
	if ( spawnedBubbles <= spawnCount || massSpawnCount > 0) {
		//spawn another very quickly
		if (_spawnInterval != 0.05) {
			_spawnInterval = 0.05;
			[self schedule:@selector(spawnBubble) interval:0.05];
		}
		
		//reduce mass spawn count if needed
		if ( massSpawnCount > 0) {
			//we are closer to being done
			massSpawnCount--;
			
			//if we are in thoughtful mode we should unschedule this selector
			//because there isn't a normal spawn operation
			//we only do this after all blocks have been mass spawned
			if ( _thoughtful && massSpawnCount == 0 ) [self unschedule:@selector(spawnBubble)];			
		}
		
	} else {
		//clear spawned count
		spawnCount = 0;
		
		//we may need to collect points here
		//rather than waiting to later
		//but we do that with the click event now
		//we may also need to level up right here
		DLOG(@"SpinBoard.spawnBubble(): updateLinks");
		//[self updateLinks];
        //[self visitBlocks:false :true :false];
		
		//testing: click if in true frantic mode
		DLOG(@"SpinBoard.spawnBubble(): click");
		if ( !_thoughtful ) [self click];
        
        //fade blocks as needed where state is 1 (collectable
        //and move up to the next level
        //[self fadeBlocks];
        //[self visitBlocks:true:true:false];
        //DLOG(@"SpinBoard.spawnBubble(): levelup");		
        //[self levelUp];
        
        //visit all blocks in the level
        //this will call: fadeBLock, updateAvailCount, updateLinks all at once
		//DLOG(@"SpinBoard.spawnBubble(): visitBlocks:1");
		
		//setup the current interval if not already
		if (currentInterval == 0 ) currentInterval = SPAWN_INTERVAL_MAX;
		
		//nope... longer delay and reset spawn count
		//but delay gets shorter each time we hit this
		spawnedBubbles = 0;
		currentInterval -= SPAWN_INTERVAL_DEC;
		
		//do not let the interval go below the minimum
		if ( currentInterval < minInterval) currentInterval = minInterval;
		
		//here we unschedule the selector stopping
		//[self unschedule:@selector(spawnBubble) ];
		
		//only reschedule when the interval changes
		//and when we are not in thoughtful mode
		if ( !_thoughtful ) { 
			if ( currentInterval != _spawnInterval ) {
				//update the scheduled interval
				_spawnInterval = currentInterval;	
				[self schedule:@selector(spawnBubble) interval:currentInterval];
			}
		}
		
	}
	
    //fade blocks as needed where state is 1 (collectable
    //and move up to the next level
    //[self fadeBlocks];
    [self visitBlocks:true:true:true];
    DLOG(@"SpinBoard.spawnBubble(): levelup");		
    [self levelUp];
    
	DLOG(@"SpinBoard.spawnBubble(): createBubble");
	//now create random bubbles
	[self createBubble];
	
	//if we are in thougthful mode then unschedule the spawn
	if ( _thoughtful && massSpawnCount <= 0 ) [self unschedule:@selector(spawnBubble)];
	
	//DEBUG START OF METHOD MESSAGING
	DLOG(@"SpinBoard.spawnBubble: End");
	
}

-(void) snapRow:(int) row:(float)delay {
	//the first item is more than half-way past the first position
	//so we should actually move the last item to the beginning
	if ( [rowSlider[0] mainSprite].position.x > X_SPACE + COL_WIDTH*(0-COLS) + COL_WIDTH/2 ) {
		//now... slide all actors up one position
		//and put this actor in the first position
		Actor *last = rowSlider[SLIDER_COLS-1];
		for (int c = SLIDER_COLS-2; c >= 0 ; c-- ) {
			rowSlider[c+1] = rowSlider[c];
		}
		
		//update first item to us
		rowSlider[0] = last;
		
	}
	
	
	//slide all actors to the right or left by X spaces
	for (int c = 0; c < SLIDER_COLS; c++ ) {
		//get this actor
		Actor *bubble = rowSlider[c];
		
		//if this is a valid actor
		if ( bubble) {
			//calc new position
			CGPoint newPos = ccp(X_SPACE + COL_WIDTH*(c-COLS),[bubble mainSprite].position.y);
			
			//if delay is 0 then we should just update it
			if (delay == 0.0f ) {
				//just update position
				[bubble mainSprite].position = newPos;
			} else {
				//trigger a move action on the sprite
				[[bubble mainSprite] runAction:[CCMoveTo actionWithDuration:delay position:newPos]];
			}

			
		}
	}
	
	
	
}

-(void) snapCol:(int) col:(float) delay{
	//the first item is more than half-way past the first position
	//so we should actually move the last item to the beginning
	if ( [colSlider[0] mainSprite].position.y > Y_SPACE_BOTTOM + ROW_HEIGHT*(0-ROWS) + ROW_HEIGHT/2 ) {
		//now... slide all actors up one position
		//and put this actor in the first position
		Actor *last = colSlider[SLIDER_ROWS-1];
		for (int c = SLIDER_ROWS-2; c >= 0 ; c-- ) {
			colSlider[c+1] = colSlider[c];
		}
		
		//update first item to us
		colSlider[0] = last;
		
	}
	
	
	//slide all actors to the right or left by X spaces
	for (int c = 0; c < SLIDER_ROWS; c++ ) {
		//get this actor
		Actor *bubble = colSlider[c];
		
		//if this is a valid actor
		if ( bubble) {
			//calc new position
			CGPoint newPos = ccp([bubble mainSprite].position.x,Y_SPACE_BOTTOM + ROW_HEIGHT*(c-ROWS));
			
			//if delay is 0 then we should just update it
			if (delay == 0.0f ) {
				//just update position
				[bubble mainSprite].position = newPos;
			} else {
				//trigger a move action on the sprite
				[[bubble mainSprite] runAction:[CCMoveTo actionWithDuration:delay position:newPos]];
			}
			
			
		}
	}
	
	
	
}

//this slides a row or a column, depending on settings
//we return true if the sliding resulted in a shift of items in the array
-(int) slideRowCol:(Actor *[]) list:(int) listLen:(int)itemSize:(int) orgLen:(int)firstItemSpacer: (float) delta:(bool) vertical:(bool) allowReorder{
	//working sprite value
	CCSprite *s;
	int results = 0;
	
	//slide all actors to the right or left by X spaces
	for (int c = 0; c < listLen; c++ ) {
		//get this actor from slider row
		Actor *bubble = list[c];
		
		//if this is a valid actor
		if ( bubble) {		
			//update actors X position by delta given
			s = [bubble mainSprite];
			
			//determine new X/Y values
			[s setPosition:CGPointMake(s.position.x+((vertical)?0:delta),s.position.y+((vertical)?delta:0))];
		}
		
	}
	
	//abort right here if we are not allowing reorder
	if (!allowReorder) return 0;
	
	//did we move so far to the right (bottom)/whatever that the last item
	//needs to jump back to the beginning?
	s = [list[listLen-1] mainSprite];
	float pos = (vertical) ? s.position.y : s.position.x;
	
	if ( pos >= firstItemSpacer+(orgLen*2)*itemSize ) {
		//we are shifting up 
		results = 1;
		//yup.... update its position (x) if its valid
		//but only if this is a valid actor
		float newX = (vertical) ? s.position.x : [list[0] mainSprite].position.x-itemSize;
		float newY = (!vertical) ? s.position.y : [list[0] mainSprite].position.y-itemSize;
		if (s) [s setPosition:CGPointMake(newX,newY)];
		
		//now... slide all actors up one position
		//and put this actor in the first position
		Actor *last = list[listLen-1];
		for (int c = listLen-2; c >= 0 ; c-- ) {
			list[c+1] = list[c];
		}
		
		//update first item to us
		list[0] = last;
		
		
	} else {
		
		//did we move so far to the left that the last item
		//needs to jump to the end
		s = [list[0] mainSprite];
		pos = (vertical) ? s.position.y : s.position.x;
		if ( pos <= firstItemSpacer - orgLen*itemSize ) {
			//we are shifting down
			results = -1;		
			//yup.... update its position (x)
			float newX = (vertical) ? s.position.x : [list[listLen-1] mainSprite].position.x+itemSize;
			float newY = (!vertical) ? s.position.y : [list[listLen-1] mainSprite].position.y+itemSize;
			[s setPosition:CGPointMake(newX,newY)];
			
			//now... slide all actors up one position
			//and put this actor in the first position
			Actor *first = list[0];
			for (int c = 1; c < listLen ; c++ ) {
				list[c-1] = list[c];
			}
			
			//update first item to us
			list[listLen-1] = first;
			
			
		}
	}
	
	//return results either we shifted or we did not
	return results;
	
}

//this slides a row or a column, depending on settings
//we return true if the sliding resulted in a shift of items in the array
//this only gets called when the balls are roughly in place

-(void) resetRowCol:(Actor *[]) list:(int) listLen:(int)itemSize:(int) orgLen:(int)firstItemSpacer: (float) pos:(bool) vertical{
	//working sprite value
	CCSprite *s;
	
	//move all actors to the specified position
	for (int c = 0; c < listLen; c++ ) {
		//get this actor from slider row
		Actor *bubble = list[c];
		
		//if this is a valid actor
		if ( bubble) {		
			//update actors X position by delta given
			s = [bubble mainSprite];
			
			//determine new X/Y values
			float newX = (vertical) ? s.position.x : firstItemSpacer + (orgLen - c) * itemSize;
			float newY = (!vertical) ? s.position.y : firstItemSpacer + (orgLen - c) * itemSize;
			[s setPosition:CGPointMake(newX,newY)];
		}
		
	}
	
}

//this function adds behaviors to the given actor and returns the actor
-(void) blockBehaviors:(Actor *) actor {
	//return actor;
}

//match behaviores between two actors
-(void) syncBehaviors:(Actor *) actor : (Actor *) clone {
}

//update links
/*
-(void) updateLinks {
	//this logic updates all linked blocks (left/up/right/down/etc0
	//run back through and link all the actors together properly
	for (int y = 0; y < ROWS; y++ ) {
		for (int x = 0; x < COLS; x++ ) {
			//get this actor and link behavior
			Actor *cur = playboard[y][x];
			TrackLinked *linked = (TrackLinked *)[cur behavesAs:[TrackLinked class]];
			
			//if no behavior exists, create one
			//and get an updated reference to it
			if (linked == nil) { 
				//initialize behaviors on the actor				
				//and reget the linked behavior from the actor now that its created
				[self blockBehaviors:cur];
				linked = (TrackLinked *)[cur behavesAs:[TrackLinked class]];
			}
			
			//set all links to null to start
			//this is important because the blocks could have shifted
			//or had a reference to a different block to the right or left
			[linked clearLinks];
			
			//setup links to each direction as we can
			if ( x > 0) [linked setLeft:playboard[y][x-1]];
			if ( y > 0 ) [linked setUp:playboard[y-1][x]];
			if ( x < COLS-1 ) [linked setRight:playboard[y][x+1]];
			if ( y < ROWS-1 ) [linked setDown:playboard[y+1][x]];
			
			
		}
		
	}	
}
*/


//this clears collectables from the board
-(void) clearCollectables {
	//run through all rows
	for (int r = 0; r < ROWS; r++ ) {
		for (int c = 0; c < COLS; c++ ) {
			//get this block reference
			Actor *block = playboard[r][c];
			
			//if this is a collectable block
			if ( [block getState] == COLLECTABLE_BLOCK ) {
				//transition back to a normal block
				[block setState:1];
				[block  setType:0];
				[self setSpriteColor:block  :false];				
			}
		}
	}
}

//collects a block and lets the rest of the system know what we collected (the block type - means something)
-(void) collectBlock:(int) blockType {
}


/***TOUCH EVENTS***/

- (void) onTouchBegan:(CGPoint) location {
	//do nothing if game over
	if (gamesOver) return;
	
	//we are in a touch began
	inTouchBegan = true;
	
	//we are touching
	touching = true;
	
	//assume this is not a valid touch
	validTouch = false;
	
	//abort if not a valid position
	if ( location.y >= screenSize.height - Y_SPACE_TOP ) return;
	if ( location.y < Y_SPACE_BOTTOM - ROW_HEIGHT/2 ) return;
	if ( location.x < X_SPACE - COL_WIDTH/2 ) return;
	if ( location.x > screenSize.width - X_SPACE + COL_WIDTH/2) return;
	
	//to start neither axis is locked
	rowLocked = false;
	colLocked = false;
	
	//this is a valid touch
	//store its values
	activeRow = (location.y - Y_SPACE_BOTTOM + ROW_HEIGHT/2) / ROW_HEIGHT; //calculate active row bsaed on Y position
	activeCol = (location.x - (X_SPACE-COL_WIDTH/2) ) / COL_WIDTH; //calculate active col based on teh X position
	startTouch = location; //first touch is the first
	lastTouch = startTouch; //first touch is also last touch
	
	//store start row/col for future use
	startRow = activeRow;
	startCol = activeCol;	
	
	//there is a special case for certain block states
	//which instead of sliding the row collect what's in them when touched
	if ( [playboard[activeRow][activeCol] getState] == COLLECTABLE_BLOCK ) {
		//save the type
		Actor *collectableBlock = playboard[activeRow][activeCol];
		int type = [collectableBlock  getType];
		
		//transition back to a normal block
		[collectableBlock setState:1];
		//[collectableBlock  setState:0];
		[collectableBlock  setType:0];
		[self setSpriteColor:collectableBlock  :false];
		
		//trigger block collection routine with type - this will update whatever is appropriate
		//NSLog(@"Touched Block at %i,%i",activeCol,activeRow);
		[self collectBlock:type];
		
	}
	
	//if the user touched and stopped touching but didn't slide
	//we are calling that a touch - in which case we can break boarded windows


	
	//if we got this far we are in a "valid touch" scenario, which is different from collecting a block
	//in this state we can slide a row/col
	validTouch = true;
	
	//triplicate the col....
	//testing - shift colors
	for (int c = 0; c < ROWS; c++ ) {
		//reference this actor
		Actor *real = playboard[c][activeCol];
		
		//IMPORTANT: prevent the column from sliding
		//if this actor happens to be a lock
		if ([real getState] == 2) {
			rowLocked = true;
		}
		
		//determine location of duplicate 1
		float posX = [real mainSprite].position.x;
		float posY = [real mainSprite].position.y - ROWS*ROW_HEIGHT;
		
		//first copy is duplicates
		//NOTE: we are using the recycle method here to reuse our actors where we can
		Actor *dup1 = [self recycledActorWithCoords:CGPointMake(posX, posY) :[real getType]:[real getState]:true];
		[dup1 setType:[real getType]];
		[dup1 setTag:100+c]; //duplicate 1 (100) of #c 
		colSlider[c] = dup1;		
		
		//second copy is real (lines up with what's on screen)
		colSlider[ROWS+c] = playboard[c][activeCol];
		
		//third copy is also a duplicate
		posX = [real mainSprite].position.x;
		posY = [real mainSprite].position.y + ROWS*ROW_HEIGHT;
		
		Actor *dup2 = [self recycledActorWithCoords:CGPointMake(posX, posY) :[real getType]:[real getState]:true];
		[dup2 setType:[real getType]];
		[dup2 setTag:200+c]; //duplicate 2 (200) of #c 
		colSlider[ROWS*2+c] = dup2;
		
		
		//add same beahviors on these blocks
		[self blockBehaviors:dup1];
		[self blockBehaviors:dup2];
		
		//set their states
		[dup1 setState:[real getState]];
		[dup2 setState:[real getState]];
		
		//match settings in the behaviors as needed
		[self syncBehaviors:real:dup1];
		[self syncBehaviors:real:dup2];
		
		//testing: shade these blocks differently
		//so the user knows they can slide them
		[self highlightSprite:real:true];
		[self highlightSprite:dup1:true];
		[self highlightSprite:dup2:true];
	}		
	
	//triplicate the row....
	//testing - shift colors
	for (int c = 0; c < COLS; c++ ) {
		//reference this actor
		Actor *real = playboard[activeRow][c];
		
		//IMPORTANT: prevent the column from sliding
		//if this actor happens to be a lock
		if ([real getState] == 2) {
			colLocked = true;
		}
		
		//first copy is duplicates
		Actor *dup1 = [self recycledActorWithCoords:CGPointMake([real mainSprite].position.x-COLS*COL_WIDTH, [real mainSprite].position.y) :[real getType]:[real getState]:true];
		[dup1 setType:[real getType]];		
		[dup1 setTag:100+c]; //duplicate 1 (100) of #c 
		rowSlider[c] = dup1;
		
		
		//second copy is real (lines up with what's on screen)
		rowSlider[COLS+c] = playboard[activeRow][c];
		
		//third copy is also a duplicate
		Actor *dup2 = [self recycledActorWithCoords:CGPointMake([real mainSprite].position.x+COLS*COL_WIDTH, [real mainSprite].position.y) :[real getType]:[real getState]:true];
		[dup2 setType:[real getType]];		
		[dup2 setTag:200+c]; //duplicate 2 (200) of #c 
		rowSlider[COLS*2+c] = dup2;
		
		
		//add same beahviors on these blocks
		[self blockBehaviors:dup1];
		[self blockBehaviors:dup2];
		
		//set their states
		[dup1 setState:[real getState]];
		[dup2 setState:[real getState]];
		
		//match settings in the behaviors as needed
		[self syncBehaviors:real:dup1];
		[self syncBehaviors:real:dup2];
		
		//testing: shade these blocks differently
		//so the user knows they can slide them
		[self highlightSprite:real:true];
		[self highlightSprite:dup1:true];
		[self highlightSprite:dup2:true];
		
	}	
	
	//testing - no longer "lock" blocks
	//they just won't spawn mosnters any longer
	rowLocked = false;
	colLocked = false;
	
	//we are no longer in a touch began
	inTouchBegan = false;
}

//this method determines if the user can click a specific block type
-(bool) canClickBlock: (Actor *) block {
	//assume we can't unless overridden
	return false;
}

//handle clicking the specific type of block
-(void) clickBlock:(Actor *) block {
}

- (void) onTouchEnded:(CGPoint) location {	
	//did the touch result in a move
	bool userMoved = true;
	
	//local declarations
	const float snapDelay = 0.0f;
	
	//do nothing if game over
	if (gamesOver) return;
	
	//we are no longer touching
	touching = false;
	
	//abort if not a valid touch
	if (!validTouch) return;
	
	//we are in a touch ended
	inTouchEnded = true;
	
	//this is a move
	userMoves++;
	
	//if the first touch and last touch are in the same place
	//then the user tapped the board and if this is a boarded window
	//we need to break it and show the user
	if ( abs(location.x - startTouch.x) < COL_WIDTH/2 && abs(location.y - startTouch.y) < COL_WIDTH/2 ) {
		//user did not move - don't count this one (don't "click")
		userMoved = false;
		
		//here we should recalculate the correct column and row our touch is on
		//the window is empty and boarded
		if ( [playboard[activeRow][activeCol] getState] == 2 && [playboard[activeRow][activeCol] getType] == 0 ) {
			//can we even collect this type of block?
			if ( [self canClickBlock:playboard[activeRow][activeCol]] ) {
				//click the block
				[self clickBlock:playboard[activeRow][activeCol]];		
			}
		}
		
	}
	
	
	//if neither are locked, slide both back
	if (!rowLocked && !colLocked) {
		//snap both row and col
		[self snapCol:activeCol:0.0f];
		[self snapRow:activeRow:0.0f];
		
	}
	
	//if row is locked, snap row in place
	if ( rowLocked) {
		//snap the row into the position
		[self snapRow:activeRow:snapDelay];
		
		//update board
		//we don't know which are which... update references and kill off the old ones
		for (int c =0; c < COLS; c++ ) {
			//update this items reference to the rowSlider in the middle (visisble one)
			playboard[activeRow][c] = rowSlider[c+COLS];
			
			//clear the tag			
			[playboard[activeRow][c] setTag:0];
		}
		
		
	}
	
	//if row is locked, snap row in place
	if ( colLocked) {
		//snap the col into the position
		[self snapCol:activeCol:snapDelay];
		
		//kill all extra col slider references
		//we don't know which are which... update references and kill off the old ones
		for (uint r =0; r < ROWS; r++ ) {
			//update this items reference to the rowSlider in the middle (visisble one)
			playboard[r][activeCol] = colSlider[r+ROWS];
			
			//clear the tag back to normal
			[playboard[r][activeCol] setTag:0];
		}
		
	}
	
	//we don't know which are which... update references and kill off the old ones
	for (int c =0; c < COLS; c++ ) {
		//before killing lets unlink this actor from the other actors
		//so its track linked behavior doesn't trigger a bogus collection
		[(TrackLinked *)[rowSlider[c] behavesAs:[TrackLinked class]] clearLinks];
		[(TrackLinked *)[rowSlider[c+COLS*2] behavesAs:[TrackLinked class]] clearLinks];
		
		//give a slight delay here so the player does not see any black when the column or row snaps
		if ( rowLocked ) {
			//NOTE: we know that removeActor won't bomb even if passed a NULL
			//reference so we take advantage of that here
			//free reference to the left copy and right copy at these corresponding positions
			//NOTE: using recycling here
			[self performSelector:@selector(recycleActor:) withObject:rowSlider[c] afterDelay:snapDelay];
			[self performSelector:@selector(recycleActor:) withObject:rowSlider[c+COLS*2] afterDelay:snapDelay];
		} else {
			//NOTE: we know that removeActor won't bomb even if passed a NULL
			//reference so we take advantage of that here
			//free reference to the left copy and right copy at these corresponding positions
			//NOTE: using recycling here
			[self recycleActor:rowSlider[c]];
			[self recycleActor:rowSlider[c+COLS*2]];
		}
		
		//now the one that's left needs to become unhighlighted
		[self highlightSprite:rowSlider[c+COLS] :false];		
	}
	
	//kill all extra col slider references
	//we don't know which are which... update references and kill off the old ones
	for (int r =0; r < ROWS; r++ ) {
		//before killing lets unlink this actor from the other actors
		//so its track linked behavior doesn't trigger a bogus collection
		[(TrackLinked *)[colSlider[r] behavesAs:[TrackLinked class]] clearLinks];
		[(TrackLinked *)[colSlider[r+ROWS*2] behavesAs:[TrackLinked class]] clearLinks];
		
		//NOTE: we know that removeActor won't bomb even if passed a NULL
		//reference so we take advantage of that here
		//free reference to the left copy and right copy at these corresponding positions
		//give a slight delay here so the player does not see any black when the column or row snaps
		if ( colLocked ) {
			//NOTE: we know that removeActor won't bomb even if passed a NULL
			//reference so we take advantage of that here
			//free reference to the left copy and right copy at these corresponding positions
			[self performSelector:@selector(recycleActor:) withObject:colSlider[r] afterDelay:snapDelay];
			[self performSelector:@selector(recycleActor:) withObject:colSlider[r+ROWS*2] afterDelay:snapDelay];
		} else {
			//remove these items immediately
			[self recycleActor:colSlider[r]];
			[self recycleActor:colSlider[r+ROWS*2]];
		}
		
		//now the one that's left needs to become unhighlighted
		[self highlightSprite:colSlider[r+ROWS] :false];
	}
    
    
	//update links
	//[self updateLinks];
    [self visitBlocks:false :true :false];
	
	//collect points from move
	//trigger a click on the actor at that location
	
	//in frantic mode we click every time
	//but in thoughtful mode we only click when the user actually
	//moves - thus preventing a "touch" from counting against us
	//this also means if you change your mind you can put back a move
	if ( !_thoughtful || userMoved ) [self click];
	
	//fade blocks as needed where state is 1 (collectable)
	//[self fadeBlocks:1];
    [self visitBlocks:true :false :false];
	
	//this touch is now the last touch
	lastTouch = location;
	
	//update available count
	//[self updateAvailCount];
	
	//level up as needed
	[self levelUp];
	
	//no longer touching
	validTouch = false;
	
	//we are no longer in a touch ended
	inTouchEnded = false;
	
	//cleanup actors here
	//we are only doing this because we overrode the touch end event
	[super killActors];
	[super killBehaviors];
	
}

//this gets called from the menu when the user advances the level
-(void) advanceLevel {
}
	
//set reference to play menu
-(void) setMenu:(PlayMenu *) playMenu {
	//update internal reference
	menu = playMenu;
}

- (void) onTouchMoved:(CGPoint) location {
	//do nothing if game over
	if (gamesOver) return;
	
	//abort if not a valid touch
	if (!validTouch) return;
	
	//in this case we are within the margin of error
	//and we should allow both axis to move back and forth
	if ( !colLocked && !rowLocked ) {
		//don't start sliding until they pass the margin of error
		
		[self slideRowCol:colSlider:SLIDER_ROWS:ROW_HEIGHT:ROWS:Y_SPACE_BOTTOM:(location.y - lastTouch.y):true:false];
		[self slideRowCol:rowSlider:SLIDER_COLS:COL_WIDTH:COLS:X_SPACE:(location.x - lastTouch.x):false:false];
	}
	
	//lock row and reset column if needed
	if ( abs(location.x - startTouch.x) > SLIDE_TOLERANCE && !rowLocked && !colLocked) {
		rowLocked = true; //the row is now locked in slide mode
		[self slideRowCol:colSlider:SLIDER_ROWS:ROW_HEIGHT:ROWS:Y_SPACE_BOTTOM:(startTouch.y - location.y):true:false]; //adjust the column back 
		
		//unhighlight the other direction
		for (int c = 0; c < SLIDER_ROWS; c++ ) {
			if ( c != activeRow + ROWS ) {
				[self highlightSprite:colSlider[c]:false];
			}
		}		
			 
	}
	
	//lock column and reset row if needed
	if ( abs(location.y - startTouch.y) > SLIDE_TOLERANCE && !colLocked && !rowLocked) {
		colLocked = true; //the row is now locked in slide mode
		[self slideRowCol:rowSlider:SLIDER_COLS:COL_WIDTH:COLS:X_SPACE:(startTouch.x - location.x):false:false];
		
		//unhighlight the other direction
		for (int c = 0; c < SLIDER_COLS; c++ ) {
			//do not chnage the active center of row/col
			if (c != activeCol+COLS ) {
				[self highlightSprite:rowSlider[c]:false];
			}
		}
	}
	
	//if the row is locked, we only move it
	if ( rowLocked && !colLocked) { 
		[self slideRowCol:rowSlider:SLIDER_COLS:COL_WIDTH:COLS:X_SPACE:(location.x - lastTouch.x):false:true];
	}
	
	//if the column is locked we only move it
	if (colLocked && !rowLocked) {
		[self slideRowCol:colSlider:SLIDER_ROWS:ROW_HEIGHT:ROWS:Y_SPACE_BOTTOM:(location.y - lastTouch.y):true:true]; //adjust the column back 
	}
	
	//update available spot list and count
	//because their locations may have changed while sliding
	//TESTING 6-31-11 - Removed This (n*n) operation on move, too slow
	//[self updateAvailCount];
	
	//update touch reference
	lastTouch = location;	
	
}


/***SCENE SETTINGS***/

//defines our screen orientation for this scene
-(ccDeviceOrientation) sceneOrientation {
	return kCCDeviceOrientationPortrait;
}

//in this scene we handle all touching here
//instead of in the individual actors
//this gives us better control of what is happening
-(bool) enableActorTouch {
	return false;
}

//we also disable the tick method
//since we don't use it and this will make
//everything run faster
-(bool) enableTick {
	return false;
}


//get and set the points actor reference
-(void) setStatus:(Actor *) statusActor {
	//set a refernece tot he point actor which we will use later
	status = statusActor;
	statusTracker = (StatusBar *)[status behavesAs:[StatusBar class]];
	
}

//get and set the points actor reference
-(void) setPoints:(Actor *) pointActor {
	//set a refernece tot he point actor which we will use later
	points = pointActor;
	pointTracker = (TrackPoints *)[points behavesAs:[TrackPoints class]];
	
	//update all blocks to point to this actor
	//start by creating all the actors (but black)
	//then we will randomly turn some of them colored
	for (int y = 0; y < ROWS; y++ ) {
		for (int x = 0; x < COLS; x++ ) {
			//update tracker for this autopoint behavior			
			Actor *bubble = playboard[y][x];
			AutoPoint *p = (AutoPoint *)[bubble behavesAs:[AutoPoint class]];
			[p withTracker:pointActor];
		}
	}
	
	
}

//update links
-(void) printBoard {
	//this logic updates all linked blocks (left/up/right/down/etc0
	//run back through and link all the actors together properly
	NSString *rowString = @"test";
	NSLog(@"******PRINTED BOARD******");
	for (int y = 0; y < ROWS; y++ ) {
		rowString = @"";
		for (int x = 0; x < COLS; x++ ) {
			rowString = [rowString stringByAppendingFormat:@"[%i]",[playboard[y][x] getType]];
			
		}
		NSLog(@"row(%i):%@",y,rowString);
	}	
}

//reset counters for spawning etc
-(void) resetCounters:(float) StartInterval:(float) MinInterval:(int)MinSpawn:(int)MaxSpawn {
	//return everyting to its intial state
	currentInterval = StartInterval;
	minInterval = MinInterval;
	minSpawn = MinSpawn;
	maxSpawn = MaxSpawn;
	
}

//are we presently in a mass spawn situation?
//we are if the mass spawn count is set
-(bool) massSpawning {
	return (massSpawnCount > 0);
}

//set the mass spawn count
-(void) triggerMassSpawn:(int) spawnCount {
	//update mass spawn count
	massSpawnCount = spawnCount;
	
	//make sure bubble spawning starts immediately (instead of waiting)
	[self spawnBubble];
}

//trigger a mass spawn with the default spawn amount
-(void) triggerMassSpawn {
	[self triggerMassSpawn:MASS_SPAWN_COUNT];
}




//clean up our mess
//we are doing it this way because dealloc doesn't get called
//when expected - probably because there are too many cross-references to objects
//all over the place
-(void) clean {
	//free our recycled actior array
	[actorRecycleBin removeAllObjects];
	[actorRecycleBin release];
	
	//clean up parent
	[super clean];
}


//testing:
-(int) checkTeaseAnims{
	return 0;
}

@end

