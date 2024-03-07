//
//  PlayMenu.m
//  testapp
//
//  Created by Jeff Cates on 11/26/10.
//  Copyright 2010 mrwired. All rights reserved.
//

#import "PlayMenu.h"
#import "MainMenu.h"
#import "Frantic.h"
#import "Settings.h"
#import "config.h"
#import "LGSocialGamer.h"

//our list of achievements
#import "achievements.h"

//definitions and names of all monsters here
#import "monsterinfo.h"

#define STATUS_SPACER 48
#define STATUS_START 150
#define STATUS_YVALUE 64/2

#define STATUS_SCALE 0.68f
#define MESSAGEBOX_XPOS 207

@implementation PlayMenu



//store reference to playboard
-(void) setPlayboard:(SpinBoard *)board {
	//save for later
	playBoard = board;
	
}

//in this scene we need a tick method to keep
//actors who use "StickTo" in sync
-(bool) enableTick {
	return true;
}

//this method reenables touching on the menu
//since it was turned off while getting shown
-(void) enableMenuTouch {
	//enable the messagebox (for touch in our case)
	[messageBox setEnabled:true];	
}

//create the news anchor
-(void) createNewsAnchor {
	//notice we add news anchor to layer not block sheet
	//this is because news anchor must show up in front of text and not behind it
	//this is the only way for text to respect its Z value (text must show above all other sprites)
	
	//setup the news anchor
	newsAnchor = [[Actor alloc] init:self];
	CCSprite *newsAnchorSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"News-Room-Anchor.png"]];	
	[newsAnchor setMainSprite:newsAnchorSprite];
	[newsAnchorSprite setAnchorPoint:CGPointMake(0,0)];
	[newsAnchor setPosition:ccp(-85,0)];
	[newsAnchorSprite setScale:0.5];
	//[blockSheet addChild:newsAnchorSprite z:100];
	[self addChild:newsAnchorSprite z:100];
	[newsAnchor setState:0];
	[self addActor:newsAnchor];
	
	//state 1 is when the anchor is onscreen
	[newsAnchor addBehavior:[(StateAction *)[[StateAction alloc] withAfterState:0] withAction:[CCMoveTo actionWithDuration:0.2 position:ccp(-10,0)]]];
	[newsAnchor addBehavior:[(StateAction *)[[StateAction alloc] withAfterState:0] withAction:[CCScaleTo actionWithDuration:0.2 scale:1.0]]];
	 
	//state 0 is when the anchor is offscreen
	[newsAnchor addBehavior:[(StateAction *)[[StateAction alloc] withState:0] withAction:[CCMoveTo actionWithDuration:0.2 position:ccp(-85,0)]]];
	[newsAnchor addBehavior:[(StateAction *)[[StateAction alloc] withState:0] withAction:[CCScaleTo actionWithDuration:0.2 scale:0.5]]];
	
	
	//add a sprite (only sprite not actor) to news anchor
	CCSprite *newsMouthSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"News-Room-Mouths-3.png"]];
	[newsMouthSprite setPosition:CGPointMake(71,152)];
	[newsAnchorSprite addChild:newsMouthSprite];

	/*
	//the news anchor sprite should be a continually talking mouth
	CCAnimation *mouthAnim = [CCAnimation animationWithName:@"anchorMouth"];
	[mouthAnim setDelay:0.12f];	
	
	for (int c = 1; c <= 6; c++ ) {
		//add this frame to the animation
		[mouthAnim addFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"News-Room-Mouths-%i.png",c]]];
	}
	
	//close the mouth when switching to state 2
	[newsAnchor addBehavior:[[[[StateAction alloc] withTarget:newsMouthSprite] withState:2] withAction:
		[CCReplaceFrame actionWithFrameName:@"News-Room-Mouths-5.png"]
	]];
	
	//create a state action on the anchor actor
	//for running the mouth animation
	//NOTE: this is a while state - which will get stopped when state changes awaay from state 1
	[newsAnchor addBehavior:[[[[StateAction alloc] withTarget:newsMouthSprite] whileState:1] withAction:
		[CCRepeatForever actionWithAction:
			[CCSequence actions:		  
				[CCAnimate actionWithAnimation:mouthAnim restoreOriginalFrame:false],
				nil
			]
		]
	 ]];
	
	//randomize states 1 and 2 for the news anchor so the mouth kinda looks like talking
	RandomizeState *rs = [(RandomizeState *)[RandomizeState alloc] withAfterState:0];
	[rs withState:1 :0.25f :0.72f];
	[rs withState:2:0.25f:0.5f];
	[newsAnchor addBehavior:rs];
	*/
	 
}

//launch the brag dialog 
-(void) showBrag {
	//brag about the currently unlocked block
	//the achievement id is the same as the block type, which is stored in the tag of the block
	[LGSocialGamer bragAchievement:[newBlock tag]-1];
}

