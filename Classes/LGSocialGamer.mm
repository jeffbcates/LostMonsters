//
//  LGSocialGamer.mm
//  LostMonsters
//
//  Created by Jeff Cates on 6/10/11.
//  Copyright 2011 leftygames. All rights reserved.
//

//note that achievements is game specific
//and should only be called here
#import "config.h"
#import "LGSocialGamer.h"
#import "LGSocialGamerConfig.h"
#import "testappAppDelegate.h"
#import "OpenFeint/OpenFeint.h"
#import "OpenFeint/OpenFeint+Dashboard.h"
#import "OpenFeint/OpenFeint+UserOptions.h"
#import "OpenFeint/OFAnnouncement.h"
#import "OpenFeint/OFGameFeedView.h"

//game center integration
#import "GameKitHelper.h"

//rating related settings
#define LGSocialGamer_RateDEBUG NO
/*
 Users will need to have the same version of your app installed for this many
 days before they will be prompted to rate it.
 */
#define LGSocialGamer_DAYS_UNTIL_PROMPT		5		// double

/*
 An example of a 'use' would be if the user launched the app. Bringing the app
 into the foreground (on devices that support it) would also be considered
 a 'use'. You tell Appirater about these events using the two methods:
 [Appirater appLaunched:]
 [Appirater appEnteredForeground:]
 
 Users need to 'use' the same version of the app this many times before
 before they will be prompted to rate it.
 */
#define LGSocialGamer_USES_UNTIL_PROMPT		5		// integer

/*
 A significant event can be anything you want to be in your app. In a
 telephone app, a significant event might be placing or receiving a call.
 In a game, it might be beating a level or a boss. This is just another
 layer of filtering that can be used to make sure that only the most
 loyal of your users are being prompted to rate you on the app store.
 If you leave this at a value of -1, then this won't be a criteria
 used for rating. To tell Appirater that the user has performed
 a significant event, call the method:
 [Appirater userDidSignificantEvent:];
 */

//NOTE: IN OUR IMPLEMENTATION IT IS ALWAYS THE # OF ACHIEVEMENTS REQUIRED BEFORE RATING

#define LGSocialGamer_SIG_EVENTS_UNTIL_PROMPT	-1	// integer

/*
 Once the rating alert is presented to the user, they might select
 'Remind me later'. This value specifies how long (in days) Appirater
 will wait before reminding them.
 */
#define LGSocialGamer_TIME_BEFORE_REMINDING		1	// double

NSString *const kAppiraterFirstUseDate				= @"kAppiraterFirstUseDate";
NSString *const kAppiraterUseCount					= @"kAppiraterUseCount";
NSString *const kAppiraterSignificantEventCount		= @"kAppiraterSignificantEventCount";
NSString *const kAppiraterCurrentVersion			= @"kAppiraterCurrentVersion";
NSString *const kAppiraterRatedCurrentVersion		= @"kAppiraterRatedCurrentVersion";
NSString *const kAppiraterDeclinedToRate			= @"kAppiraterDeclinedToRate";
NSString *const kAppiraterReminderRequestDate		= @"kAppiraterReminderRequestDate";


//have the various social gaming engines been initialized?
bool LGSocialGamer_FeintEnabled;
bool LGSocialGamer_Initialized;
bool LGSocialGamer_GCAvailable;
int LGSocialGamer_BragAchievment; //this is the achievement to call when the user brags (makes it easier for us)

//various social gaming engine delegates
LGOFDelegate *LGSocialGamer_FeintDelegate;

//reference tot eh game feed view on the main menu
UIViewController *LGSocialGamer_RootView;
OFGameFeedView* LGSocialGamer_GameFeed;


//this is the object reference with delegate methods for social stuff, like receiving a bonus
id LGSocialGamer_SocialDelegate;

@implementation LGSocialGamer

//have we already initialized
+(bool) initialized {
	return LGSocialGamer_Initialized;
}

