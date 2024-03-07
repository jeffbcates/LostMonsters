/*
 *  LGSocialGamerConfig.h
 *  LostMonsters
 *
 *  Created by Jeff Cates on 6/10/11.
 *  Copyright 2011 leftygames. All rights reserved.
 *
 */

/***WEIRD TESTING SETTINGS***/

//set this to test a game with all the social stuff completely removed
#define BYPASS_SOCIAL false

/***OPENFEINT INTEGRATION***/

#define OF_PRODUCT_KEY @"RqfHBiNcLEWHhLMRqnsZDw"
#define OF_SECRET @"SKrdsbWCxcR6jDv2dT7Ii8nfpEFIU0hlVIuX9oyCGQ"
#define OF_NAME @"Lost Monsters"

//***ACHIEVEMENT STRUCTURE****//

//achievement structure
struct LGAchievementInfo {
	NSString *OFID; //id of the achievement in OpenFeint
	NSString *Title; //title of the achievement
};

//***LEADERBOARD STRUCTURE***//

//leaderboard structure
struct LGLeaderBoardInfo {
	NSString *OFID; //id of the leader board in open feint
	NSString *Notification; //description when user gets a new high score in this leaderboard
};

//***ACHIEVEMENTS***//

#define ACHIEVEMENTS 20
LGAchievementInfo LGAchievements[ACHIEVEMENTS] = {
	//the 12 monsters:
	{OFID:@"1024942",Title:@"A Bird in the Eye"},
	{OFID:@"1025052",Title:@"It's Not Easy Being Blue"},
	{OFID:@"1025062",Title:@"Not So Scary"},
	{OFID:@"1025072",Title:@"Hats Off To You"},
	{OFID:@"1025082",Title:@"Judo Chop"},
	{OFID:@"1025092",Title:@"I'm All Heart"},
	{OFID:@"1025102",Title:@"Lend me a Hand"},
	{OFID:@"1025112",Title:@"Look Me in the Eyes"},
	{OFID:@"1025122",Title:@"Pass me the BBQ"},
	{OFID:@"1025132",Title:@"Seeing Red"},
	{OFID:@"1025142",Title:@"Big, Gray, and Grumpy"},
	{OFID:@"1025152",Title:@"Got Ants?"},
	
	//other achievements
	{OFID:@"1026312",Title:@"Bust a Board"}, //board bust
	{OFID:@"1026362",Title:@"Movie Buff"}, //movie bust
	{OFID:@"1029082",Title:@"Bomber Man"}, //bomber man
	{OFID:@"1050602",Title:@"Best Combo Ever"}, //best combo ever
	{OFID:@"1050612",Title:@"Multiplicity"}, //multiplier achievement
	{OFID:@"1050622",Title:@"Biography Channel"}, //look at a bio
	{OFID:@"1050632",Title:@"Social Butterfly"}, //brag about an achievement
	{OFID:@"1051012",Title:@"Mail Man"} //perform an invite to the game within OF integration
};

//***LEADERBOARDS***//

#define LEADERBOARDS 4
LGLeaderBoardInfo LGLeaderBoards[LEADERBOARDS] = {
	{OFID:@"775256",Notification:@"New High Score!"},
	{OFID:@"776706",Notification:@"New Single Level High-Score!"}, /*NO LONGER USING THIS ONE*/
	{OFID:@"779276",Notification:@"New Super Multiplier!"},
	{OFID:@"779286",Notification:@"New Best Combo Ever!"}
};