//trigger an alert message that floats up
-(void) setupMessageBox {
	//there are three durations for the 
	float durIn = 0.2f;
	float durOut = 0.2f;
	
	//other declarations
	CGPoint location = ccp([super screenSize].width/2,[super screenSize].height/2);
	
	//randomly choose a rotation direction
	//and a fade out direction
	int rotationDir = (CCRANDOM_0_1() < 0.5) ? -1 : 1;

	//NOTE: hack - add brag actor before the main messagebox
	//so it will capture touch events first, then messagebox can still be tap to continue
	//this displays the next message
	//and we should match the position / rotation and state of the main menu block
	tweetStatus = [[Actor alloc] init:self];
	[self addActor:tweetStatus];
	CCSprite *bragSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"brag.png"]];
	[tweetStatus setMainSprite:bragSprite];
	[blockSheet addChild:bragSprite z:10 tag:1234];
	[bragSprite setPosition:ccp(MESSAGEBOX_XPOS,[super screenSize].height/2-12)];
	//tweetStatus = [self addTextActor:ccp(MESSAGEBOX_XPOS,[super screenSize].height/2) :@"Brag" :@"CCZoinks" :48 :LM_GREEN];
	[tweetStatus addBehavior:[NamedBehavior MenuClick:@selector(showBrag)]];
	[[tweetStatus mainSprite] setVisible:false];	
	
	//create the message box actor
	//create the level up messagebox
	messageBox = [[Actor alloc] init:self];
	//CCSprite *boxSprite = [CCSprite spriteWithSpriteSheet:blockSheet rect:CGRectMake(0,70,192,192)];	
	CCSprite *boxSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"popup-menu.png"]];	
	[messageBox setMainSprite:boxSprite];
	
	//TODO: review this line - doesn't have an effect on placement (because behaviors place box later?)	
	boxSprite.position = ccp(MESSAGEBOX_XPOS,[super screenSize].height/2);
	[blockSheet addChild:boxSprite];
	[self addActor:messageBox];
	
	//NOTE: Hack part 2 - now make the brag button stick to the messagebox
	//now that we've created a messagebox
	[tweetStatus addBehavior:[[[StickTo alloc] withOther:messageBox] withMatchState]];
	
	//create a "LEVEL UP" actor
	//start with it rotated 90deg upwards
	CCSprite *s = [messageBox mainSprite];
	[s setRotation:45*rotationDir];
	[s setScale:0.25];
	[messageBox setState:0];
	
	//start with it hidden
	[s setOpacity:0];

	//create a state action behavior that will trigger these actions
	//when the state changes to 1
	[messageBox addBehavior:[(StateAction *)[[StateAction alloc] withState:1] withAction:
			[CCSequence actions:
				//flip the menu in focus
				[NamedAction FlipIn:durIn],
			 
				//enable touch events on the menu
				[CCCallFunc actionWithTarget:self selector:@selector(enableMenuTouch)],
			 
				//now socialize the scores while the user is reading
				[CCCallFunc actionWithTarget:self selector:@selector(socializeScores)],
			 
				nil
			]
	]];
	
	//create a state action behavior to trigger the slide out
	//action when the state chnages back to 0
	[messageBox addBehavior:[(StateAction *)[[StateAction alloc] withState:0] withAction:
		[CCSequence actions:
			//first flip out
			[NamedAction FlipOut:durOut:ccp(-192,[super screenSize].height/2)],
							 
			nil
		]
	]];

	//when the box is touched we fire the hide message event
	[messageBox addBehavior:[[[TouchSelector alloc] withSelector:self:@selector(nextPage)] withTouch]];
	[messageBox setEnabled:false];
	
	//this displays the level that was completed
	//and we should match the position / rotation and state of the main menu block
	levelName = [self addTextActor:ccp(boxSprite.position.x,boxSprite.position.y+10) :@"1" :@"BadaBoom BB" :44 :LM_GREEN];
	[levelName addBehavior:[[[StickTo alloc] withOther:messageBox] withMatchState]];
	[[levelName mainSprite] setAnchorPoint:CGPointMake(0.5,0.5)];
	
	//this displays the points earned this level
	//and we should match the position / rotation and state of the main menu block
	pointsEarned = [self addTextActor:ccp(boxSprite.position.x-75,boxSprite.position.y-100) :@"1" :@"BadaBoom BB" :30 :LM_LIGHTBLUE];
	[[pointsEarned mainSprite] setAnchorPoint:CGPointMake(0,0.5)];
	[pointsEarned addBehavior:[[[StickTo alloc] withOther:messageBox] withMatchState]];
	[pointsEarned addBehavior:[[TrackPoints alloc] withCountBy:10]];
	
	
	//the "tap to continue" message
	//and we should match the position / rotation and state of the main menu block
	/*
	pointsEarned = [self addTextActor:ccp(boxSprite.position.x-35,boxSprite.position.y+10) :@"1 Points" :@"BadaBoom BB" :24 :LM_LIGHTBLUE];
	[[pointsEarned mainSprite] setAnchorPoint:CGPointMake(0,0.5)];
	[pointsEarned addBehavior:[[[StickTo alloc] withOther:messageBox] withMatchState]];
	[pointsEarned addBehavior:[[TrackPoints alloc] withCountBy:10]];
	*/
	
	
	//this displays the moves required to complete the level
	/*
	movesUsed = [self addTextActor:ccp(boxSprite.position.x-35,boxSprite.position.y-20) :@"Coins: 1" :@"BadaBoom BB" :24 :LM_LIGHTBLUE];
	[[movesUsed mainSprite] setAnchorPoint:CGPointMake(0,0.5)];
	[movesUsed addBehavior:[[[StickTo alloc] withOther:messageBox] withMatchState]];
	[movesUsed addBehavior:[[[TrackPoints alloc] withCountBy:10] withTitle:@"Coins: %i"]];
	*/

	//this displays the next message
	//and we should match the position / rotation and state of the main menu block
	introducing = [self addTextActor:ccp(boxSprite.position.x,boxSprite.position.y-130) :@"REWARD IF FOUND!" :@"CCZoinks" :24 :LM_LIGHTBLUE];
	[introducing addBehavior:[[[StickTo alloc] withOther:messageBox] withMatchState]];
	
	//this displays the next monster name
	//and we should match the position / rotation and state of the main menu block
	newBlockName = [self addTextActor:ccp(boxSprite.position.x,boxSprite.position.y-90) :@"" :@"CCZoinks" :36 :LM_GREEN];
	[newBlockName addBehavior:[[[StickTo alloc] withOther:messageBox] withMatchState]];

	//add the title of the menu
	//this will either say "LOST" or will say "level done!"
	title = [[Actor alloc] init:self];
	CCSprite *titleSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"level-done.png"]];	
	[title setMainSprite:titleSprite];
	[titleSprite setPosition:ccp(boxSprite.position.x-3,boxSprite.position.y+120)];
	[blockSheet addChild:titleSprite];
	[self addActor:title];	
	[title addBehavior:[[[StickTo alloc] withOther:messageBox] withMatchState]];	
	
	

	//this displays the level actor
	//and we should match the position / rotation and state of the main menu block
	
	newBlock = [[Actor alloc] init:self];
	CCSprite *newBlockSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"monster-1-colored.png"]];	
	[newBlock setMainSprite:newBlockSprite];
	
	//dead center now:
	[newBlockSprite setPosition:ccp(boxSprite.position.x,boxSprite.position.y+20)];
	/*
	[newBlockSprite setAnchorPoint:ccp(1,0)]; //anchor to bottom right of the menu to make it easier (no need to calc monster sizes)
	//the constants referenced here (25 and 28) refer to the amount of the popup menu sprite devoted to shadowing
	newBlock.position = ccp(boxSprite.position.x+boxSprite.contentSize.width/2-25,boxSprite.position.y-boxSprite.contentSize.height/2+28);
	*/
	
	[blockSheet addChild:newBlockSprite];
	[self addActor:newBlock];	
	
	//just like others - this block sticks to the main message window
	[newBlock addBehavior:[[[StickTo alloc] withOther:messageBox] withMatchState]];	
	
	//this displays the next message
	//and we should match the position / rotation and state of the main menu block
	highScore = [self addTextActor:ccp(boxSprite.position.x,boxSprite.position.y+60) :@"You Unlocked a Monster          Tell your Friends!" :@"CCZoinks" :20 :LM_BLUE:CGSizeMake(220,80):UITextAlignmentCenter];
	
	//highScore = [self addTextActor:ccp(boxSprite.position.x,boxSprite.position.y+70) :@"you just unlocked a monster, tell your friends what's up!" :@"CCZoinks" :24 :LM_BLUE];
	//CCLabel *highLabel =  [highScore mainSprite];
	[highScore addBehavior:[[[StickTo alloc] withOther:messageBox] withMatchState]];
	//[highScore addBehavior:[ShadowText alloc]];
	
	//setup our brag button and add it as an actor before the main window
	//so it will capture touch events first
	/*
	bragButton = [[Actor alloc] init:self];
	CCSprite *bragButtonSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"brag-button.png"]];	
	[bragButton setMainSprite:newBlockSprite];
	*/
	
	//create the news anchor
	[self createNewsAnchor];
	
}