//is game center available?
+(BOOL) isGameCenterAvailable {
	return LGSocialGamer_GCAvailable;
}

//this method returns if we are actually using feint or not
//i.e. the user accepted it
//we don't call directly for two reasons:
//1) our app only knows about us, not feint
//2) we can make this more sophisticated in the future (i.e. decide based on GC availablity as well)
+(BOOL) usingFeint {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return false;
	
	return [OpenFeint hasUserApprovedFeint];
}

//init open feint
+(void) initOpenFeint:(id) target: (SEL) selector {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;

	//quit if feint already enabled
	if ( LGSocialGamer_FeintEnabled ) return;
		
	//feint now enabled don't call again
	LGSocialGamer_FeintEnabled = true;
		
	//get a window reference
	testappAppDelegate *t = [[UIApplication sharedApplication] delegate];
	UIWindow *mainWindow = [t window];
    
    //get the root view controller delegate

	
	//configure settings
	NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithInt:UIInterfaceOrientationPortrait], OpenFeintSettingDashboardOrientation,
							  @"LostMonsters", OpenFeintSettingShortDisplayName,
							  [NSNumber numberWithBool:YES], OpenFeintSettingEnablePushNotifications,
                              
							  //JBC 8-29-11: the following line disables chat
                              [NSNumber numberWithBool:YES], OpenFeintSettingDisableUserGeneratedContent,
  							  
                              
                              [NSNumber numberWithBool:NO], OpenFeintSettingAlwaysAskForApprovalInDebug,
							  [NSNumber numberWithBool:YES], OpenFeintSettingGameCenterEnabled,
                              
                            #ifdef DEBUG
                              [NSNumber numberWithInt:OFDevelopmentMode_DEVELOPMENT], OpenFeintSettingDevelopmentMode,
                            #else
							  [NSNumber numberWithInt:OFDevelopmentMode_RELEASE], OpenFeintSettingDevelopmentMode,
                            #endif

							  mainWindow, OpenFeintSettingPresentationWindow,
							  nil
							  ];
	
		
	//setup a delegate (same delegate handles all OF events )
	LGSocialGamer_FeintDelegate = [LGOFDelegate new];
	OFDelegatesContainer* delegates = [OFDelegatesContainer containerWithOpenFeintDelegate:LGSocialGamer_FeintDelegate
															andChallengeDelegate:LGSocialGamer_FeintDelegate
															andNotificationDelegate:LGSocialGamer_FeintDelegate];
	//also brag delegate
	delegates.bragDelegate = LGSocialGamer_FeintDelegate;	
	
	//set some other delegates
	[OFUser setDelegate:LGSocialGamer_FeintDelegate];
	[OFSocialNotificationApi setDelegate:LGSocialGamer_FeintDelegate];
	[OFAnnouncement setDelegate:LGSocialGamer_FeintDelegate];
	
	//set callback
	if ( target != nil ) {
		[LGSocialGamer_FeintDelegate setLoginDelegate:target :selector];
	}
		
	//initialize openfeint
	[OpenFeint initializeWithProductKey:OF_PRODUCT_KEY
	 andSecret:OF_SECRET
	 andDisplayName:OF_NAME
	 andSettings:settings
	 andDelegates:delegates];
		
}

//this determines if our current device is at least the given version
+(BOOL) deviceAtVersion:(NSString *) requiredVersion {
	// Test if device is running iOS 4.1 or higher
	NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
	bool isOSVerSet = ([currSysVer compare:requiredVersion options:NSNumericSearch] != NSOrderedAscending);
	return isOSVerSet;	
}

//this initializes game center (call whether we have GC or nort)
+(void) initGC {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;
	
	// Test for Game Center availability
	Class gameKitLocalPlayerClass = NSClassFromString(@"GKLocalPlayer");
	bool isLocalPlayerAvailable = (gameKitLocalPlayerClass != nil);
	
	// Test if device is running iOS 4.1 or higher
	bool isOSVer41 = [LGSocialGamer deviceAtVersion:@"4.1"];
	
	///here is the important part - is GC even available?
	LGSocialGamer_GCAvailable =  (isLocalPlayerAvailable && isOSVer41);	
	
}

