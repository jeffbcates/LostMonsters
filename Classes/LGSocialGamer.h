//
//  LGSocialGamer.h
//  LostMonsters
//
//	this class hides the complexity of the different
//	score engines we use
//	you pass our lefty achievements
//	and the class communicates with GC, OpenFeint
//	or just stores locally
//
//  Created by Jeff Cates on 6/10/11.
//  Copyright 2011 leftygames. All rights reserved.



#import "OpenFeint/OpenFeintDelegate.h"
#import "LGAchievement.h"

//used to handle announcements received from social gaming engine
//#import "AnnouncementDelegate.h"

//OpenFeint Integration
#import "LGOFDelegate.h"

//high score stuff
#import "OpenFeint/OFHighScore.h"

//achievement stuff
#import "OpenFeint/OFAchievementService.h"
#import "OpenFeint/OFHighScoreService.h"

//social notifications
#import "OpenFeint/OFSocialNotificationService.h"
#import "OpenFeint/OFSocialNotificationApi.h"

//invites to friends
#import "OpenFeint/OFInvite.h"
#import "OpenFeint/OFInviteDefinition.h"

//our social delegate
@protocol LGSocialDelegate

//this method gets called when we receive a social bonus
-(void) receiveSocialBonus;

@end



@interface LGSocialGamer : NSObject {

}

/***OUR PUBLIC METHODS***/

//these methods trigger the user to
//do something after some number of runs
//determine by the methods
+(void) promptForInvite; //the user should invite friends after some # of plays


//this method

//have we logged in already?
+(bool) initialized;

//start the social
+(void) initSocial;

//start the social and call a method when complete
+(void) initSocialCallBack:(id) target selector:(SEL) selector;

//submit a score to a leaderboard
+(void) score:(float) score leaderboard:(int) leaderboard;

//submit some achievement given an achievement object (so that it can be called delayed/etc)
+(void) achieve:(LGAchievement *) achievement;

//submit some achievement given the lefty id
+(void) achieve:(int) achievement percentComplete: (float) percentComplete;

//request announcements (simple - we pick order, etc)
//+(void) requestAppAnnouncements:(AnnouncementDelegate *) announcementDelegate;
//+(void) requestDevAnnouncements:(AnnouncementDelegate *) announcementDelegate;

//show twttier/facebook for lefty games
//facebook click
+(void) showFaceBook;
+(void) showTwitter;
+(BOOL) timeToRate; //determines if it is time to rate our app or not
+(void) rateLater; //should we rate later
+(void) rateNever; //should we never rate again?

//these methods should get called when
//the app starts, stops, and pauses
+(void) appLaunched; //call this when the app is launched or brought to foreground to increment use count
+(void) appPaused; //call on app resign active
+(void) appResumed; //call when app is resumed (not launched)

//invite your friends with this method
+(void) inviteFriends;

//different pages to show
+(void) showLeaderboard:(int) leaderboard;
+(void) showLeaderboards;
+(void) showAchievements;
+(void) findFriends;
+(void) showOpenFeint; //show open feint dashboard for settings/etc

//methods related to showing game feed
+(void) showGameFeed;
+(void) hideGameFeed;
+(void) removeGameFeed; //hides and removes game feed completely

//social related methods
+(void) bragAchievement:(int) achievement;
+(void) promptForReview;
+(void) promptForInvite;

//what type of social gaming are we using?
+(BOOL) usingFeint; //are we using feint
+(BOOL) isGameCenterAvailable; //is game center even available?

//this could be somewhere better
//but for now we will just leave it here
+(BOOL) deviceAtVersion:(NSString *) requiredVersion;

//this method applies a social bonus (some bonus in the game for doing social tasks like bragging/inviting)
+(void) socialBonus;
+(void) setSocialDelegate:(id) delegate;

@end