//set the current level # (for display at bottom right)
//this is only really needed if we are loading a saved level
//and the natural level progression doesn't work
-(void) setLevel:(int) level {
	[levelTracker resetPoints];
	[levelTracker addPoints:level];
}

//this disables the menu buttno when showing a message box widnow
-(void) disableMenuButton {
	//disable related actions
	[[menu behavesAs:[TouchSelector class]] setEnabled:false];
	[[menu behavesAs:[ShowWindow class]] setEnabled:false];	
	
	//fade the button out
	[[menu mainSprite] runAction:[CCFadeOut actionWithDuration:0.5f]];
	
}

//this enables the menu button
-(void) enableMenuButton {
	//enable the menu button behaviors
	[[menu behavesAs:[TouchSelector class]] setEnabled:true];
	[[menu behavesAs:[ShowWindow class]] setEnabled:true];	
	
	//fade the button back in
	[[menu mainSprite] runAction:[CCFadeIn actionWithDuration:0.5f]];
	
}

//this gets called whent eh game is over - shows that window
-(void) gameOver:(int) finalScore:(bool) lite {
	//we are showing the game over menu!
	_gameOverShowing = true;
	
	//disable the menu button
	[self disableMenuButton];
	
	//create the window
	Window *gameOverWindow = [[Window alloc] init:self];
	[self addActor:gameOverWindow];
	[gameOverWindow setDelegate:self];
	
	//determine points this level
	//int pointsForLevel = (finalScore-lastPoints);
	
	//single level best score and high score
	//no longer using the single level score leaderboard:
	//[LGSocialGamer score:pointsForLevel leaderboard:LEADERBOARD_SINGLELEVEL];
	[LGSocialGamer score:finalScore leaderboard:LEADERBOARD_HIGHSCORE];
	
	//don't bother submitting if there isn't a multiplier
	if (bestCombo > 0 ) [LGSocialGamer score:bestCombo leaderboard:LEADERBOARD_COMBO];
	if ( bestMultiplier > 0 ) {
		NSLog(@"best multiplier: %i",bestMultiplier);
		[LGSocialGamer score:bestMultiplier leaderboard:LEADERBOARD_MULTIPLIER];
	}
	
	//set the final score
	[gameOverWindow setParameter:@"Points" :[NSString stringWithFormat:@"%i",finalScore]];
	
	//get the correct window to show (lite version or regular version)
	NSString *windowName = (lite) ? @"get-full.plist" : @"game-over.plist";
	
	//load the window from a file and show it
	[gameOverWindow fromFile:windowName :blockSheet];	
}