//this initializes all the social gaming platforms at once
//or whichever ones the user installed / etc
+(void) initSocial {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;
	
	//increment our use count
	//[LGSocialGamer incrementUseCount];
    
	//don't initialize twice (now we have)
	if ( LGSocialGamer_Initialized) return;
	LGSocialGamer_Initialized = true;

	//initialize open feint with no login callback
	[LGSocialGamer initOpenFeint:nil:nil];
	
	//initialize game center
	[LGSocialGamer initGC];
	
}

//this initializes all the social gaming platforms at once
//or whichever ones the user installed / etc
+(void) initSocialCallBack:(id) target selector:(SEL) selector {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;

	//don't initialize twice (now we have)
	if ( LGSocialGamer_Initialized) return;
	LGSocialGamer_Initialized = true;

	//initialize social
	[LGSocialGamer initOpenFeint:target:selector];
	
	//initialize game center
	[LGSocialGamer initGC];
}

//submit some high score by its friendly LG id
+(void) score:(float) score leaderboard:(int) leaderboard {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;
	
	//update high score in open feint
	if ( [OpenFeint hasUserApprovedFeint] ) {
		//update the last leaderboard name reference (so we can change the notification)
		[LGSocialGamer_FeintDelegate setLastLeaderboard:LGLeaderBoards[leaderboard].Notification];
		
		//submit the high score
		[OFHighScoreService setHighScore:score forLeaderboard:LGLeaderBoards[leaderboard].OFID onSuccessInvocation:[OFInvocation invocationForTarget:LGSocialGamer_SocialDelegate selector:@selector(setHighscoreSucceeded)] onFailureInvocation:[OFInvocation invocationForTarget:LGSocialGamer_SocialDelegate selector:@selector(setHighScoreFailed)]];


	}
}


//brag about an achievement
+(void) bragAchievement:(int) achievement {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;
	
	//NOTE: always show OF dialog since with GC only we can't do this
	//save the achievement locally
	//updte the achievement in open feint
	//if ( [OpenFeint hasUserApprovedFeint] ) {
		//send a social notification for this achievement
		//and include a URL back to the itunes info for the app
		//note: the facebook image is named exactly the same as the achievement id 
		[OFSocialNotificationApi setCustomUrl:APP_URL];
		[OFSocialNotificationApi sendWithPrepopulatedText:[NSString stringWithFormat:@"I just unlocked %@ in %@",LGAchievements[achievement].Title,APP_TITLE] originalMessage:@"" imageNamed:[NSString stringWithFormat:@"achievement-%i",achievement]];
	//}
}

//achieve some achievement by its friendly LG id
+(void) achieve:(int) achievement percentComplete:(float) percentComplete {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;

	//save the achievement locally
	//updte the achievement in open feint
	//if ( [OpenFeint hasUserApprovedFeint] ) 
	{
		//update the achievement
		[OFAchievementService updateAchievement:LGAchievements[achievement].OFID andPercentComplete:percentComplete andShowNotification:true];			
	}

}

//submit some achievement given an achievement object (so that it can be called delayed/etc)
+(void) achieve:(LGAchievement *) achievement {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;

	//call normal function
	[LGSocialGamer achieve:[achievement achievement] percentComplete:[achievement percentComplete]];
}

//invite your friends with this method
+(void) inviteFriends {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;
	
	//NOTE: always show OpenFeint dialog
	//that way the user knows this is the only way to invite friends
	
	//trigger an open feint invitation request
	//if ( [OpenFeint hasUserApprovedFeint] || !LGSocialGamer_GCAvailable) {
		//trigger an invite and use our single delegate for it
		[OFInvite setDelegate:LGSocialGamer_FeintDelegate];
		[OFInviteDefinition setDelegate:LGSocialGamer_FeintDelegate];
		[OFInviteDefinition getPrimaryInviteDefinition];
		
		//this should trigger a method on our generic delegate
		//which will launch appropriate windows / etc

	//}
}

