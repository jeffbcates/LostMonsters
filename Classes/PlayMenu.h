//
//  PlayMenu.h
//  testapp
//
//	this is the play menu (top and popup menu items)
//	this layer appears along side the playboard when playing the game
//	that way you can control this player and the playboard differently
//
//  Created by Jeff Cates on 11/26/10.
//  Copyright 2010 mrwired. All rights reserved.
//

// When you import this file, you import all the cocos2d classes
//scene stuff and everything else
#import "BehavioralLayer.h"
#import "ActorStack.h"


/***MENU IMPLEMENTATION***/
@class SpinBoard;
@interface PlayMenu : BehavioralLayer <BehavioralLayer> {
	//tracks current best multiplier and other scores
	int bestMultiplier, bestCombo, bestBombs;
	
	//are we showing our popup menu or not?
	bool showingPopup;
	bool _braggable; //set to true when there is a braggable event (so we show the second "brag" page
	bool _gameOverShowing; //so the pause menu doesn't show over the game over menu
	
	//is sound enabled or not?
	bool soundEnabled;
	
	//testing - slow song being played or fast one?
	bool fastSong;
	
	//the stack of hearts for our lives
	ActorStack *lifeStack;
	
	//the stack of monsters for our statuses
	ActorStack *statusStack;
	
	//the blocksheet for all images in the menu
	Actor *helpActor; //the actor for help overlay
	Actor *finger; //the finger
	CCSpriteSheet *helpSheet;
	CCSpriteSheet *blockSheet;
	CCSpriteSheet *ballSheet; //for displaying pictures of balls on level up screens
	
	//keep a reference to the play board
	SpinBoard *playBoard;
	
	//these track # of monsters still available on the board
	/*
	Actor *monsterCount;
	TrackPoints *monsterCountTracker;
	*/

	//these track points and status
	Actor *points;
	int pointsForLevel; //calculated points earned during this level
	TrackPoints *pointTracker;
	
	//track the level we are on
	Actor *levelNum;
	Actor *levelDisplay; //shows the word "level" before the level #
	TrackPoints *levelTracker;

	//track status
	Actor *status;
	
	//the level up messageboard (little box that pops up)
	Actor *messageBox;
	
	//are we showing the messagebox?
	//if so then the touch event should hide the messagebox
	//rather than doing anything else
	bool showingMessage;
	
	//are we showing the pause menu or not?
	bool paused;
	
	//our level up message box has several components
	Actor *title; //this is the title of the popup (an image)
	Actor *menu; //this is the little menu button at the top left
	Actor *levelName; //what level are we on?
	Actor *pointsEarned; //how many points are there?
	//Actor *movesUsed; //how many moves were used to complete the level?
	Actor *introducing; //which new blocks are showing up
	Actor *newBlock; //displays the new block that we add in a level
	Actor *newBlockName; //name of the new block (monster)
	//Actor *newBlockDesc; //description of the new block
	Actor *tweetStatus; //displays the tweet status message if setup
	Actor *highScore; //the high score name "new record!!!"
	Actor *bragButton; //this is the button the user pushes to do their bragging
	
	
	//the news anchor pops up between each level
	//to give you new information
	Actor *newsAnchor;
	
	int lastPoints; //last points earned
	int pagesToShow; //how many pages should we show
	
	//there are actually a couple "pages" on the level up message box
	//store hte page we are on
	int currentPage;
	
	//this is the level that just got beat
	int _levelDone;
	
	//stuff relating to tweeting
	//this determines if we automatically tweet or not
	bool autoTweet;
	//QuickTweet *quickTweet;
	
	//coins - just a quick thing here
	int _coins;
	
}

//when we come back from a save the last # of points
//needs to get updated so "points per level" is correct
-(int) getLastPoints;
-(void) setLastPoints:(int) updatedPoints;

//update methods for multipliers
-(void) updateBestMultiplier:(int) multipliers;
-(void) updateBestCombo:(int) combos;

//show the messagebox (also overrides touch events temporarily)
//and this shows a new block (being introduced)
-(void) showMessageBox:(int) levelDone:(int) newBlockType;

//this doesn't show the new block dialog
-(void) showMessageBox:(int)levelDone;

-(void) hideMessageBox;

//set a reference to the playboard
-(void) setPlayboard:(SpinBoard *) board;

//return a reference to the points actor
-(Actor *) getPoints;

//return a reference tot eh status bar actor
-(Actor *) getStatus;

//for quick tweeting - we are the delegate this method gets called
-(void) doneTweeting:(NSString *) result;

//define the # of statuses available
-(void) clearStatuses;
-(void) resetStatuses:(int) statusCount;

//various updaters etc for status related info
-(void) updateStatus:(int) actorType:(float) newStatus;

//update status with a possible new max value
-(void) updateStatus:(int) actorType:(float) newStatus : (float) newMax; 

//reset and pop status values
-(void) addStatus:(int) blockType;
-(void) resetStatus:(int) actorType:(float) min:(float) max;
-(void) popStatus:(int) blockType; //this reoves the status from the menu

//update the # of lives visible
-(void) updateLives:(uint) lives;

//update the available # of coins
-(void) updateCoins:(int) coins;

//set the current level
-(void) setLevel:(int) level;

//testing:
-(void) checkStatus:(int) stat;

//show the game over menu item
-(void) gameOver:(int) finalScore:(bool) lite;

//selector to launch the link to the full version
-(void) buyFull;

//trigger the paused menu and save operation for quitting/starting the app
-(void) triggerPause;
-(void) triggerSave;

//show a particular help overlay
-(void) showHelp:(NSString *) helpFrame; //shows the defined help overlay
-(void) killHelp; //kills the current help overlay
-(bool) showingHelp; //are we showing help or not?
-(void) fadeHelp; //fade out the help (maybe when the user touches the screen, etc)

//related to the finger that appears during help
-(Actor *) createFinger:(CGPoint) startPoint;
-(void) killFinger;
-(bool) showingFinger;
-(void) fadeFinger;

//cleanup
-(void) dealloc;


@end