//show the messagebox to the user
//and wait for them to click something to continue
-(void) showMessageBox:(int) levelDone:(int) newBlockType {
	//quit if already showing
	if (showingMessage) return;
	showingMessage = true;
	
	//play the level up sound
	if ( soundEnabled) [[SimpleAudioEngine sharedEngine] playEffect:@"level-up-128.mp3"];
	
	//disable the menu touch behavior while showing message box
	[self disableMenuButton];
	
	//hide the level name and number from bottom right
	[levelDisplay setState:0];
	[levelNum setState:0];
	
	//start at the first page
	currentPage = 1;
	
	//update the title image
	[[title mainSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"level-done.png"]];
	
	
	//save level done for later
	_levelDone = levelDone;
	
	//update anchor state so it pops onscreen
	[newsAnchor setState:1];
	
	//make sure the message box is centered (we will fade it in)
	//235 - this will put the popup as far to the right as we can
	//but still leaves a slight bit on the right side to give context
	[messageBox mainSprite].position = ccp(MESSAGEBOX_XPOS,240);
	//[[messageBox mainSprite] setVisible:true];

	//enable the messagebox
	//so we can start capturing user input (touches)
	[messageBox setEnabled:true];
	
	//hide tweet page stuff
	[tweetStatus mainSprite].visible = false;
	[highScore mainSprite].visible = false;	

	//hide second page items
	[introducing mainSprite].visible = false;
	[newBlock mainSprite].visible = false;
	[newBlockName mainSprite].visible = false;
	//[newBlockDesc mainSprite].visible = false;
	
	//show first page items
	[levelName mainSprite].visible = true;
	//[movesUsed mainSprite].visible = true;	
	[pointsEarned mainSprite].visible = true;
	//[movesUsed mainSprite].visible = true;
	
	//setup the messagebox if this is the first time
	if ( messageBox == nil) [self setupMessageBox];

	//update the level name actor
	[(CCLabel *)[levelName mainSprite] setString:[NSString stringWithFormat:@"~%i~",levelDone]];	
	
	//determine points this level
	pointsForLevel = ([pointTracker getPoints]-lastPoints);	
	
	//clear points earned
	//and schedule the points earned to do something cool (after a sligh delay)
	[(TrackPoints *)[pointsEarned behavesAs:[TrackPoints class]] resetPoints];
	[(TrackPoints *)[pointsEarned behavesAs:[TrackPoints class]] addPoints:pointsForLevel afterDelay:1.0f];
	
	//this is where we count up how many coins the play er colected on the level by doing combos
	//and schedule the points earned to do something cool (after a sligh delay)
	//[(TrackPoints *)[movesUsed behavesAs:[TrackPoints class]] resetPoints];
	//[(TrackPoints *)[movesUsed behavesAs:[TrackPoints class]] addPoints:_coins afterDelay:1.0f];

	//update points earned this level
	//[(CCLabel *)[pointsEarned mainSprite] setString:[NSString stringWithFormat:@"%i Points",([pointTracker getPoints]-lastPoints)]];	
	
	
	//assume we are only showing 1 page for now
	pagesToShow = 1;
	_braggable = false; //assume no braggable event
	
	//save as last points we received
	lastPoints = [pointTracker getPoints];
	
	
	
	if ( newBlockType > 0 ) {
		//we are showing 3 pages 
		//(the second page will skip if nothing to brag about)
		pagesToShow = 3;
		
		//update new block rectangle
		//based on the one given to us
		CCSpriteFrame *newFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"intro-monster-%i.png",newBlockType]];
		[[newBlock mainSprite] setDisplayFrame:newFrame];
		
		//this sets the name from our monster info array
		[(CCLabel *)[newBlockName mainSprite] setString:monsters[newBlockType-1].monsterName];
		//[(CCLabel *)[newBlockDesc mainSprite] setString:monsters[newBlockType-1].monsterLikes];
		
		//record in settings that we just got this new monster
		//if we haven't already passed it in settings
		if ( [Settings getUnlockedMonsters] < newBlockType ) {
			//set the # of unlocked monsters within the game
			[Settings setUnlockedMonsters:newBlockType];
			
			//also flag this as a braggable event
			_braggable = true;
		}
		
		//set the tag on the monster picture to match the type
		[newBlock setTag:newBlockType];
		
	} else {
		//update new block rectangle
		//based on the one given to us
		[newBlock mainSprite].textureRect = CGRectMake(0,0,0,0);
		[newBlock mainSprite].visible = false;
		[newBlockName mainSprite].visible = false;
		//[newBlockDesc mainSprite].visible = false;
	}
	
	//make sure messageBox is on very top
	//not needed because we run in the play menu layer
	//[blockSheet reorderChild:[messageBox mainSprite] z:1];
	
	//we are now showin the messagebox
	showingMessage = true;

	//enable the messagebox (for touch in our case)
	//TESTING: why did we have this guy disabled here
	[messageBox setEnabled:true];
	
	//make sure the items on it are visible also
	[levelName mainSprite].visible = true;
	[pointsEarned mainSprite].visible = true;
	
	//shows the messagebox and waits
	[messageBox setState:1];
	
}

//show message box but not second page
-(void) showMessageBox:(int) levelDone {	
	//call internal
	[self showMessageBox:levelDone:0];
	
	//testing: always show brag page
	//_braggable = true;
	//pagesToShow = 3;
	//[newBlock setTag:1];	
}

//this hides the messagebox
-(void) hideMessageBox {
	//quit if not already showing
	if (!showingMessage) return;
	showingMessage = false;
	
	//clear out the multiplier and combo now that we submitted it
	bestCombo = 0;
	bestMultiplier = 0;	
	
	//enable the menu button when the other menu closes
	[self enableMenuButton];

	//change state of level name / num so it fades back in
	[levelNum setState:1];
	[levelDisplay setState:1];
	
	//update anchor state so it pops off screen
	[newsAnchor setState:0];
	
	
	//brings the messagbox away from the user
	//this will also trigger it to slide away and hide from the user
	[messageBox setState:0];
	
	//disable the box so it doesn't triggere events
	[messageBox setEnabled:false];
	
	//trigger event on play board
	[playBoard advanceLevel];
	
}