//show the openfeint dashbaord
+(void) showOpenFeint {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;
	
	//show the main OF dashboard
	//even if the user has not approvted
	//that way they can change their mind	
	[OpenFeint launchDashboard];
}

//show various things
+ (void) showAchievements {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;

	
	
	//show OF achievements always if game center is not available
	//or user has approved open feint (even if GC is avialable)
	if ( LGSocialGamer_GCAvailable ) {
        //remove game feed if its showing
        [LGSocialGamer removeGameFeed];
        
		//use game kit helper to show achievements
		[[GameKitHelper sharedGameKitHelper] showAchievements];
	} else {
		//show the achievement page
		[OpenFeint launchDashboardWithAchievementsPage];
	}

	/*
	if ( [OpenFeint hasUserApprovedFeint] || !LGSocialGamer_GCAvailable ) {
		//show the achievement page
		[OpenFeint launchDashboardWithAchievementsPage];
	} else {
		//use game kit helper to show achievements
		[[GameKitHelper sharedGameKitHelper] showAchievements];
	}
	*/
}


//show a specific leaderboard
+(void) showLeaderboard:(int) leaderboard {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;

	//show game center if available otherwise show open feint
	if ( LGSocialGamer_GCAvailable ) {
        //remove game feed if its showing
        [LGSocialGamer removeGameFeed];
        
		//show the game center leaderboard, using the same OFID - since we are keeping them in sync
		[[GameKitHelper sharedGameKitHelper] showLeaderboard:LGLeaderBoards[leaderboard].OFID];
	} else {
		//show the specific leaderboard page
		[OpenFeint launchDashboardWithHighscorePage:LGLeaderBoards[leaderboard].OFID];
	}
	
	/*
	//trigger an open feint invitation request
	if ( [OpenFeint hasUserApprovedFeint] || !LGSocialGamer_GCAvailable ) {
		//show the specific leaderboard page
		[OpenFeint launchDashboardWithHighscorePage:LGLeaderBoards[leaderboard].OFID];
	} else {
		//show the game center leaderboard, using the same OFID - since we are keeping them in sync
		[[GameKitHelper sharedGameKitHelper] showLeaderboard:LGLeaderBoards[leaderboard].OFID];
	}
	*/
}

//show the generic leaderboard list
+(void) showLeaderboards {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;
    
	//show GC if available otherwise use OF
	if ( LGSocialGamer_GCAvailable ) {
        //remove game feed if its showing
        [LGSocialGamer removeGameFeed];
        
		//show game center leaderboard list
		[[GameKitHelper sharedGameKitHelper] showLeaderboards];
	} else {
		//show the achievement page
		[OpenFeint launchDashboardWithListLeaderboardsPage];
	}

	/*
	//trigger an open feint invitation request
	if ( [OpenFeint hasUserApprovedFeint] || !LGSocialGamer_GCAvailable ) {
		//show the achievement page
		[OpenFeint launchDashboardWithListLeaderboardsPage];
	} else {
		//show game center leaderboard list
		[[GameKitHelper sharedGameKitHelper] showLeaderboards];
	}
	*/
	
}

+(void) findFriends {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;
	
	//NOTE: always show the openfeint find friend dialog so users know
	
	//trigger an open feint invitation request
	//if ( [OpenFeint hasUserApprovedFeint] ) {
		//help the user find friends
		[OpenFeint launchDashboardWithFindFriendsPage];
	/*} else {
		//show the game center request friend dialog
		[[GameKitHelper sharedGameKitHelper] showFriendRequest];
	}
	*/
}

/***SOCIAL TICKLERS***/

//launch our facebook page
+(void) showFaceBook {

	/*http://www.facebook.com/leftygames*/
	[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString: @"http://www.facebook.com/leftygames"]];
}

