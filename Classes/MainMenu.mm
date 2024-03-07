//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


//social gaming
#import "achievements.h"
#import "GameKitHelper.h"

// Import the interfaces
#import "MainMenu.h"
#import "PickConstants.h"
#import "config.h"
#import "Settings.h"

/***OUR SCENES***/
#import "FranticScores.h"
#import "FranticScene.h"
#import "IntroScene.h"
#import "AboutScene.h"
#import "OptionScene.h"
#import "ScoreMenuScene.h"


/***TESTING FOR GAME FEED***/
#import "testappAppDelegate.h"
#import "RootViewController.h"


//***GLOBALS SCOPED WITHIN THIS CLASS***//


//because this is the first and only game where
//i released without social and now have to detect changes
//i am adding this here
bool LGSOCIAL_Synced;

//main menu implementation
@implementation MainMenu




+(id) sceneNoMusic {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenu *layer = [MainMenu node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;	
}

+(id) scene {
	//start our music
	//only play background music if enabled
	if ( [Settings getMusicEnabled] ) [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"menu-song-128.mp3" loop:false];
	
	//load the scene without music
	return [MainMenu sceneNoMusic];
	
}

-(void) hideTextMenus:(bool) hidden { 
	//hide both "thoughtful" and "frantic" so they don't show over our menu
	[[[monsterMenu assetWithTag:-1] mainSprite] setVisible:!hidden];
	[[[monsterMenu assetWithTag:-2] mainSprite] setVisible:!hidden];
    
    //also hide game feed
    //if ( hidden) [LGSocialGamer hideGameFeed];
    //if (!hidden) [LGSocialGamer showGameFeed];
}


//this method gets called for all menu items that are clicked
-(void) menuClicked:(id) menuItem {
	//HACK: update reference so we are looking at the sprite
	//not the actor (for main menu)...
	int menuTag=-1;
	CCSprite * sender;
	if ( [menuItem isKindOfClass:[Actor class]] ) {
		menuTag = [(Actor *)menuItem tag];
		sender = (CCSprite *)[(Actor *)menuItem mainSprite];
		
	} else {
		//sender is sprite
		//but tag is from actor
		sender = (CCSprite *)menuItem;		
		menuTag = [(Actor *)[(CCSprite *)menuItem userData] tag];
	}
	//were we passed an actor or a sprite
	//get the sprite form the actor
	
	//menu items
	Class scenes[5] = {
		nil,	//frantic
		nil,	//thoughtful
		[ScoreMenuScene class],	//scores
		//[FranticScores class], //for now straight to frantic score menu
		[OptionScene class],	//options
		[AboutScene class]	//about
	};
	
	//menu transitions
	Class transitions[4] = {
		[CCSplitColsTransition class], //split columns
		[CCSplitRowsTransition class], //split rows
		[CCFadeTRTransition class],
		[CCFadeBLTransition class]
	};

	//HACK: setup appropriate scene classes based on if we are showing
	//the intro movie or not
	if ( showIntro) {
		scenes[0] = [IntroScene class];
		scenes[1] = [IntroScene class];
	} else {
		scenes[0] = [FranticScene class];
		scenes[1] = [FranticScene class];		
	}
	
	//create the appropriate scene
	menuTag = (menuTag < 0 ) ? -1 * menuTag : menuTag;
	menuTag--;
	
	
	int tranIDX = (CCRANDOM_0_1() * 4);
	Class sceneClass = scenes[menuTag];
	Class tran = transitions[tranIDX];
	CCScene *newScene;
	
	//option for thoughtful
	if ( menuTag+1 == 2 ) {
		newScene = (CCScene *) [sceneClass thoughtfulScene:true];
	} else {
		newScene = (CCScene *)[sceneClass scene];
	}

	//transition to the new scene
	[[CCDirector sharedDirector] replaceScene:[tran transitionWithDuration:0.5f scene:newScene]];
}


//this starts a new campaign
-(void) newCampaign:(Actor *) menuItem {
	//we are no longer showing the popup
	showingPopup = false;	
	showIntro = true;
	
    //remove game feed (recycle resources)
    [LGSocialGamer removeGameFeed];

	//HACK: clear the level # in settings for this mode
	//and then when the thing starts it will start over
	if ( abs([clickedMenu tag]) == 1) {
		//clear frantic mode
		[Settings setInt:@"franticLevelNumber" :1];
	} else {
		//clear thoughtful mode
		[Settings setInt:@"thoughtfulLevelNumber" :1];
	}
	[Settings sync];
	
	//continue with the normal function
	[self menuClicked:clickedMenu];
}

//this resumes an existing campaign
-(void) resumeCampaign:(Actor *) menuItem {
    //remove game feed (recycle resources)
    [LGSocialGamer removeGameFeed];
    
	//we are no longer showing the popup
	showingPopup = false;

	//call the normal function
	[self menuClicked:clickedMenu];	
}

//this displays the resume or continue popup menu for frantic
-(void) popupResume:(Actor *) actor {
	//quit if already showing a monster
	if ( showingPopup) return;
	
    //HACK: get the "menuItem", reall just a sprite
	CCSprite *menuItem = [actor mainSprite];
	
	//hide text menus
	[self hideTextMenus:true];
	
	
	//disable the main menu 
	[monsterMenu setEnabled:false];
	
	//HACK:  get last level # and go directly to scene
	//if that level # is 1 - meaning no saved ata
	//and then when the thing starts it will start over
	int lastLevel = 0;
	if ( [actor tag] == -1) {
		//clear frantic mode
		lastLevel = [Settings getInt:@"franticLevelNumber" :1];
	} else {
		//clear thoughtful mode
		lastLevel = [Settings getInt:@"thoughtfulLevelNumber" :1];
	}
	
	//if at level 1 then don't show this popup
	if ( lastLevel == 1 ) {
		//go directly to scene, bypass this popup
		showingPopup = false;
		showIntro = true; //show intro on first game
		[self menuClicked:actor];		
		return;
	}
	
	//we are now showing the popup
	showingPopup = true;
	
	//save the tag for the menu item that was clicked
	//we need to pass this along when the user picks to resume/new
	clickedMenu = menuItem; 
	
	//create a popup window for the defined mosnter
	Window *resumePopup = [[Window alloc] init:self];
	[self addActor:resumePopup];
	[resumePopup setDelegate:self];
	[resumePopup fromFile:@"resume-menu.plist":menuSheet];
	
}

//we respond to this selector when popup menus are closed
//that way we can gracefully disable touch events on us while its open
-(void) popupWindowClosed:(Actor *) window {
	//we are no longer showing a popup
	showingPopup = false;
	
	//hide text menus
	[self hideTextMenus:false];

	//re-enable the main menu
	//disable the main menu 
	[monsterMenu setEnabled:true];	
    
    //when done showing amonster, display the game feed
    //[LGSocialGamer showGameFeed];
    

}

//this gets called once the monster popup window closes and it shows gamefeed
-(void) showGameFeed {
    //show the game feed
    [LGSocialGamer showGameFeed];
}

//show a monster
-(void) showMonster: (Actor *) monsterPic {
	//quit if already showing a monster
	if ( showingPopup) return;
	showingPopup = true;
	
    //while showing monster, hide the game feed
    [LGSocialGamer hideGameFeed];
    
	//disable all main menu items
	[monsterMenu setEnabled:false];
	
	//hide text menus
	[self hideTextMenus:true];
	
	//create a popup window for the defined mosnter
	Window *monsterPopup = [[Window alloc] init:self];
	[monsterPopup setParameter:@"MonsterNum" :[NSString stringWithFormat:@"%i",[monsterPic tag]]];
	[monsterPopup setDelegate:self];
	[monsterPopup fromFile:@"monster-popup.plist":menuSheet];
	
	//HACK: add the window after we added all the assets
	//so that they pickup events before the e window does (tap events specifically)
	[self addActor:monsterPopup];
	
	//trigger the "monster bio" achievement
	//since the user is viewing a monster
	[LGSocialGamer achieve:ACHIEVE_MONSTERBIO percentComplete:100];			
	
}


//show unlocked monsters
-(void) showUnlockedMonsters {
	//get the # of uynlocked monsters
	int unlockedMonsters = [Settings getUnlockedMonsters];

    
	//create the window for all monsters
	//this is not actually a window, but we can use functionality in this way
	monsterMenu = [[Window alloc] init:self];
	[self addActor:monsterMenu];
	
	//define the "free version" message
	NSString *freeVersion = (LITE_VERSION ) ? @"True" : @"False";
	[monsterMenu setParameter:@"Free-Version":freeVersion];
	
	//go through all monsters and hide or unhide appropriately
	for (int c = 1; c <= 12; c++ ) {
		//set the parameter whether this monster is hidden or not
		NSString *loaded = (c <= unlockedMonsters ) ? @"True" : @"False";
		[monsterMenu setParameter:[NSString stringWithFormat:@"Monster-%i-Loaded",c]:loaded];		
	}
	
	//load menu from file
	[monsterMenu fromFile:@"monster-menu.plist":menuSheet];
    
}


//this method unlocks achievements already cracked by the user
-(void) unlockExistingAchievements {
	//get the current # of unlocked monsters
	int currentMonsters = [Settings getUnlockedMonsters];
	
	//run through all those monsters
	for (int c = 1; c <= currentMonsters; c++ ) {
		//submit each monster achievement to OpenFient
		[LGSocialGamer performSelector:@selector(achieve:) withObject:[LGAchievement achievementWithValues:c-1 :100] afterDelay:c ];
		//[LGSocialGamer achieve:c-1 percentComplete:100];
	}
    

}

//this method submits existing scores for the user
-(void) submitExistingScores {
	//there is only one score for the user
	//that we saved with the first version
	//OF integration - submit score for high scores
	[LGSocialGamer score:[Settings getMaxScore] leaderboard:LEADERBOARD_HIGHSCORE];
	
}

//brag about a monster, given the asset that you clicked it on
//which contains the monster # (also achievement #)
-(void) bragAboutMonster:(Actor *) bragButton {
	//get the monster # from the brag button
	int monsterNum = [bragButton tag];
	
	//brag about that achievement
	//note that the achievement id is one less than the monster #
	[LGSocialGamer bragAchievement:monsterNum-1];
}

//trigger invite method
-(void) inviteFriends {
	[LGSocialGamer inviteFriends];
}


//never rate again
-(void) rateNever {[LGSocialGamer rateNever];}
-(void) rateLater {[LGSocialGamer rateLater];}

//trigger a rating from the user
-(void) rateGame {[LGSocialGamer promptForReview];}

//this shows the social tickler menu for the user
-(void) showSocialTickler {
	//we are now showing a popup menu
	showingPopup = true;
	
	//hide text menus (we have to do this because they are at a higher z then the sprite sheet)
	[self hideTextMenus:true];	
	
	//disable the main menu 
	[monsterMenu setEnabled:false];
	
	//show the social tickler menu after a certain # of tries
	//this is better than the "please rate us" crap (i think)
	Window *socialTickler = [[Window alloc] init:self];
	[self addActor:socialTickler];
	//TODO: update this so we launch appropriate invite (i.e. GC invite if enabled)
	//[socialTickler setParameter:@"CanInviteFriends" :([LGSocialGamer usingFeint]) ? "True":"False" ];
	[socialTickler setDelegate:self];
	[socialTickler fromFile:@"social-tickler.plist":menuSheet];
	
	
}

//this method syncs with OF for the first time
//it can be called amny times but
//only does something the first time
-(void) loginComplete {
	//unlock achievements for first run
	//this will only happen once
	//7-11-11: JBC - only prompt for social tickler when monsters have been unlocked (so the app was installed before)	
	int existingMonsters = [Settings getUnlockedMonsters];
	if ( ! [Settings getBool:@"LGSocial_INITIAL_SYNC" : false] && existingMonsters > 0) {
		//sync with open feint
		[self unlockExistingAchievements];
		[self submitExistingScores];

		//update the setting
		[Settings setBool:@"LGSocial_INITIAL_SYNC" :true];
		[Settings sync];
		
		//if they had the old version, let's ask them to rate it now
		[self showSocialTickler];
		
	}
	
	//trigger the social tickler menu to the user
	//if ( [LGSocialGamer timeToRate] ) [self showSocialTickler];
	
}


//here we setup the splash screen
//then on touch we launch the main menu
-(void) startScene {
	//only try to login once
	if ( ![LGSocialGamer initialized]) {
		//NOTE: only for Lost Monsters and Lost Monsters Free
		//we need to sync the old leaderboard information from before we were using "LGSocialGamer"
		//from now on - even if the user doesn't use OpenFeint, we will track their stuff here
		
		//trigger a method once login is complete
		//this method does the initial sync but it also
		//triggers some social gaming prompts as appropriate
		[LGSocialGamer initSocialCallBack:self selector:@selector(loginComplete)];
		
	}
	
	//we are the social delegate when we are in the fore-front
	[LGSocialGamer setSocialDelegate:self];
	
	//testing game center and OF integration
	//[[GameKitHelper sharedGameKitHelper] resetAchievements];

	//load the block sheet for all sprites in this menu layer
	menuSheet = [self spriteSheetWithFrame:@"main-menu.png":@"main-menu.plist"];
	[self addChild:menuSheet z:2];

	//initialize monsters for the main menu
	[self showUnlockedMonsters];	
	
	//note: if we are not using feint, then we should trigger the social tickler now
	//otherwise it gets called after login is complete
	if ( [LGSocialGamer timeToRate] ) {
		//show our fancy rating dialog
		[self showSocialTickler];
	}
    
    
    //show game feed (or initialize if first run)
    [LGSocialGamer showGameFeed];
}

/***FREE VERSION STUFF***/

-(void) buyFull {	
	//launch the full application url (using analytics so we know how many clicks this button gets)
	[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString: FULL_VERSION_URL]];
}

