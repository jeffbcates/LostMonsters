//
//  HelloWorldScene.h
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
#import "SpinBoard.h"
#import "LGSocialGamer.h"
#import "PlayMenu.h"

//****CONSTANTS****//

//#define MAX_BLOCK_TYPES 11
#define MAX_BLOCKS_ON_BOARD 4

//scene defintiion
@class CountManager;
@interface Frantic : SpinBoard <BehavioralLayer,LGSocialDelegate> { /*, GameKitHelperProtocol> {*/
	//the 3 window tease frames
	CGRect windowTeaseRect1, windowTeaseRect2, windowTeaseRect3;
	
	//this is all about fixing the ambient effects
	//CCArray *ambientAvail;
	int ambientPlaying;
	int teasesPlaying;  //we should only let so many tease sounds play at a time
	
	
	//an array of all the teasing animations and all the regular animations
	//since they can be reused
	CCArray *teaseAnims;
	CCArray *randAnims;
	
	
	//some other stats that help with achievements
	int bombsCollected, boardsBusted;
	
	//is sound enabled?
	//this is checked from user settings only at certain times
	//that way we don't run into any slow downs when sound plays
	bool soundEnabled;
	
	
	//did the level start with a custom board?
	//if so, we don't start spawning until a move is completed
	
	
	
	bool definedBoard;
	
	//are we counting combos right now?
	bool countingQuickFires;
	int quickFireCounter; //counts by 1 til it hits the specified amount, can add to this as we collect more items
	int quickFires; //not like a combo, this is the total # of combos in a certian timeframe
	int quickFireStartScore; //starting score for quick fires	
	
	//animations - stored here to save memory
	CCAnimation *animWindowOpening, *animWindowClosing, *animWindowBoarding;
	
	
	//the count manager controls block counts keeping us honest
	//with our blocks
	CountManager *counter;
	
	//each level should spawn at least one life just for getting that far
	bool freebieLifeSpawned;
	
	//how many lives do we have
	//and how many coins have we collected
	int lives;
	int coins;
	
	//an alert given to teh user (such as leveling up, etc)
	Actor *alert;
	int level;
	int lastLevelPoints; //store the # of points required for the last level we completed
	int maxSpawnCount; //current max spawn count
	int maxStates; //max states for the level
	CCQuadParticleSystem *cpf;

	//keep a reference back to play menu
	//so we can update statuses of various trackers
	//PlayMenu *playMenu;
	
	//behavior that managers triggering alerts on the screen
	TriggerAlert *alertManager;
	
	//store the last # of combos made
	int combos;
	int comboPoints; //points before combo
	
	//the finger is an interactive help thing
	//for the initial levels to help users see what to do
	Actor *finger;
	//Actor *helpActor; //this is the help text
	bool _fingerCanCancel;
	
	//instead of help being just text
	//we are now showing a full image overlay
	//CCSprite *helpOverlay;
	
	//keep a reference to the game kit helper
	//GameKitHelper *gkHelper;
	
}

//this is called by floatyspawn to determine which sprite frame we show
//when we are collecting monsters (the guy on the cloud)
-(CCSpriteFrame *) floatyFrame:(Actor *) actor;

//remove the "help" finger from the scene if its there
//can also cancel the finger operation here (actually allow canceling)
-(void) removeFinger;
-(void) cancelFinger;
-(void) removeHelpText;

//call this method to set the game in thoughtful mode
//which is a slower easier way of playing
-(bool) thoughtful;
-(void) setThoughtful:(bool) thoughtful;

-(void) startMusic;

//sound may have been enabled/disabled from the pause menu
//so here we can quickly get that done
-(void) setSoundEnabled:(bool) enabled;

//return the estimated # of remaining moves
-(int) remainingMoves;

//this gets called from the menu when the user advances the level
-(void) advanceLevel;

//reads the board into a string and returns it
-(NSString *) readBoard;

//return mode prefix
-(NSString *) modePrefix;

//save the current level to settings
-(void) loadLevel;
-(void) saveLevel;

//when this gets called - all the boarded windows break open
-(void) bustBoards;

//set menu and set alert layer
-(void) setMenu:(PlayMenu *) menu;
-(void) setAlertLayer:(BehavioralLayer *) alertLayer;

@end