//launch our twitter feed
+(void) showTwitter {
	/*<a href="http://www.twitter.com/leftygames"><img src="http://twitter-badges.s3.amazonaws.com/t_logo-a.png" alt="Follow leftygames on Twitter"/></a>*/
	[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString: @"http://www.twitter.com/leftygames"]];	
}


//prompt the user to review the app after enough runs
+(void) promptForReview {
	//ask user to 
	//launch rating page for app
	[[UIApplication sharedApplication] openURL:[[NSURL alloc] initWithString: APP_RATE_URL]];

}

//prompt the user to invite their friends after enough runs
//and if they have never invited friends before
+(void) promptForInvite {
	//quit if we are not social
	if ( BYPASS_SOCIAL ) return;
	
	//trigger an open feint invitation request
	if ( [OpenFeint hasUserApprovedFeint] ) {
		//invite friends (using us)
		[LGSocialGamer inviteFriends];
	}
}


/***APP RATING LOGIC***/

//this method gets called to check for ating
//it gets called in "appLaunched" and "appResumed" methods
//so just add those to your app and the rest is magic
+ (void)rateCheck {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;

	// get the app's version
	NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey];
	
	// get the version number that we've been tracking
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSString *trackingVersion = [userDefaults stringForKey:kAppiraterCurrentVersion];
	if (trackingVersion == nil)
	{
		trackingVersion = version;
		[userDefaults setObject:version forKey:kAppiraterCurrentVersion];
	}
	
	if (LGSocialGamer_RateDEBUG)
		NSLog(@"APPIRATER Tracking version: %@", trackingVersion);
	
	if ([trackingVersion isEqualToString:version])
	{
		// check if the first use date has been set. if not, set it.
		NSTimeInterval timeInterval = [userDefaults doubleForKey:kAppiraterFirstUseDate];
		if (timeInterval == 0)
		{
			timeInterval = [[NSDate date] timeIntervalSince1970];
			[userDefaults setDouble:timeInterval forKey:kAppiraterFirstUseDate];
		}
		
		// increment the use count
		int useCount = [userDefaults integerForKey:kAppiraterUseCount];
		useCount++;
		[userDefaults setInteger:useCount forKey:kAppiraterUseCount];
		if (LGSocialGamer_RateDEBUG)
			NSLog(@"APPIRATER Use count: %d", useCount);
	}
	else
	{
		// it's a new version of the app, so restart tracking
		[userDefaults setObject:version forKey:kAppiraterCurrentVersion];
		[userDefaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:kAppiraterFirstUseDate];
		[userDefaults setInteger:1 forKey:kAppiraterUseCount];
		[userDefaults setInteger:0 forKey:kAppiraterSignificantEventCount];
		[userDefaults setBool:NO forKey:kAppiraterRatedCurrentVersion];
		[userDefaults setBool:NO forKey:kAppiraterDeclinedToRate];
		[userDefaults setDouble:0 forKey:kAppiraterReminderRequestDate];
	}
	
	[userDefaults synchronize];
}

//method that handles app launch
+(void) appLaunched {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;

	//trigger rate check
	[LGSocialGamer rateCheck];
}

//method handles pausing social gaming
+(void) appPaused {
	//abort if debug mode
	if ( BYPASS_SOCIAL ) return;
	
}

+(void) appResumed {
	//abort if debug mode
	if ( BYPASS_SOCIAL ) return;
	
	//trigger rate check
	[LGSocialGamer rateCheck];
	
}

//rate the app later or never
+(void) rateLater {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;

	// remind them later
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setDouble:[[NSDate date] timeIntervalSince1970] forKey:kAppiraterReminderRequestDate];
	[userDefaults synchronize];
}
+(void) rateNever {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return;

	// they don't want to rate it ever
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:YES forKey:kAppiraterDeclinedToRate];
	[userDefaults synchronize];
}


