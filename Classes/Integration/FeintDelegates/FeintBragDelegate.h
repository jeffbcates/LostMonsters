#pragma once

#import "OpenFeint/OFBragDelegate.h"

@interface SampleOFBragDelegate : NSObject< OFBragDelegate >

- (void)bragAboutAchievement:(OFAchievement*)achievement overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message;
- (void)bragAboutAllAchievementsWithTotal:(int)total unlockedAmount:(int)unlockedAmount overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message;
- (void)bragAboutHighScore:(OFHighScore*)highScore onLeaderboard:(OFLeaderboard*)leaderboard overridePrepopulatedText:(NSString*&)text overrideOriginalMessage:(NSString*&)message;

@end