//this moves the messagebox dialog forward
-(void) nextPage {
	//this shows the "lost" dialog	
	if (currentPage == 1 && pagesToShow > 1) {
		//hide some items on the dialog
		[levelName mainSprite].visible = false;
		[pointsEarned mainSprite].visible = false;

		//these are page 2 actors
		[introducing mainSprite].visible = true;
		[newBlock mainSprite].visible = true;
		[newBlockName mainSprite].visible = true;
		[[title mainSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"lost-title.png"]];
		//[newBlockDesc mainSprite].visible = true;
		
		//social gaming - achieve new block type
		[LGSocialGamer achieve:[newBlock tag]-1 percentComplete:100];
		
	}
	//first we try to tweet
	if ( currentPage == 2 && pagesToShow > 2) {
		//save this level as the last level made
		//we don't do on first page because it slows down rendering of menu
		//[self saveLevel:_levelDone+1];
		//hide some items on the dialog
		[introducing mainSprite].visible = false;
		[newBlock mainSprite].visible = false;
		[newBlockName mainSprite].visible = false;
		
		//are we tweeting?
		//and if so is this a new record
		//note the false here is so we don't pause on the tweeting menu right now
		//until i fix it 
		autoTweet = true; //skip this for now
		//only ever show the brag page when there is something to brag about
		if ( _braggable ) {
			//disable events on the mesasge box so they pass through to the brag button
			//[messageBox setEnabled:false];
			
			//update the title text to "brag time!" message
			[[title mainSprite] setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"brag-time.png"]];
			
			//save the score
			[Settings setMaxScore:[pointTracker getPoints]];
			[Settings sync];
			
			//here we are tweeting to the world because
			//we just beat this level
			[highScore mainSprite].visible = true;
			[tweetStatus mainSprite].visible = true;
			
			
			//schedule next page after a second or so			
			//kick off the tweet
			//NSLog(@"would be tweeting, but need new api");
			//[quickTweet tweet:[NSString stringWithFormat:@"just beat JellyRow level %i with %i points.  beat that!",_levelDone,[pointTracker getPoints]]];
			
			
		} else {
			//just automatically move to next page
			currentPage++;
		}
		
	} 
	
	
	//finally we hide the messagebox and start the level back up
	if (pagesToShow == currentPage) {
		//update the level number we are now on (we are up one levle now)
		[levelTracker addPoints:1];	

		//this may be first page or second page
		//but if we are last page then hide it
		[self hideMessageBox];
	}
	
	//move to next page
	currentPage++;
}

//trigger the OF events slighly after the menu pops up
//so there is no percieved lag
-(void) socializeScores {
	//single level best score and high score
	//[LGSocialGamer score:pointsForLevel leaderboard:LEADERBOARD_SINGLELEVEL];
	[LGSocialGamer score:[pointTracker getPoints] leaderboard:LEADERBOARD_HIGHSCORE];
	
	//don't bother submitting if there isn't a multiplier
	if (bestCombo > 0 ) [LGSocialGamer score:bestCombo leaderboard:LEADERBOARD_COMBO];
	if ( bestMultiplier > 0 ) {
		[LGSocialGamer score:bestMultiplier leaderboard:LEADERBOARD_MULTIPLIER];
	}
	
	//social integraton - unlock birds eye for the first level completed
	if ( _levelDone == 1 ) {
		//show the new monster in open feint
		//this is a bit of a hack since we don't actually show the "lost" screen for birds eye
		[LGSocialGamer achieve:ACHIEVE_BIRDSEYE percentComplete:100];
	}
	
	
}

//add a new status for a specific block type
-(void) addStatus:(int) blockType {
	
	//we decide the position based on how many blocks are already created
	//CGPoint pos = ccp(STATUS_START + [statuses count]*STATUS_SPACER, 64/2);

	//get the colored and white sprite frames
	CCSpriteFrame *fullFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-colored.png",blockType]];
	CCSpriteFrame *emptyFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"monster-%i-white.png",blockType]];
	
	//create the status bar
	//CCSprite *statusSprite = [CCSprite spriteWithSpriteSheet:blockSheet rect:CGRectMake(50+[statuses count]*11,60,11,10)]; //this is the "full" rectangle
	CCSprite * statusSprite = [CCSprite spriteWithSpriteFrame:emptyFrame];
	
	[blockSheet addChild:statusSprite]; 
	//[statusSprite setPosition:CGPointMake(0, 0)];
	[statusSprite setScale:STATUS_SCALE];
	
	Actor * newStatus = [[Actor alloc] init:self];
	[newStatus setMainSprite:statusSprite];	
	[actors addObject:newStatus];
	StatusBar *sb = [[[[StatusBar alloc] withFullBar:fullFrame] withScale:0:10] withVertical];
	[newStatus setState:1];
	[newStatus addBehavior:sb];
	
	//this will make the block type status thing float away
	//automatically when we are done with it
	[newStatus addBehavior:[[FloatyKill alloc] withState:2]];
	
	//our type matches the block for which we collect
	[newStatus setType:blockType];
	
	//add to the status array
	[statusStack pushActor:newStatus];
	
	//add to our internal array
	//[statusTrackers addObject:sb];

	/*
	
	//run a little opening animation to make ourselves look sweet and cool
	[statusSprite setScale:0.00];	
	[statusSprite runAction:[CCSequence actions:			
			[CCDelayTime actionWithDuration:blockType * 0.1f + 0.25f],
			[CCEaseElastic actionWithAction:[CCScaleTo actionWithDuration:0.1f scale:STATUS_SCALE] period:0.1],
			[NamedAction Pulsate:0.2f:2:STATUS_SCALE],
			nil
	]];
	*/
	
	//immediately size this guy down and fade him out
	//[statusSprite setScale:0.25];
	//[statusSprite setOpacity:0];
	
	//make the status "spring forth" very neatly
	//[statusSprite runAction:[NamedAction DelayedAction:10.0:[NamedAction PopIn:10.0]]];
	
}

//trigger a save on the play board
-(void) triggerSave {
	//trigger the save
	[(Frantic *)playBoard saveLevel];
}

//this quits the game (returning to main menu)
-(void) quitGame {
	//first save
	[self triggerSave];
	
	//now tell the playboard scene to clean itself up
	//[playBoard clean];
	
	
	//now load main menu
	[[CCDirector sharedDirector] replaceScene:[CCRadialCWTransition transitionWithDuration:0.5f scene:(CCScene *)[MainMenu scene]]];
	
}

//resume gamelay when user clicks resume
-(void) resumeGame {
	//we are not showing our popup meu
	showingPopup = false;
	paused = false;
	
	//resumes play on layer and all child actors
	[playBoard resume];	
	
}

//pause gameplay while menu is shown
-(void) pauseGame {
	//HACK: we are showing our popup menu
	showingPopup = true;
	paused = true;
	
	//pause so nothing happens while the pause menu is displayed
	[playBoard pause];	
}

