//
//  CountManager.mm
//  LostMonsters
//
//	this class manages the different counts for all the blocks onscreen
//
//  Created by Jeff Cates on 4/8/11.
//  Copyright 2011 leftygames. All rights reserved.
//


#import "CountManager.h"

//since we don't import coco (we don't need it)
//i added this macro here - only thing we were using
//i renamed it for our purpose
//note: this is scoped within this file only

#define RANDOM_0_1() ((random() / (float)0x7fffffff ))

//this is the # of blocks visible on the bottom
//of the board at any given time - also the #
//of blocks that can be in play at any given time
#define MAX_BLOCKS_ON_BOARD 4


@implementation CountManager

//***HELPER FUNCTIONS***//


//this locates an item in one of our arrays
-(int) locateType:(int[]) a:(int) cnt : (int) data {
	int idx = -1;
	for (int c = 0; c < cnt; c++ ) {
		if ( a[c] == data ) {
			idx = c;
			break;
		}
	}
	return idx;
}

//simple function to remove an item from one of our arrays
-(void) removeItem:(int[]) a:(int) index:(int) cnt {
	//there are no more available of this type
	for (int c = index; c < cnt - 1;c ++ ) {
		//slide this guy down
		
		a[c] = a[c+1];
	}
	//there is one fewer available type
	a[cnt-1] = 0;
	
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

//***SERIALIZE TO AND FROM STRINGS***//


//these methods return a string for each of the arrays
-(NSString *) deployedToString {return [self arrayToString:blocksDeployed:MAX_BLOCK_TYPES+1];}
-(NSString *) collectedToString {return [self arrayToString:blocksCollected:MAX_BLOCK_TYPES+1];}
-(NSString *) maxToString {return [self arrayToString:maxBlocks:MAX_BLOCK_TYPES+1];}
-(NSString *) onboardToString {return [self arrayToString:blocksOnBoard:MAX_BLOCK_TYPES+1];}

//return type arrays
-(NSString *) pausedToString {return [self arrayToString:pausedTypes:MAX_BLOCK_TYPES];}
-(NSString *) waitingToString {return [self arrayToString:waitingTypes:MAX_BLOCK_TYPES];}
-(NSString *) availToString {return [self arrayToString:availTypes:MAX_BLOCK_TYPES];}

//these methods load each of the arrays from a string
-(void) deployedFromString:(NSString *) stringValue {[self arrayFromString:blocksDeployed:stringValue];}
-(void) collectedFromString:(NSString *) stringValue {[self arrayFromString:blocksCollected:stringValue];}
-(void) onboardFromString:(NSString *) stringValue {[self arrayFromString:blocksOnBoard:stringValue];}

//update type arrays
-(void) maxFromString:(NSString *) stringValue:(int) maxCount {
	[self arrayFromString:maxBlocks:stringValue];
	maxTypeCount = maxCount;
}
-(void) pausedFromString:(NSString *) stringValue:(int) pausedCount {
	[self arrayFromString:pausedTypes:stringValue];
	pausedTypeCount = pausedCount;
}
-(void) waitingFromString:(NSString *) stringValue:(int) waitingCount {
	[self arrayFromString:waitingTypes:stringValue];
	waitingTypeCount = waitingCount;
}
-(void) availFromString:(NSString *) stringValue:(int) availCount {
	[self arrayFromString:availTypes:stringValue];
	availTypeCount = availCount;
}

//***RETURN A GIVEN TYPE***//

//return a type given its index in an array
-(int) availType:(int) index { return availTypes[index];}
-(int) pausedType:(int) index { return pausedTypes[index];}
-(int) waitingType:(int) index { return waitingTypes[index];}

//***HOW MANY OF A GIVEN BLOCK TYPE ARE AVAILABLE***//

//return type counts
-(int) avail { return availTypeCount;} 
-(int) waiting { return waitingTypeCount;}
-(int) paused {return pausedTypeCount;}
-(int) max { return maxTypeCount;}


-(int) deployed:(int) blockType {
	return blocksDeployed[blockType];
}
-(int) collected:(int) blockType {
	return blocksCollected[blockType];
}
-(int) max:(int) blockType {
	return maxBlocks[blockType];
}
-(int) onBoard:(int) blockType {
	return blocksDeployed[blockType] - blocksCollected[blockType];
	//return blocksOnBoard[blockType];
	//return blocksDeployed[blockType] - blocksCollected[blockType];
	//return blocksOnBoard[blockType];
}

//get onboard for all types
-(int) onBoard {
	int boardCount = 0;
	for (int c = 1; c < maxTypeCount+1; c++ ) {
		boardCount += [self onBoard:c];
	}
	return boardCount;
}

//is the particular type done?
-(bool) done:(int) blockType {
	//the block is done when all have been collected
	return blocksCollected[blockType] >= blocksDeployed[blockType] && blocksCollected[blockType] >= maxBlocks[blockType];
}

//***COUNT MANAGEMENT METHODS***//

//this moves a waiting type to available type array
-(void) popWaitingType {
	//TODO: check that avail type count is correct
	//if there are any block types that were waiting
	//they now are not waiting
	//when we remove from available type count
	//we should also add a new type from the waiting types
	//if there is one available
	if ( waitingTypeCount > 0 && availTypeCount < MAX_BLOCKS_ON_BOARD) {
		//testing:
		//NSLog(@"****Popping Type****");
		//NSLog(@"Avail: %i, Waiting: %i, Max: %i",availTypeCount, waitingTypeCount, maxTypeCount);
		
		
		//add the first item from waiting to the end of available
		availTypeCount++;
		availTypes[availTypeCount-1] = waitingTypes[0];
		
		//remove the first item from waiting		
		[self removeItem:waitingTypes:0:waitingTypeCount];
		waitingTypeCount--;
		waitingTypes[waitingTypeCount] = 0; //we don't have to - this just helps me know we are done here
	}
	
}

//sync a type count with the correct onboard count
//because sometimes it gets off
-(void) syncWithBoard:(int) blockType:(int) onBoard {
	return;
	//is the amount on the board not what we think?
	if ( [self onBoard:blockType] != onBoard ) {
		//adjust deployed count to match expected value
		blocksOnBoard[blockType] = onBoard;
	}
	//fix the block count
	//[self fix:blockType];
}

//adjust a block type - increasing max count
//to accomidate an odd # of blocks by the user
-(void) adjust:(int) blockType {
	//if the remaining count plus what's on the board is less than 4
	//then we have a problem and need to adjust the max count to allow for more blocks
	//do not spawn when there are no blocks on the board
	if ( [self max:blockType] - [self deployed:blockType] < 4 ) {
		//test: adjust down not up
		maxBlocks[blockType] = blocksDeployed[blockType];
		
		//make sure the block is not paused because we just adjusted the max count
		//reactivating it
		//[self unpauseType:blockType];

	}
	
}

//this fixes the block type counts based on the onboard types (little different than adjusting)
//basically here the onboard type is taken into account and max is adjusted accordingly
-(void) fix:(int) blockType {
	//doesn't seem to be working:
	return;
	
	//if the remaining count plus what's on the board is less than 4
	//then we have a problem and need to adjust the max count to allow for more blocks
	//do not spawn when there are no blocks on the board
	if ( [self max:blockType] - [self deployed:blockType] + [self onBoard:blockType] < 4 && [self onBoard:blockType] > 0) {
		//there is an adjustment to be made		
		int adjustment = 4 - ([self max:blockType] - [self deployed:blockType] + [self onBoard:blockType]);
		//NSLog(@"blockType: %i - max=%i, deployed=%i, onboard=%i",blockType,maxBlocks[blockType],blocksDeployed[blockType],[self onBoard:blockType]);
		//NSLog(@"adjusting %i from %i to %i",blockType,maxBlocks[blockType],maxBlocks[blockType] + adjustment);
		maxBlocks[blockType] += adjustment;
		
		//test: adjust down not up
		//maxBlocks[blockType] = blocksDeployed[blockType];
		
		//make sure the block is not paused because we just adjusted the max count
		//reactivating it
		[self unpauseType:blockType];
		
	}
	
}

//adjust a blocks availability
//this happens as part of deploying
//NOTE: this is internal user of us doesn't need to be aware
-(void) updateAvailability:(int) ballType {
	//locate the type in the available array
	int typeIDX = [self locateType:availTypes :availTypeCount :ballType];
	
	//quit if its not even there
	if ( typeIDX == -1 ) return;
	
	
	//if we have deployed all the blocks of this type
	if ( [self deployed:ballType] >= [self max:ballType]) {
		//get the # of blocks on the board
		int onBoard = [self onBoard:ballType];
		
		//when blocks on board is more than 4 but all deployed
		//then pause the spawning - user may collect all blocks on board at once
		if ( onBoard >= 4 ) {
			[self pauseType:ballType];
			
		} else if ( onBoard == 0 ) {
			//when there are no longer any blocks on board			
			//definately can remove from available array
			//but there is no need to pause
			[self removeItem:availTypes :typeIDX :availTypeCount];
			availTypeCount--;
			
			
		} else {
			//there are fewer than 4 blocks on the board so
			//we need to adjust the # of blocks available to compensate
			[self adjust:ballType];
		}
	}		
	
}

//this method is called when collecting or undeploying a block
//it is very similar to updateAvailablity but works with paused types
-(void) updatePausedState:(int) ballType {
	//first find the block type
	int typeIDX = [self locateType:pausedTypes :pausedTypeCount :ballType];
	
	//quit if not found
	if (typeIDX == -1 ) return;
	
		
	//are we at the limit for this block?
	//if so we should be doing something
	if ( [self deployed:ballType] >= [self max:ballType]) {
		//get # of blocks on board now
		int onBoard = [self onBoard:ballType];
		
		//if we were paused but now there are fewer than 4 blocks
		//on the board, we need to unpause again so that we can finish collecting
		//the blocks
		if ( onBoard < 4 && onBoard > 0 ) {
			//unpause the block
			[self unpauseType:ballType];
			
			//adjust the # of blocks for this type (in case user collected an odd #)
			[self adjust:ballType];
			
			//there are now more blocks of this type
			//maxBlocks[ballType] += 4 - onBoard;
			
		} else if ( onBoard == 0  ) {
			//if there are zero blocks on the board we can remove the type completely
			//even though its paused - it has been captured completely by the user
			[self removeItem:pausedTypes :typeIDX :pausedTypeCount];
			pausedTypeCount--;
			
		}
	}	
}

//deploy a block - add to deployed count
-(void) deployType:(int) blockType {
	//there is one more block deployed of this type
	blocksDeployed[blockType]++;
	
	//now that we deployed a block we may want to adjust its availablity
	//we only call update availablity here because we know the block is not paused
	//since it was just deployed
	[self updateAvailability:blockType];
}

//undeploy a block - remove from deployed count
//this is what happens when a window boards up
-(void) undeployType:(int) blockType {
	//i think this is where the problem is at - when a block
	//gets boarded but its paused
	
	//write out the before information
	//is the block paused?
	int pausedIDX = [self locateType:pausedTypes :pausedTypeCount :blockType];
	//NSLog(@"TYPE[%i], COL(%i) + DEP(%i) =  MAX=%i, Paused=%i",blockType,blocksCollected[blockType],blocksDeployed[blockType],maxBlocks[blockType],pausedIDX);
	
	//break if block is paused - it hink that is the scenario
	if ( pausedIDX >= 0 ) {
		//NSLog(@"TYPE[%i] - Paused Type",blockType);
		//if we were paused we should not be anymore
		//because there is one fewer blocks
		//why would we be paused?
		[self unpauseType:blockType];
		
	}
	
	
	//there is one less block deployed of this type
	blocksDeployed[blockType]--;
	
	//if undeploying then the block won't enter a paused state
	//but it might go from paused to available
	//[self updatePausedState:blockType];
	
	
	//write out the before information
	//is the block paused?
	//pausedIDX = [self locateType:pausedTypes :pausedTypeCount :blockType];
	//NSLog(@"TYPE[%i], COL(%i) + DEP(%i) =  MAX=%i, Paused=%i",blockType,blocksCollected[blockType],blocksDeployed[blockType],maxBlocks[blockType],pausedIDX);
	
}

//collect a block - move from deployed to collected state
-(void) collectBlock:(int) blockType {
	//update collected count
	blocksCollected[blockType]++;
	
	//we might need to pause the block (from available to paused)
	[self updateAvailability:blockType];
	
	//or we might need to unpause the block (from paused to available)
	[self updatePausedState:blockType];	
	
}

//collect multiple # of blocks at once (this could be bad)
-(void) collectBlocks:(int) blockType:(int) blockCount {
	//update the # of collected blocks on the board
	blocksCollected[blockType]+= blockCount;
	
	//we might need to pause the block (from available to paused)
	[self updateAvailability:blockType];
	
	//or we might need to unpause the block (from paused to available)
	[self updatePausedState:blockType];	
	
}

//reset a type (there are none collected or deployed)
//this should only be called at the start of a level
-(void) resetType:(int) blockType:(int) blockCount {
	blocksDeployed[blockType] = 0;
	blocksCollected[blockType] = 0;
	blocksOnBoard[blockType] = 0;
	maxBlocks[blockType] = blockCount;
}

//reset the # of block types etc
-(void) reset:(int) blockTypes {
	maxTypeCount = blockTypes;
}


//get a random type from our availabile type array
-(int) randomType {
	int availTypeIDX = RANDOM_0_1() * [self avail];
	int ballType = availTypes[availTypeIDX];
	return ballType;
}

/***PAUSING AND UNPAUSING LOGIC***/

//this handles "pausing" a type - moving from available to paused array
-(void) pauseType:(int) ballType {
	//get the location of the block in the available array
	int ballLoc = [self locateType:availTypes:availTypeCount:ballType];
	
	//only tro to pause if the block is currently available
	if (ballLoc >= 0) {
		//move to pause array b/c we may need to
		//add more blocks later to help the user finish
		pausedTypeCount++;
		pausedTypes[pausedTypeCount-1] = ballType;
		[self removeItem:availTypes :ballLoc :availTypeCount];
		availTypeCount--;
	}
}

//this handles unpausing a type - moving from paused to available array
-(void) unpauseType:(int) ballType {
	//get the position of the ball type in the paused type array
	int ballLoc = [self locateType:pausedTypes:pausedTypeCount:ballType];
	
	//only try to unpause the block if its currently paused
	if ( ballLoc >= 0) {		
		//add more blocks later to help the user finish
		availTypeCount++;
		availTypes[availTypeCount-1] = ballType;
		[self removeItem:pausedTypes :ballLoc :pausedTypeCount];
		pausedTypeCount--;				
	}
}

//initialize types - this does most of the setup work for all the arrays
-(void) initializeTypes:(int) levelTypes:(int) levelBlocks {
	//update available types (count their counts just which are available)
	maxTypeCount = levelTypes;
	
	availTypeCount = maxTypeCount; //only 
	
	//if there are more than max on board
	//we need to fill in the wiating type counts
	if ( availTypeCount > MAX_BLOCKS_ON_BOARD) {
		availTypeCount = MAX_BLOCKS_ON_BOARD;
		waitingTypeCount = maxTypeCount - availTypeCount;
	} else {
		//there are no blocks waiting because we can display them all at once
		waitingTypeCount = 0;
	}
	
	
	pausedTypeCount = 0; //there are no blocks paused
	
	//setup all available block types now
	for (int c = 0; c < availTypeCount;c ++ ) {
		//setup this type as available
		availTypes[c] = c+1;
		pausedTypes[c] = 0; //nothing here to pause
		
		
		//reset this blocks type in the count manager
		[self resetType:c+1 :levelBlocks/maxTypeCount];
	}
	
	//setup all the waiting block types now
	for (int c = 0; c < waitingTypeCount;c ++ ) {
		//setup this type as available
		waitingTypes[c] = availTypeCount+c+1;
		pausedTypes[availTypeCount+c] = 0; //nothing here to pause
		
		//setup counter for this type as well (even though its waiting)
		[self resetType:availTypeCount+c+1 :levelBlocks/maxTypeCount];		
		
	}
	
}

//TODO: remove updatePausedTypes method, shouldn't need
//this method pauses or unpauses block types
//based on how many blocks are available of their type
//this method needs to be broken up into the seperate ethods
//and shouldn't have to be called in this manner
-(void) updatePausedTypes {
	//testing - see if other methods handle this properly
	return;
	
	
	//pause all blocks that need pausing
	int c = 0;
	while ( c < availTypeCount) { 
		//get this blocks type
		int ballType = availTypes[c];
		int onBoard = [self onBoard:ballType];
		//int onBoard = [self blocksOnBoard:ballType];
		
		//are we at the limit for this block?
		//if so we should be doing something
		if ( [self deployed:ballType] >= [self max:ballType]) {
			
			//are we at a stopping point?
			if ( onBoard >= 4 ) {
				[self pauseType:ballType];
				
			} else if ( onBoard == 0 ) {
				//definately can remove from available array
				//but there is no need to pause
				[self removeItem:availTypes :c :availTypeCount];
				availTypeCount--;
				
				
			} else {
				//no need to do anything with this ball - still in play
				//however - here we should probably update the max # of items to 4 since
				//we can't collect less than 4
				//maxBlocks[ballType] += 4-onBoard;
				[self adjust:ballType];
				
				
				//keep on moving
				c++;
			}
		} else {
			//ball still in play - there are more to come
			c++;
		}		
	}
	
	//now check all paused types they either get removed or moved back to available types array
	c = 0;
	while ( c < pausedTypeCount) { 
		//get this blocks type
		int ballType = pausedTypes[c];
		int onBoard = [self onBoard:ballType];
		//int onBoard = [self blocksOnBoard:ballType];		
		
		//are we at the limit for this block?
		//if so we should be doing something
		if ( [self deployed:ballType] >= [self max:ballType]) {
			//are we at a stopping point?
			if ( onBoard < 4 && onBoard > 0 ) {
				//unpause the block
				[self unpauseType:ballType];
				
				//adjust the # of blocks for this type (in case user collected an odd #)
				[self adjust:ballType];
				
				//there are now more blocks of this type
				//maxBlocks[ballType] += 4 - onBoard;
				
			} else if ( onBoard == 0  ) {
				//definately can remove from paused array array
				//but there is no need to pause
				[self removeItem:pausedTypes :c :pausedTypeCount];
				pausedTypeCount--;
				
			} else {
				//no need to do anything with this ball - still in play
				c++;
			}
		} else {
			//ball still in play - there are more to come
			c++;
		}		
	}
	
}


@end