//we never prompt to rate, we only alert when it should be done
+(BOOL)timeToRate {
	//quit if bypassing social
	if ( BYPASS_SOCIAL ) return false;

	if (LGSocialGamer_RateDEBUG)
		return YES;
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	NSDate *dateOfFirstLaunch = [NSDate dateWithTimeIntervalSince1970:[userDefaults doubleForKey:kAppiraterFirstUseDate]];
	NSTimeInterval timeSinceFirstLaunch = [[NSDate date] timeIntervalSinceDate:dateOfFirstLaunch];
	NSTimeInterval timeUntilRate = 60 * 60 * 24 * LGSocialGamer_DAYS_UNTIL_PROMPT;
	if (timeSinceFirstLaunch < timeUntilRate)
		return NO;
	
	// check if the app has been used enough
	int useCount = [userDefaults integerForKey:kAppiraterUseCount];
	if (useCount <= LGSocialGamer_USES_UNTIL_PROMPT)
		return NO;
	
	// check if the user has done enough significant events
	int sigEventCount = [userDefaults integerForKey:kAppiraterSignificantEventCount];
	if (sigEventCount <= LGSocialGamer_SIG_EVENTS_UNTIL_PROMPT)
		return NO;
	
	// has the user previously declined to rate this version of the app?
	if ([userDefaults boolForKey:kAppiraterDeclinedToRate])
		return NO;
	
	// has the user already rated the app?
	if ([userDefaults boolForKey:kAppiraterRatedCurrentVersion])
		return NO;
	
	// if the user wanted to be reminded later, has enough time passed?
	NSDate *reminderRequestDate = [NSDate dateWithTimeIntervalSince1970:[userDefaults doubleForKey:kAppiraterReminderRequestDate]];
	NSTimeInterval timeSinceReminderRequest = [[NSDate date] timeIntervalSinceDate:reminderRequestDate];
	NSTimeInterval timeUntilReminder = 60 * 60 * 24 * LGSocialGamer_TIME_BEFORE_REMINDING;
	if (timeSinceReminderRequest < timeUntilReminder)
		return NO;
	
	return YES;
}

/***VERY IMPORTANT - SOCIAL BONUS LOGIC***/

//this method applies a social bonus (some bonus in the game for doing social tasks like bragging/inviting)
+(void) socialBonus {
	//alert the social delegate (i.e. menu or game scene, etc)
	[LGSocialGamer_SocialDelegate receiveSocialBonus];
	
}

//update the social delegate
+(void) setSocialDelegate:(id<LGSocialDelegate>) socialDelegate {
	//update our reference
	LGSocialGamer_SocialDelegate = socialDelegate;
}


/***GAME FEED LOGIC***/