//show the pause menu
-(void) showPause {
	//do not trigger a pause if we are already paused
	//or if the menu is already showing
	if ( paused ) return;
	if ( showingMessage ) return;
	if ( _gameOverShowing ) return;
	
	//kill help instantly
	[self fadeHelp];
	[self fadeFinger];
	
	//pause the game
	[self pauseGame];
	
	//get some of the settings we have here	
	bool tutorialsOn = [Settings getTutorialEnabled];
	bool musicOn = [Settings getMusicEnabled];
	bool soundOn = [Settings getSoundEnabled];
	
	//setup and show the paused menu
	Window *pausedMenu = [[Window alloc] init:self];
	[pausedMenu setParameter:@"TutorialsOn" :(tutorialsOn) ? @"On":@"Off" ];
	[pausedMenu setParameter:@"MusicOn" :(musicOn) ? @"On":@"Off" ];
	[pausedMenu setParameter:@"SoundOn" :(soundOn) ? @"On":@"Off" ];
	[pausedMenu fromFile:@"pause-menu.plist" :blockSheet];	
}

//trigger a pause
-(void) triggerPause {
	//show the paused menu
	[self showPause];
}

// initialize your instance here
-(void) startScene {	
	
	//should we auto-tweet when the user finishes a level?
	autoTweet = [Settings getBool:@"autoTweet" :true];
	
	//is sound enabled?
	soundEnabled = [Settings getSoundEnabled];
	
	//if we are auto tweeting then create the tweet object
	//if (autoTweet) quickTweet = [[QuickTweet alloc] initWithDelegate:self];
	
	//no points earned yet
	lastPoints = 0;

	//initialize status related arrays
	//statuses = [[CCArray alloc] init];
	//statusTrackers = [[CCArray alloc] init];	
	
	//****BLOCK SHEET AND SPRITE SHEET FOR ALL MENUS****/

	//create the texture
	CCTexture2D *sprites = [[CCTextureCache sharedTextureCache] addImage:@"menu.png"];
	
	//setup sprite frame using that texture
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"menu.plist" texture:sprites];
	
	//setup the sprite sheet using the texture as well
	blockSheet = [CCSpriteSheet spriteSheetWithTexture:sprites];
	
	//this blocksheet contains all the images for the menus
	//blockSheet = [CCSpriteSheet spriteSheetWithFile:@"menu.png" capacity:1];
	[self addChild:blockSheet z:0 tag:1];		
	
	//****BLOCK SHEET FOR HELP (TODO: MOVE TO FIRST REQUEST OF HELP)****/
	
	//create the texture
	CCTexture2D *helpSprites = [[CCTextureCache sharedTextureCache] addImage:@"help.png"];
	
	//setup sprite frame using that texture
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"help.plist" texture:helpSprites];
	
	//setup the sprite sheet using the texture as well
	helpSheet = [CCSpriteSheet spriteSheetWithTexture:helpSprites];
	
	//this blocksheet contains all the images for the menus
	//blockSheet = [CCSpriteSheet spriteSheetWithFile:@"menu.png" capacity:1];
	[self addChild:helpSheet z:0 tag:2];		
	
	//*****MENUS*****//
	
	//setup the bar at the top
	CCSprite *sprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"menu-only.png"]];
	//CCSprite *sprite = [CCSprite spriteWithSpriteSheet:blockSheet rect:CGRectMake(320,0,320,480)];
	[blockSheet addChild:sprite]; 
	sprite.position = ccp( 160, 240);
	Actor *newActor = [[Actor alloc] init:self];
	[newActor setMainSprite:sprite];	
	[actors addObject:newActor];
	
	//create the "menu" menu
	//and tell it to load the main menu when the user clicks on it
	//menu = [self addTextActor:ccp(5, screenSize.height-16):@"MENU":@"CCZoinks":24:LM_LIGHTBLUE];
	menu = [self addTextActor:ccp(30, screenSize.height-16):@"MENU":@"CCZoinks":24:LM_LIGHTBLUE];
	[menu addBehavior:[ShadowText alloc]]; //give a shadow to the menu text
	[menu addBehavior:[[[StateAction alloc] withTouchBegan] withAction:[NamedAction Wiggle]]];
	[menu addBehavior:[(TouchSelector *)[[TouchSelector alloc] withTouch] withSelector:self :@selector(showPause)]]; //pause the gameplay
	//[menu addBehavior:[(ShowWindow *)[[ShowWindow alloc] withTouch] withWindow:@"pause-menu.plist" :blockSheet]]; //show the pause menu
	
	//staright back to main menu for now
	//[[menu mainSprite] setAnchorPoint:ccp(0,0.5)];	

	//create the points item and store it
	//text center is on far right (right aligned in essence)
	points = [self addTextActor:ccp(170, screenSize.height-17):@"0":@"BadaBoom BB":16:LM_YELLOW ];
	[[points mainSprite] setAnchorPoint:ccp(1,0.5)];
	pointTracker = [[[TrackPoints alloc] withTitle:@"%i"] withCountBy:2];
	[points  addBehavior:pointTracker];	
	
	//setup level display
	levelDisplay = [self addTextActor:ccp(8, 64/2-3):@"Level":@"CCZoinks":30:LM_LIGHTBLUE ];
	[levelDisplay addBehavior:[ShadowText alloc]];
	[[levelDisplay mainSprite] setAnchorPoint:ccp(0,0.5)];
	
	//setup level num er
	levelNum = [self addTextActor:ccp(112+8, 64/2-3):@"1":@"CCZoinks":30:LM_YELLOW ];
	[[levelNum mainSprite] setAnchorPoint:ccp(1,0.5)];
	levelTracker = [[[TrackPoints alloc] withTitle:@"%i"] withCountBy:1];
	[levelNum  addBehavior:levelTracker];
	
	//display and level # start at state 1 (visible)
	[levelDisplay setState:1];
	[levelNum setState:1];
	
	//level display fades in and out based on state
	[levelDisplay addBehavior:[(StateAction *)[[StateAction alloc] withState:0] withAction:[CCFadeOut actionWithDuration:0.5]]];
	[levelDisplay addBehavior:[(StateAction *)[[StateAction alloc] withState:1] withAction:[CCFadeIn actionWithDuration:0.5]]];
	
	//so does the level nmber
	[levelNum addBehavior:[(StateAction *)[[StateAction alloc] withState:0] withAction:[CCFadeOut actionWithDuration:0.5]]];
	[levelNum addBehavior:[(StateAction *)[[StateAction alloc] withState:1] withAction:[CCFadeIn actionWithDuration:0.5]]];

	//we should start on level 1
	[levelTracker resetPoints];
	[levelTracker addPoints:1];

	//create the messagebox actor
	//to start we are not showing the message box
	[self setupMessageBox];
	showingMessage = false;
	
	//create life stacker
	lifeStack = [[ActorStack alloc] initWithSpacer:32:CGPointMake(208, screenSize.height-18)];
	
	//create the status stacker
	statusStack = [[ActorStack alloc] initWithSpacer:STATUS_SPACER:CGPointMake(STATUS_START, STATUS_YVALUE)];
}

