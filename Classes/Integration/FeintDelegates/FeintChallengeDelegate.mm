#import "SampleOFChallengeDelegate.h"
#import "PlayAChallengeController.h"
#import "MyOpenFeintSampleAppDelegate.h"

#import "OpenFeint/OFChallengeToUser.h"
#import "OpenFeint/OFChallenge.h"
#import "OpenFeint/OFChallengeDefinition.h"
#import "OpenFeint/OFControllerLoader.h"

@implementation SampleOFChallengeDelegate

- (void)userLaunchedChallenge:(OFChallengeToUser*)challengeToLaunch withChallengeData:(NSData*)challengeData
{
	OFLog(@"Launched Challenge: %@", challengeToLaunch.challenge.challengeDefinition.title);
	PlayAChallengeController* controller = (PlayAChallengeController*)OFControllerLoader::load(@"PlayAChallenge");
	[controller setChallenge:challengeToLaunch];
	[controller setData:challengeData];
	MyOpenFeintSampleAppDelegate* appDelegate = (MyOpenFeintSampleAppDelegate*)[[UIApplication sharedApplication] delegate];	
	[appDelegate.rootController pushViewController:controller animated:YES];
}

- (void)userRestartedChallenge
{
	OFLog(@"Ignoring challenge restart.");
}

@end