//initialize game feed
+(void)setupGameFeed:(NSDictionary*)additionalSettings {
    //setup root view controller if not every initialized
    if ( LGSocialGamer_RootView == nil ) {
        id<UIApplicationDelegate> t = [[UIApplication sharedApplication] delegate];
        UIWindow *mainWindow = [t window];
        UIViewController *r = (UIViewController *)[mainWindow rootViewController];
        LGSocialGamer_RootView = r;
    }
    
    
    //game feed settings
    NSMutableDictionary* settings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:YES], OFGameFeedSettingAnimateIn,

        [UIImage imageNamed:@"GameFeed-Back.png"], OFGameFeedSettingFeedBackgroundImagePortrait,
        //[UIImage imageNamed:@"GameFeed-Cell.png"], OFGameFeedSettingCellBackgroundImagePortrait,
        //[UIImage imageNamed:@"GameFeed-Cell.png"], OFGameFeedSettingCellHitImagePortrait,
        //[UIImage imageNamed:@"CellBackgroundLandscape.png"], OFGameFeedSettingCellBackgroundImageLandscape,
        //[UIImage imageNamed:@"CellBackgroundHitLandscape.png"], OFGameFeedSettingCellHitImageLandscape,
        //[UIImage imageNamed:@"ProfileFrame.png"], OFGameFeedSettingProfileFrameImage,
        //[UIImage imageNamed:@"CellDividerPortrait.png"], OFGameFeedSettingCellDividerImagePortrait,
        //[UIImage imageNamed:@"GameBarBackgroundLandscape.png"], OFGameFeedSettingFeedBackgroundImageLandscape,
        //[UIImage imageNamed:@"CellDividerLandscape.png"], OFGameFeedSettingCellDividerImageLandscape,
    nil];    
    [settings setObject:[NSNumber numberWithInt:OFGameFeedAlignment_BOTTOM] forKey:OFGameFeedSettingAlignment];
    
    //additional settupings
    if (additionalSettings) {
        [settings addEntriesFromDictionary:additionalSettings];
    }
    
    //save game feed reference
    LGSocialGamer_GameFeed = [OFGameFeedView gameFeedViewWithSettings:settings];
    [[LGSocialGamer_RootView view] addSubview:LGSocialGamer_GameFeed];
    
    //hide the OF button and badge count from the user
    //UIButton *b = [LGSocialGamer_GameFeed badgeButton];
    //[b setHidden:true];
    //[[LGSocialGamer_GameFeed badgeView] setValue:0];

    //change the size/shape of the game feed item cell

    
    //testing:
    //if(currentGameFeedAlignment == OFGameFeedAlignment_CUSTOM)
    //{
    //    CGRect frame = self.gameFeed.frame;
    //    LGSocialGamer_GameFeed.frame = CGRectMake(0, 100, frame.size.width, frame.size.height);
    //}
    
    
    
    //testing: can we create a new feed item:
    //this would be to push our own stuff in there (like announcements
    
    
}

//show game feed view
+(void) showGameFeed {
    //testing: is button visible?
    bool hid = (bool)[[LGSocialGamer_GameFeed badgeButton] hidden];
    
    NSLog(@"button hidden: %i",hid);
    
    //initialize if needed
    if ( LGSocialGamer_GameFeed == nil ) {
        //setup game feed
        [LGSocialGamer setupGameFeed:nil];
    } else {
        //only animate in (don't recreate it - FOR SPEED)
        [LGSocialGamer_GameFeed animateIn];
        
    }
}


//hide game feed (but don't remove it)
+(void) hideGameFeed {
    //quit if game feed is not initialized
    if ( LGSocialGamer_GameFeed == nil ) return;
    
    //this is the contents of "animateOutAndRemoveFromSuperView"
    //minus the remove part, apparently there is no OF method for this
    [LGSocialGamer_GameFeed cancelCurrentFeedRequest];
    [LGSocialGamer_GameFeed cancelCurrentADRequest];
    [LGSocialGamer_GameFeed moveViewIntoPlace];
    
    [UIView beginAnimations:@"OFGameBarViewPositioning" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:LGSocialGamer_GameFeed];
    //[UIView setAnimationDidStopSelector:@selector(animateOutDone)];
    
    [LGSocialGamer_GameFeed moveViewOffscreen];    
    [UIView commitAnimations];

}


//remove game feed entirely
+(void) removeGameFeed {
    //quit if already removed 
    if ( LGSocialGamer_GameFeed == nil ) return;
    
    //remove from super view
    [LGSocialGamer_GameFeed animateOutAndRemoveFromSuperview];
    LGSocialGamer_GameFeed = nil;
}


/***ANNOUNCEMENT LOGIC***/

/*//request announcements for this app only
//note: we created announcemenet delegate
+(void) requestAppAnnouncements:(* AnnouncementDelegate) announcementDelegate {
	//store the target/selector for ur app announcement request
	[LGSocialGamer_FeintDelegate setAnnouncementDelegate:AnnouncementDelegate];
	
	//start downloading announcements
	OFRequestHandle* handle = [OFAnnouncement downloadAnnouncementsAndSortBy:EAnnouncementSortType_CREATION_DATE];
}

//request all our global announcements
+(void) requestDevAnnouncements:(* AnnouncementDelegate) announcementDelegate {
}
*/

@end
