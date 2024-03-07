#import "SampleOFBragDelegate.h"
#import "PostToSocialNetworkSampleController.h"

@implementation SampleOFBragDelegate

- (void)bragAboutAchievement:(OFAchievement*)achievement overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message
{
	if([PostToSocialNetworkSampleController shouldOverrideOneAchievementBrag])
	{
		text = @"I could write something flavorful and interesting here for bragging about a single achievement";
		message = @"Suggested Text To Send";
	}
}

- (void)bragAboutAllAchievementsWithTotal:(int)total unlockedAmount:(int)unlockedAmount overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message
{
	if([PostToSocialNetworkSampleController shouldOverrideAllAchievementBrag])
	{
		text = @"I could write something flavorful and interesting here for bragging about all achievements";
		message = @"Suggested Text To Send";
	}
}

- (void)bragAboutHighScore:(OFHighScore*)highScore onLeaderboard:(OFLeaderboard*)leaderboard overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message
{
	if([PostToSocialNetworkSampleController shouldOverrideOneScoreBrag])
	{
		text = @"I could write something flavorful and interesting here for bragging about a HighScore";
		message = @"Suggested Text To Send";
	}
}

@end
