//
//  CountManager.h
//  LostMonsters
//
//  Created by Jeff Cates on 4/8/11.
//  Copyright 2011 leftygames. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MAX_BLOCK_TYPES 12

@interface CountManager : NSObject {
	//internally we just have some arrays of counts for each block type
	int maxTypeCount; //the is the original # of each type of block we originally 

	//the # of blocks collected, deployed, and original (max) blocks
	int blocksOnBoard[MAX_BLOCK_TYPES+1]; //# blocks on board
	int blocksCollected[MAX_BLOCK_TYPES+1]; //# of blocks collected by user
	int blocksDeployed[MAX_BLOCK_TYPES+1]; //# of blocks provided to the user
	int maxBlocks[MAX_BLOCK_TYPES+1]; //# of blocks total
	
	//how many blocks of each type have been collected
	//the type is the index in this thing
	int availTypeCount; //# of available types (upper bound of available values in availTypes array)
	int availTypes[MAX_BLOCK_TYPES]; //contains the array of types available for this level (zeros trailing at end of array)
	
	//contains the array of types that are "paused" meaning they should not spawn
	//because they have hit max but can't be removed b/c they have more than 4 blocks
	int pausedTypeCount; //# of block types paused from spawning b/c they have more than 4 but at maximum
	int pausedTypes[MAX_BLOCK_TYPES]; 
	int waitingTypeCount;
	int waitingTypes[MAX_BLOCK_TYPES]; //this is the # of blocks waiting in the wings (only 4 are shown at a time)
	
	

}

//***SERIALIZATION METHODS***//

//array to string methods
-(NSString *) deployedToString;
-(NSString *) collectedToString;
-(NSString *) maxToString;
-(NSString *) onboardToString;

//there are not block counts - they are arrays of types that are available
-(NSString *) pausedToString;
-(NSString *) waitingToString;
-(NSString *) availToString;

//array from string methods
-(void) deployedFromString:(NSString *) stringValue;
-(void) collectedFromString:(NSString *) stringValue;
-(void) maxFromString:(NSString *) stringValue:(int) maxCount;
-(void) onboardFromString:(NSString *) stringValue;

-(void) pausedFromString:(NSString *) stringValue:(int) pausedCount;
-(void) waitingFromString:(NSString *) stringValue:(int) waitingCount;
-(void) availFromString:(NSString *) stringValue:(int) availCount;

//***COUNT CHECK METHODS***//

//return type counts
-(int) max;
-(int) avail;
-(int) waiting;
-(int) paused;

//how many of a given block are deployed
-(int) deployed:(int) blockType;
-(int) collected:(int) blockType;
-(int) max:(int) blockType;
-(int) onBoard:(int) blockType;
-(int) onBoard; //on board for all types

//return a type given its index in an array
-(int) availType:(int) index;
-(int) pausedType:(int) index;
-(int) waitingType:(int) index;

//is the particular type done?
-(bool) done:(int) blockType;

//***COUNT MANAGEMENT METHODS***//

//make a currently waiting type available
-(void) popWaitingType;

//adjust a block type - increasing max count
//to accomidate an odd # of blocks by the user
-(void) adjust:(int) blockType;

//fix is like adjust accept assumes the board is currently in
//a stable state (i.e. not in the middle of connecting anything)
//also assumes that the onboard count has been correcrted already
-(void) fix:(int) blockType;

//deploy a block - add to deployed count
-(void) deployType:(int) blockType;

//undeploy a block - remove from deployed count
//this is what happens when a window boards up
-(void) undeployType:(int) blockType;

//collect a block - move from deployed to collected state
-(void) collectBlock:(int) blockType;

//collect multiple # of blocks at once (this could be bad)
-(void) collectBlocks:(int) blockType:(int) blockCount;

//reset a type (there are none collected or deployed)
//this should only be called at the start of a level
-(void) resetType:(int) blockType:(int) blockCount;

//reset the # of block types etc
-(void) reset:(int) blockTypes;

//get a random type from our available type array
-(int) randomType;

/***PAUSING AND UNPAUSING LOGIC***/

//this handles "pausing" a type - moving from available to paused array
-(void) pauseType:(int) ballType;

//this handles unpausing a type - moving from paused to available array
-(void) unpauseType:(int) ballType;


//initialize types - this does most of the seutp work for everyting
-(void) initializeTypes:(int) levelTypes:(int) levelBlocks;

//TODO: remove updatePausedTypes method
-(void) updatePausedTypes;

//sync a type with the count on board
//this is because sometimes the counts get off
-(void) syncWithBoard:(int) blockType:(int) onBoard;

@end
