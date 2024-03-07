//
//  LGOFDelegate.mm
//  LostMonsters
//
//  Created by Jeff Cates on 6/8/11.
//  Copyright 2011 leftygames. All rights reserved.
//

#import "OpenFeint/OpenFeint.h"
#import "OpenFeint/OFUnlockedAchievementNotificationData.h"
#import "LGOFDelegate.h"
#import "cocos2d.h"
#import "LGSocialGamer.h"


@implementation LGOFDelegate

-(void) setLoginDelegate:(id) loginDelegate :(SEL) selector{
	_loginDelegate = loginDelegate;	
	_loginSelector = selector;
}



- (void)dashboardWillAppear
{
}

- (void)dashboardDidAppear
{
	[[CCDirector sharedDirector] pause];
	[[CCDirector sharedDirector] stopAnimation];
}

- (void)dashboardWillDisappear {
}

- (void) dashboardDidDisappear
{
	[[CCDirector sharedDirector] resume];
	[[CCDirector sharedDirector] startAnimation];
}

- (void)userLoggedIn:(NSString*)userId {
	OFLog(@"New user logged in! Hello %@", [OpenFeint lastLoggedInUserName]);
	if ( _loginDelegate != nil )  {
		//call the login delegate method and pass ourselves
		[_loginDelegate performSelector:_loginSelector withObject:self];
	}
}

- (BOOL)showCustomOpenFeintApprovalScreen {
	return NO;
}


/***OPENFEINT INVITE NOTIFICATIONS EVENTS***/

//we will only get this called once we requested it in-game using "inviteFriends" method
- (void)didGetPrimaryInviteDefinition:(OFInviteDefinition*)definition{	
	//display the OF dialog
	OFInvite*invite = [[[OFInvite alloc]initWithInviteDefinition:definition]autorelease];
	[invite displayAndSendInviteScreen];
}


- (void)didFailGetPrimaryInviteDefinition{
	NSLog(@"LGSocialGamer: Failed To Get Primary Invite Definition");
}

/***OFNotificationDelegate Methods***/

- (BOOL)isOpenFeintNotificationAllowed:(OFNotificationData*)notificationData {
	/*
	if (notificationData.notificationCategory == kNotificationCategoryAchievement &&
		notificationData.notificationType == kNotificationTypeSuccess)
	{return NO;
	}
	*/
	
	return YES;
}


//update last leaderboard used
-(void) setLastLeaderboard:(NSString *) leaderboardName {
	//update our internal reference
	_lastLeaderboard = leaderboardName;
}

//NOTE: speed enhancement - we don't download the icon for each achievement
//we use a local copy of the announcement, hopefully faster and less clunkier than
//downloading the whole image everytime
/*
-(void)handleDisallowNotification:(OFNotificationData*)notificationData {
	//only for achievements - we skp the default notification
	//so we don't download our achievement icon - instead use a local copy
	if (notificationData.notificationCategory == kNotificationCategoryAchievement && notificationData.notificationType == kNotificationTypeSuccess) {
		//get the achievement data and the URL
	
		OFUnlockedAchievementNotificationData *data = notificationData;
		NSArray *component = [data.unlockedAchievement.iconUrl pathComponents];
		
		//create a custom OF notification with the local URL not the external one
		CustomOFNotification *custom = [[[CustomOFNotification alloc] initWithFile:[component lastObject] andWithText:data.unlockedAchievement.title] autorelease];		
		[custom showNotification];
	}
}
*/


- (void)handleDisallowedNotification:(OFNotificationData*)notificationData {

	//we override the default achievement 
	if (notificationData.notificationCategory == kNotificationCategoryAchievement &&
		notificationData.notificationType == kNotificationTypeSuccess) {
	}	
	
	//NSString* message = @"We're overriding the achievement unlocked notification. Check out SampleOFNotificationDelegate.mm!";
	//[[[[UIAlertView alloc] initWithTitle:@"Achievement Unlocked!" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];

}


- (void)notificationWillShow:(OFNotificationData*)notificationData {
	//update notification text for high scores
	if (notificationData.notificationCategory == kNotificationCategoryHighScore) {
		//here we are submitting a high score, but we want it to say the leaderboard name
		//not the words "new high score"
		[notificationData setNotificationText:_lastLeaderboard];		
		
	}
}


/***Challenge Delegate Methods***/

- (void)userLaunchedChallenge:(OFChallengeToUser*)challengeToLaunch withChallengeData:(NSData*)challengeData
{
	/*
	 OFLog(@"Launched Challenge: %@", challengeToLaunch.challenge.challengeDefinition.title);
	PlayAChallengeController* controller = (PlayAChallengeController*)OFControllerLoader::load(@"PlayAChallenge");
	[controller setChallenge:challengeToLaunch];
	[controller setData:challengeData];
	MyOpenFeintSampleAppDelegate* appDelegate = (MyOpenFeintSampleAppDelegate*)[[UIApplication sharedApplication] delegate];	
	[appDelegate.rootController pushViewController:controller animated:YES];
	*/
}

- (void)userRestartedChallenge {
	/*
	OFLog(@"Ignoring challenge restart.");
	*/
}


/***BRAG Delegate Methods***/
- (void)bragAboutAchievement:(OFAchievement*)achievement overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message {
	//create our own original message based on the achievement
	text = [NSString stringWithFormat:@"I just unlocked %@ in %@",[achievement title],SOCIAL_NAME];
}

- (void)bragAboutAllAchievementsWithTotal:(int)total unlockedAmount:(int)unlockedAmount overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message {
}

- (void)bragAboutHighScore:(OFHighScore*)highScore onLeaderboard:(OFLeaderboard*)leaderboard overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message {
}

/***ANNOUNCEMENT LISTS***/

- (void)didDownloadAnnouncementsAppAnnouncements:(NSArray*)appAnnouncements devAnnouncements:(NSArray*)devAnnouncements; {
	//here we should return to the caller what we got
	
	
	//OFSafeRelease(appAnnouncementList);
	//OFSafeRelease(devAnnouncementList);
	
	//appAnnouncementList = [appAnnouncements retain];
	//devAnnouncementList = [devAnnouncements retain];
	
	//[self setAnnouncementType: AnnouncementType_App];
}


/***SOCIAL NOTIFICATION EVENTS***/


- (void)didSendInvite:(OFInvite*)invite {
	//the user sent an invite - achieve the invite achievement
	[LGSocialGamer achieve:ACHIEVE_INVITE percentComplete:100];
	
	//the user gets a bonus for this
	[LGSocialGamer socialBonus];
}

- (void)didSendSocialNotification {
	//we unlocked the social notification achievement
	[LGSocialGamer achieve:ACHIEVE_SOCIAL percentComplete:100];
	
	//the user gets a bonus for this
	[LGSocialGamer socialBonus];
}

- (void)didFailSocialNotification {
}

/***GAME CENTER METHODS***/

-(void)achievementViewControllerDidFinish {
}


/***TESTING NEW OPENFEINT CHANGES***/

-(void) setHighScoreSucceeded {}
-(void) setHighScoreFailed {}

@end