//update the # of coins available
-(void) updateCoins:(int) coins {
	_coins = coins;
}

//update the # of available lives
-(void) updateLives:(uint) lives {
	//is the # of lives more than we have now?
	if ( lives > [lifeStack count] ) {
		//this is simple - add all a heart for each life
		for (uint c = [lifeStack count]; c < lives; c++ ) {
			Actor *a = [[Actor alloc] init:self];
			CCSprite *s = CCSpriteByFrame(@"heart.png");
			//CCSprite *s = CCSpriteByFrame(@"Heart.png");
			[blockSheet addChild:s];
			[s setScale:0.75];
			[a setMainSprite:s];
			[lifeStack pushActor:a];
		}
	} else if ( lives < [lifeStack count] ) {
		//we have fewer now - pop the first heart
		//so it looks cool
		[lifeStack popActor];
	}
	
}

//remove

//this gets fired when we are done tweeting
-(void) doneTweeting:(NSString *) result {
	//testing:
	//NSLog(@"res: %@",result);
	//move to next page after a little bit
	//[(CCLabel *)[tweetStatus mainSprite] setString:@"done"];
	[self performSelector:@selector(nextPage) withObject:nil afterDelay:1.0f];
	//[self nextPage];
	
}



//return a reference to the points actor
-(Actor *) getPoints {
	//return the internal value
	return points;
}


//return a reference to the points actor
-(Actor *) getStatus {
	//return the internal value
	return status;
}

//various updaters etc for status related info
-(void) updateStatus:(int) actorType:(float) newStatus {	
	//get the actor
	//and get the status tracker
	
	Actor *stat = [statusStack actorWithType:actorType];
	StatusBar *sb = (StatusBar *)[stat behavesAs:[StatusBar class]];
	
	//get a delta on status
	//and adjust monster count accordingly
	//float oldStatus = [sb getStatus];
	//[monsterCountTracker addPoints:(oldStatus - newStatus)];
	
	//update its status
	[sb setStatus:newStatus];
	
}

//various updaters etc for status related info
-(void) updateStatus:(int) actorType:(float) newStatus : (float) newMax {	
	//get the actor
	//and get the status tracker
	Actor *stat = [statusStack actorWithType:actorType];
	StatusBar *sb = (StatusBar *)[stat behavesAs:[StatusBar class]];

	//get a delta on status
	//and adjust monster count accordingly
	//float oldStatus = [sb getStatus];
	float oldMax = [sb getMax];
	
	//update the max value if it changed
	if ( oldMax != newMax ) {
		//update status bar
		[sb setMax:newMax];
		
	}
	
	//update its status
	[sb setStatus:newStatus];
	
}

-(void) resetStatus:(int) actorType:(float) min:(float) max {	
	//get the actor
	//and get the status tracker
	
	Actor *stat = [statusStack actorWithType:actorType];
	StatusBar *sb = (StatusBar *)[stat behavesAs:[StatusBar class]];	
	
	//update the status bar status
	[sb resetStatus:min:max];
	//NSLog(@"resetStatus:End");	
	
}

//clean up our menu we are done
-(void) dealloc {
	//clean up status bar related arrays
	//[statuses release];
	//[statusTrackers release];
	
	//there is a lot of other crap to clean up we should do here
	[super dealloc];
}

//this will pop a completed status off the menu
-(void) popStatus:(int) blockType {
	
	//spawn a particle effect for this status
	Actor * poppedStatus = [statusStack actorWithType:blockType];
	CCQuadParticleSystem *cpf = [CCQuadParticleSystem particleWithFile:@"StarPoints.4.plist"];
	cpf.autoRemoveOnFinish = true;
	cpf.position = [[poppedStatus mainSprite] position];
	cpf.totalParticles = 500;
	cpf.posVar = ccp(50,50);	
	[self addChild:cpf];	
	
	//pop the status
	[statusStack popActorWithType:blockType];
}

//clear all statuses
-(void) clearStatuses {
	//just call on actor stack
	[statusStack clear];
}

//this will reset all statuses (adding new ones taht is)
-(void) resetStatuses:(int) statusCount {
	//kill any existing statuses if they are there at all
	[self clearStatuses];
	
	//setup all status bars specified
	for (int c = 0; c < statusCount; c++ ) {
		//add a new status bar for this guy
		[self addStatus:c+1];
	}
	
}


//update our # of bombs collected during the level
-(void) updateBestBombs:(int) bombs {
	if ( bombs >= bestBombs) bestBombs = bombs;
}

//update methods for multipliers
-(void) updateBestMultiplier:(int) multipliers {
	//update our best value
	if ( multipliers >= bestMultiplier) bestMultiplier = multipliers;
}

