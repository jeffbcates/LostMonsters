/*
 *  monsterinfo.h
 *  LostMonsters
 *
 *	contains names and descriptions of all monsters in the order of appearance
 *
 *
 *  Created by Jeff Cates on 2/28/11.
 *  Copyright 2011 leftygames. All rights reserved.
 *
 */

//this structure defines monster info

struct MonsterInfo {
	int monsterNum; //# of the monster (appearance, order, etc)
	NSString *monsterName; //name of the monster
	NSString *monsterType; //the type of monster
	int monsterWeight; //weight of monster
	
	//the height is broken into feet and inches
	int monsterFeet;
	int monsterInches;

	//these two are at the end because they are long
	NSString *monsterLikes; //likes for the monster
	NSString *monsterHistory; //history of the monster
	
};

//our array of monsters
#define MONSTER_COUNT 12

MonsterInfo monsters[MONSTER_COUNT] = {	
	/***MONSTER-1***/
	{	monsterNum:1,
		monsterName:@"Birds Eye",
		monsterType:@"",
		monsterWeight:76,
		monsterFeet:4,monsterInches:3,
		monsterLikes:@"",
		monsterHistory:@""
	},

	/***MONSTER-2***/
	{
	monsterNum:2,
	monsterName:@"Grumbles",
	monsterType:@"Blue Cronkler",
	monsterWeight:386,
	monsterFeet:7,monsterInches:1,
	monsterLikes:@"Description",
	monsterHistory:@""
	},
	
	/***MONSTER-3***/
	{
	monsterNum:3,
	monsterName:@"Green",
	monsterType:@"",
	monsterWeight:298,
	monsterFeet:5,monsterInches:2,
	monsterLikes:@"",
	monsterHistory:@""
	},
	
	/***MONSTER-4***/
	{	
	monsterNum:4,
	monsterName:@"Top Hat",
	monsterType:@"",
	monsterWeight:93,
	monsterFeet:3,monsterInches:8,
	monsterLikes:@"",
	monsterHistory:@""
	},

	/***MONSTER-5***/
	{	
	monsterNum:5,
	monsterName:@"Yellow",
	monsterType:@"",
	monsterWeight:245,
	monsterFeet:6,monsterInches:0,
	monsterLikes:@"",
	monsterHistory:@""
	},
	
	/***MONSTER-6***/
	{	
	monsterNum:6,
	monsterName:@"Bull Frog",
	monsterType:@"",
	monsterWeight:215,
	monsterFeet:5,monsterInches:7,
	monsterLikes:@"",
	monsterHistory:@""
	},
	
	/***MONSTER-7***/
	{	
	monsterNum:7,
	monsterName:@"Octi",
	monsterType:@"",
	monsterWeight:103,
	monsterFeet:4,monsterInches:3,
	monsterLikes:@"",
	monsterHistory:@""
	},
	
	/***MONSTER-8***/
	{	
	monsterNum:8,
	monsterName:@"Blinky",
	monsterType:@"",
	monsterWeight:265,
	monsterFeet:5,monsterInches:8,
	monsterLikes:@"",
	monsterHistory:@""
	},
	
	/***MONSTER-9***/
	{	
	monsterNum:9,
	monsterName:@"Porker",
	monsterType:@"",
	monsterWeight:269,
	monsterFeet:4,monsterInches:2,
	monsterLikes:@"",
	monsterHistory:@""
	},
	
	/***MONSTER-10***/
	{	
	monsterNum:10,
	monsterName:@"Red",
	monsterType:@"",
	monsterWeight:108,
	monsterFeet:2,monsterInches:11,
	monsterLikes:@"",
	monsterHistory:@""
	},
	
	/***MONSTER-11***/
	{	
	monsterNum:11,
	monsterName:@"Grumpy",
	monsterType:@"",
	monsterWeight:293,
	monsterFeet:6,monsterInches:7,
	monsterLikes:@"",
	monsterHistory:@""
	},
	
	/***MONSTER-12***/
	{	
	monsterNum:12,
	monsterName:@"Purple",
	monsterType:@"",
	monsterWeight:134,
	monsterFeet:4,monsterInches:11,
	monsterLikes:@"",
	monsterHistory:@""
	}
	
};