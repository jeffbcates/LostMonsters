//
//  LGOFDelegate.h
//  LostMonsters
//
//  Created by Jeff Cates on 6/8/11.
//  Copyright 2011 leftygames. All rights reserved.
//

#define SOCIAL_NAME @"Lost Monsters"

//we achieve the social notification achievement
#import "achievements.h"

#import "OpenFeint/OpenFeintDelegate.h"
#import "OpenFeint/OFBragDelegate.h"
#import "OpenFeint/OFChallengeDelegate.h"
#import "OpenFeint/OFNotificationDelegate.h"
#import "OpenFeint/OFInvite.h"
#import "OpenFeint/OFInviteDefinition.h"
#import "OpenFeint/OFUser.h"
#import "OpenFeint/OFSocialNotificationApi.h"
#import "OpenFeint/OpenFeint.h"
#import "OpenFeint/OpenFeint+Dashboard.h"
#import "OpenFeint/OpenFeint+UserOptions.h"
#import "OpenFeint/OFAnnouncement.h"
//#import "OpenFeint/OFControllerLoader.h"
//#import "OpenFeint/OFViewHelper.h"



@interface LGOFDelegate : NSObject<OFAnnouncementDelegate,OFSocialNotificationApiDelegate,OFBragDelegate,OFChallengeDelegate,OpenFeintDelegate,OFInviteSendDelegate, OFInviteDefinitionDelegate,OFNotificationDelegate,OFUserDelegate> {
	//the login delegate
	id _loginDelegate;
	SEL _loginSelector;
	NSString *_lastLeaderboard;
}

/***OUR CUSTOM STUFF***/

//set a temporary login delegate method
- (void) setLoginDelegate:(id) loginDelegate:(SEL)selector;


/***OpenFeint Delegate Methods***/

//social notification api delegate methods
- (void)didSendSocialNotification;
- (void)didFailSocialNotification;

//OFNotificationDelegate Methods
- (BOOL)isOpenFeintNotificationAllowed:(OFNotificationData*)notificationData;
- (void)handleDisallowedNotification:(OFNotificationData*)notificationData;
- (void)notificationWillShow:(OFNotificationData*)notificationData;

//set the last leaderboard
- (void) setLastLeaderboard:(NSString *) leaderboardName;

//OpenFeint Delegate Methods
- (void)dashboardWillAppear;
- (void)dashboardDidAppear;
- (void)dashboardWillDisappear;
- (void)dashboardDidDisappear;
- (void)userLoggedIn:(NSString*)userId;
- (BOOL)showCustomOpenFeintApprovalScreen;

//Challenge Delegate Methods
- (void)userLaunchedChallenge:(OFChallengeToUser*)challengeToLaunch withChallengeData:(NSData*)challengeData;
- (void)userRestartedChallenge;

//Invite Delegate Methods
- (void)didGetPrimaryInviteDefinition:(OFInviteDefinition*)definition;
- (void)didFailGetPrimaryInviteDefinition;

//brag delegate methods
- (void)bragAboutAchievement:(OFAchievement*)achievement overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message;
- (void)bragAboutAllAchievementsWithTotal:(int)total unlockedAmount:(int)unlockedAmount overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message;
- (void)bragAboutHighScore:(OFHighScore*)highScore onLeaderboard:(OFLeaderboard*)leaderboard overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message;



@end
