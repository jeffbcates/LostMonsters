//
//  HelloWorldScene.h
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "BehavioralLayer.h"

//****CONSTANTS****//

#define ROWS 6
#define COLS 5

#define SLIDER_COLS (COLS*3)
#define SLIDER_ROWS (ROWS*3)

//this is a block that can be collected
//when you touch it you collect it instead of sliding row/col
#define COLLECTABLE_BLOCK 3

//hack - set max block type here
#define _MAX_BLOCK_TYPES 12

//scene defintiion
@class PlayMenu;

@interface SpinBoard : BehavioralLayer <BehavioralLayer> {
	//this stores the current spawn interval
	float _spawnInterval;
	
	//store a reference to the playmenu in case we need it
	PlayMenu *menu;
	
	//values that modify game play
	NSString *BLOCK_FILE;	//what is the block sprite file
	int BALL_TYPES;		//how many blocks are in the game
	
	//is the game over?
	bool gamesOver;
	
	//are we playing in "thoughful" mode
	bool _thoughtful;
	
	//are we in a mass spawn?
	//if so this # will not be 0
	int massSpawnCount;
	
	//the row slider is slightly bigger than a normal row
	//in order to accomidate the 2 phantom sprites
	Actor *rowSlider[SLIDER_COLS];
	Actor *colSlider[SLIDER_ROWS];
	
	//store an array of actors in their cols/rows
	Actor *playboard[ROWS][COLS];
	
	//store an array of the available spots on the board
	//for quick reference
	CGPoint availSpots[ROWS*COLS];
	int availCount;
	
	//this is an array of spots that are active... i.e. a monster is in there
	//or the window is boarded up
	CGPoint activeSpots[ROWS*COLS];

	//this tracks the # of active bocks on the board
	int activeBalls;
	
	//scene level actors
	CCSpriteSheet *blockSheet;
	
	//store current spawn interval
	float currentInterval;
	float minInterval;
	int minSpawn;
	int maxSpawn;
	
	//track moves 
	Actor *points;
	TrackPoints *pointTracker; //this is the behavior that actually tracks points
	
	//track level completion status
	Actor *status; //reference to the actor that displays the status (has the status bar behavior)
	StatusBar *statusTracker; //this is the behavior that actually tracks status

	//touch event related values
	bool touching;
	bool validTouch;
	int activeRow;
	int activeCol;
	
	//this is the original row and column the user touched
	int startRow, startCol;
	
	CGPoint startTouch;
	CGPoint lastTouch;
	
	//track the # of moves during a level
	int userMoves;
	
	//these two determine if axeses are locked	
	bool rowLocked;
	bool colLocked;
	
	//we can't let the spawn fire while we are setting
	//up or taking down row sliders
	//that's what this is about
	bool inTouchBegan;
	bool inTouchEnded;
	
	//HACK: keep a count of actual blocks on board
	//that we sync anytime we loop over the entire board	
	//this should be 1 bigger than the # of block types
	//because this thing tracks block type of zero (i.e. block #1 is not in array indice 0 as normal)
	int blocksOnBoard[_MAX_BLOCK_TYPES+1];
	
	
	
}


//this gets called when the level is up
-(bool) levelUp;

//this gets called when the game is over
-(void) gameOver:(bool)lite;

//get and set the points actor reference
-(void) setPoints:(Actor *) pointActor;

//get and set the status actor reference
-(void) setStatus:(Actor *) pointActor;

//update links (for tracking behavior)
-(void) updateLinks;

//get texture rectangle for ball type
-(CGRect) getBallTextureRect:(Actor *) ball;
//this returns a sprite frame
-(CCSpriteFrame *) getBallFrame:(Actor *) ball;

//different ways to add a new sprite (and actor) with coordinates
-(Actor *) addNewSpriteWithCoords:(CGPoint)p:(int) ballType:(int) ballState:(bool) noAnim;
-(Actor *) addNewSpriteWithCoords:(CGPoint)p:(int) ballType : (bool) noAnim;

//spawn bubbles
-(void) spawnBubble;

//testing functionality
-(void) printBoard;

//this resets the counters
//slowing gameplay back down between levels
-(void) resetCounters:(float) StartInterval:(float) MinInterval:(int)MinSpawn:(int)MaxSpawn;

//trigger a mass spawn
-(void) triggerMassSpawn:(int) spawnCount;

//are we presently in a mass spawn situation?
-(bool) massSpawning;

//update the play menu reference
-(void) setMenu:(PlayMenu *) playMenu;

//this gets called from the menu when the user adavnces the level
-(void) advanceLevel;

//set sprite color (overridden later)
-(void) setSpriteColor:(Actor *)ball:(bool) noAnim;

//when a new block gets spawned
//this method is called to shake things up a big
//it determines the type and state of the new block
//based on whatever variables we want (depends on game implmentation)
//if this returns false it is beacuse we don't want a block created
-(bool) determineBlockType:(Actor *) block;

//call this to cancel spawn events
-(void) stopSpawning;

//this is like spawnBubble except it spawns a collectable item of the given type
-(void) spawnCollectable:(int) blockType ;

//update the available block count on the board
-(void) updateAvailCount;

//remove all blocks that have a collectable state - return them to normal empty window
//this is typically done when the level completes
-(void) clearCollectables;

//override this bad boy to cause sprites to hightlight in the column and row that's slideable
-(void) highlightSprite:(Actor *) actor:(bool) highlighted;

@end