/***SCENE SETTINGS***/

-(void) dealloc {
    //hide game feed since its only visible in the main menu
    [LGSocialGamer hideGameFeed];
    
	//release the monster menu
	[monsterMenu release];
	
	//cleanup parent
	//[super dealloc];
}

/***GAME CENTER INTEGRATION***/
/*

#pragma mark GameKitHelper delegate methods
-(void) onLocalPlayerAuthenticationChanged
{
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	CCLOG(@"LocalPlayer isAuthenticated changed to: %@", localPlayer.authenticated ? @"YES" : @"NO");
	
	if (localPlayer.authenticated)
	{
		GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
		[gkHelper getLocalPlayerFriends];
		//[gkHelper resetAchievements];
	}	
}

-(void) onFriendListReceived:(NSArray*)friends
{
	CCLOG(@"onFriendListReceived: %@", [friends description]);
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper getPlayerInfo:friends];
}

-(void) onPlayerInfoReceived:(NSArray*)players
{
	CCLOG(@"onPlayerInfoReceived: %@", [players description]);
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper submitScore:1234 category:@"Playtime"];
	
	//[gkHelper showLeaderboard];
	
	GKMatchRequest* request = [[[GKMatchRequest alloc] init] autorelease];
	request.minPlayers = 2;
	request.maxPlayers = 4;
	
	//GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper showMatchmakerWithRequest:request];
	[gkHelper queryMatchmakingActivity];
}

-(void) onScoresSubmitted:(bool)success
{
	CCLOG(@"onScoresSubmitted: %@", success ? @"YES" : @"NO");
}

-(void) onScoresReceived:(NSArray*)scores
{
	CCLOG(@"onScoresReceived: %@", [scores description]);
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper showAchievements];
}

-(void) onAchievementReported:(GKAchievement*)achievement
{
	CCLOG(@"onAchievementReported: %@", achievement);
}

-(void) onAchievementsLoaded:(NSDictionary*)achievements
{
	CCLOG(@"onLocalPlayerAchievementsLoaded: %@", [achievements description]);
}

-(void) onResetAchievements:(bool)success
{
	CCLOG(@"onResetAchievements: %@", success ? @"YES" : @"NO");
}

-(void) onLeaderboardViewDismissed
{
	CCLOG(@"onLeaderboardViewDismissed");
	
	GameKitHelper* gkHelper = [GameKitHelper sharedGameKitHelper];
	[gkHelper retrieveTopTenAllTimeGlobalScores];
}

-(void) onAchievementsViewDismissed
{
	CCLOG(@"onAchievementsViewDismissed");
}

-(void) onReceivedMatchmakingActivity:(NSInteger)activity
{
	CCLOG(@"receivedMatchmakingActivity: %i", activity);
}

-(void) onMatchFound:(GKMatch*)match
{
	CCLOG(@"onMatchFound: %@", match);
}

-(void) onPlayersAddedToMatch:(bool)success
{
	CCLOG(@"onPlayersAddedToMatch: %@", success ? @"YES" : @"NO");
}

-(void) onMatchmakingViewDismissed
{
	CCLOG(@"onMatchmakingViewDismissed");
}
-(void) onMatchmakingViewError
{
	CCLOG(@"onMatchmakingViewError");
}

-(void) onPlayerConnected:(NSString*)playerID
{
	CCLOG(@"onPlayerConnected: %@", playerID);
}

-(void) onPlayerDisconnected:(NSString*)playerID
{
	CCLOG(@"onPlayerDisconnected: %@", playerID);
}

-(void) onStartMatch
{
	CCLOG(@"onStartMatch");
}

-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID
{
	CCLOG(@"onReceivedData: %@ fromPlayer: %@", data, playerID);
}
*/


/*****SOCIAL TICKLER METHODS*****/

//this is the "receive social bonus" method
-(void) receiveSocialBonus {
	//play a sound to the user know
	if ( [Settings getSoundEnabled] ) [[SimpleAudioEngine sharedEngine] playEffect:@"points.mp3"];
	
	//since we are not currently playing, just add to bonus setting
	[Settings incrementBonus];
}

//show facebook and twitter
-(void) twitClick {[LGSocialGamer showTwitter];}
-(void) faceClick {[LGSocialGamer showFaceBook];}


@end