//update best combo move for the level
-(void) updateBestCombo:(int) combos {
	//update our best value
	if (combos >= bestCombo ) bestCombo = combos;
}


//testing:
-(void) checkStatus:(int) stat {
	return;
}

//get and set last points used when saving
-(int) getLastPoints {
	return lastPoints;
}
-(void) setLastPoints:(int) updatedPoints{
	lastPoints = updatedPoints;
}


/***HELP OVERLAY LOGIC***/


//show the help text
-(void) showHelp:(NSString *) helpFrame {
	//kill existing help actor if needed (canceling not relevant here)
	[self killHelp];
	
	//help as an image overlay
	CCSprite *helpSprite = [CCSprite spriteWithFile:helpFrame];
	//CCSprite *helpSprite = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:helpFrame]];
	[helpSprite setPosition:ccp(160,240)];
	[self addChild:helpSprite z:9];
	helpActor = [[Actor alloc] init:self];	
	[helpActor setMainSprite:helpSprite];
	[self addActor:helpActor];
	
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
	  [CCCallFunc actionWithTarget:self selector:@selector(fadeHelp)], //this will also clean up our reference properly
	  nil		
	  ]
	 
	 ];
	
}

//this kills the help overlay frame
-(void) killHelp {
	//remove the help actor
	[self removeActor:helpActor];
	helpActor = nil;
}


//are we showing help or not?
-(bool) showingFinger {
	return finger != nil;
}


//are we showing help or not?
-(bool) showingHelp {
	return helpActor != nil;
}

//fade the finger out
-(void) fadeFinger {
		//kill the finger
		if ( finger != nil) {
			//Fade To is better than FadeOut, because it starts at the current opacity
				[[finger mainSprite] runAction:[CCSequence actions:
											[CCFadeTo actionWithDuration:0.5 opacity:0],
											[CCCallFunc actionWithTarget:self selector:@selector(killFinger)],
											nil
											]];
		}
		//that's it
}

//this actually kills the finger
-(void) killFinger {
	//kill finger if needed
	[self removeActor:finger];
	finger = nil;
}

//create the finger actor
-(Actor *) createFinger:(CGPoint) startPoint {
	//setup the finger sprite and actor
	//and make sure the finger is at the top of the z-order
	//finger = [menu createFinger:startPoint];
	finger = [Actor alloc];
	CCSprite * fingerSprite = [CCSprite spriteWithSpriteFrame:[ [CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"help-finger.png"]];	
	
	//finger cannot cancel yet
	//_fingerCanCancel = false;
	
	//add the finger to the scene
	[self addChild:fingerSprite z:10];
	[actors addObject:finger];
	
	//set the main sprite reference on the actor to the finger sprite
	[finger setMainSprite:fingerSprite];
	
	//setup the initial state of the finger
	[fingerSprite setOpacity:0];
	[fingerSprite setPosition:startPoint];
	
	//return the finger to caller
	return finger;
	
}


//fade out the help
-(void) fadeHelp {
	[[helpActor mainSprite] runAction:
	 [CCSequence actions:
	  [CCFadeTo actionWithDuration:0.5f opacity:0],
	  [CCCallFunc actionWithTarget:self selector:@selector(killHelp)],
	  nil
	  ]];
	
}

//toggle whether tutorials are on or off
-(void) toggleTutorials:(Actor *) menuOption {
	//get the current value
	bool tutorialEnabled = ![Settings getTutorialEnabled];
	
	//update the value
	[Settings setTutorialEnabled:tutorialEnabled];
	[Settings sync];
	
	//update the menu option text
	//and sync the shadow text behavior
	//TODO: this type of behavior should attach itself to the setter and update when its ready
	[(CCLabel *)[menuOption mainSprite] setString:[NSString stringWithFormat:@"Help: %@",(tutorialEnabled) ? @"On":@"Off"]];
	[(ShadowText *)[menuOption behavesAs:[ShadowText class]] updateText];
	

	//we are done
	
}

//toggle whether music is on or off
-(void) toggleMusic:(Actor *) menuOption {
	//get the current value
	bool musicOn = ! [Settings getMusicEnabled];
	
	//if music is playing stop it
	if ( !musicOn ) [[CDAudioManager sharedManager] stopBackgroundMusic];
	
	//if music is not playing start it
	if ( musicOn ) [[CDAudioManager sharedManager] playBackgroundMusic:@"gameplay-song-128.mp3" loop:true];
	
	//update the value
	[Settings setMusicEnabled:musicOn];
	[Settings sync];
	
	//update the menu option text
	//and sync the shadow text behavior
	//TODO: this type of behavior should attach itself to the setter and update when its ready
	[(CCLabel *)[menuOption mainSprite] setString:[NSString stringWithFormat:@"Music: %@",(musicOn) ? @"On":@"Off"]];
	[(ShadowText *)[menuOption behavesAs:[ShadowText class]] updateText];
	
	//we are done
}

//toggle whether sound is on or off
-(void) toggleSound:(Actor *) menuOption {
	//get the current value
	bool soundOn = ! [Settings getSoundEnabled];
	
	//update our internal value (for cheering when completing levels, etc)
	soundEnabled = soundOn;
	
	//update the value
	[Settings setSoundEnabled:soundOn];
	[Settings sync];
	
	//update in our play board scene
	//so the change takes effect right now
	[playBoard setSoundEnabled:soundOn];
	
	//update the menu option text
	//and sync the shadow text behavior
	//TODO: this type of behavior should attach itself to the setter and update when its ready
	[(CCLabel *)[menuOption mainSprite] setString:[NSString stringWithFormat:@"Sound: %@",(soundOn) ? @"On":@"Off"]];
	[(ShadowText *)[menuOption behavesAs:[ShadowText class]] updateText];
	
	//we are done
}

/***FREE VERSION STUFF***/

-(void) buyFull {	
	//launch the full application url (using analytics so we know how many clicks this button gets)
	[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString: FULL_VERSION_URL]];
}


@end
