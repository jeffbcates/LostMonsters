/*
 *  Levels.h
 *  testapp
 *
 *	contains definitions for the levels
 *	including their max states, blocks, achievements, etc
 *
 *  Created by Jeff Cates on 1/12/11.
 *  Copyright 2011 mrwired. All rights reserved.
 *
 */


//some levels have custom messages that are displayed (besides the ready steady go thing)
//those messages are stored here

#define LEVEL_COUNT 6
#define LEVEL_MESSAGE_COUNT 3
struct Level {
	int level; //the level number for this level
	int newBlockType; //which block is being introduced?
	//int newBlockState; //which block state is being introduced
	//int maxPoints; //point override for level
	int maxBlocks; //this is the # of blocks on this level (divided evenly between block types)
	int maxSpawn; //max # of monsters that will get spawned in rapid succession during a single spawn
	int minSpawn; //min # of monsters that will get spawned in rapid succession during a single spawn
	int types; //the # of 
	int states; //DEPRECATED - not relevant anymore because there are only 2 states - locked and not locked
	float maxInterval; //maximum time between monsters spawning (starts at this and gets faster as level goes on)
	float minInterval; //minimum time bewteen monsters spawning (won't get faster than this)
	
	NSString *messages[LEVEL_MESSAGE_COUNT]; //messages to start the level
	
	//this is the layout of the board in its initial state when first loaded
	int board[ROWS][COLS];
	
	//the starting and ending finger positions (or nothing)
	CGPoint fingerStart;
	CGPoint fingerEnd;
	NSString *helpText; //help text
};

//the array of levels

//notice level 0 - that is the generic level for any level
//not defined here
Level levels[LEVEL_COUNT] = {
	
	//most levels
	//notice that the ball types here do not include the rainbow bll type
	//notice on this level we do not define the board because it is not a training level
	{	level:0,newBlockType:0,
		maxBlocks:0,maxSpawn:5,minSpawn:1,
		types:0,states:1,
		maxInterval:4.0f,minInterval:2.0f,
		messages:{@"ready?",@"steady",@"go!"},
		board:{},
		fingerStart:CGPointZero,fingerEnd:CGPointZero,
		helpText:nil
	},
	

	//LEVEL 1 - show how we slide to connect (columns)	
	{	level:1,newBlockType:0,
		maxBlocks:4,maxSpawn:1,minSpawn:1,
		types:1,states:1,
		maxInterval:8.0f,minInterval:3.5f,
		messages:{@"ready?",@"steady",@"go!"},

		//well defined starting board:
		board: {
			{0,0,0,0,0},
			{0,0,0,0,1},
			{0,0,0,0,1},
			{0,0,0,0,0},
			{0,0,0,1,0},
			{0,0,0,1,0}
		},
		
		//help finger position and text for this learning level
		fingerStart:CGPointMake(3, 3), fingerEnd:CGPointMake(3, 1),
		helpText:@"helptext-1.png"
		//helpText:@"Lost Monsters is Easy to Play.  Just slide rows or columns to collect groups of 4 or more monsters in any shape"
	},
	
	//LEVEL 3 - show how we slide to connect (columns)	
	{	level:2,newBlockType:0,
		maxBlocks:8,maxSpawn:1,minSpawn:1,
		types:1,states:1,
		maxInterval:8.0f,minInterval:3.5f,
		messages:{@"ready?",@"steady",@"go!"},
		
		//well defined starting board:
		board: {
		{0,0,0,0,0},
		{0,0,0,0,-3},
		{0,0,0,1,0},
		{0,0,0,0,1},
		{0,0,0,0,1},
		{0,0,0,0,1}
		},
		
	//same start/end means to tap
	fingerStart:CGPointMake(4, 0), fingerEnd:CGPointMake(4, 0),		
	helpText:@"helptext-2.png"
	},
	
	//LEVEL 2 - show more=better, and we can connect rows too
	{	level:3,newBlockType:0,
		maxBlocks:12,maxSpawn:1,minSpawn:1,
		types:1,states:1,
		maxInterval:8.0f,minInterval:3.5f,
		messages:{@"ready?",@"steady",@"go!"},
		
		//well defined starting board:
		board: {
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,0,0,0},
			{0,0,1,0,-1},
			{0,0,0,1,0},
			{0,0,0,1,1}
		},
		
		//help finger position and text
		fingerStart:CGPointMake(4, 2), fingerEnd:CGPointMake(4, 2),
		helpText:@"helptext-3.png"
	},
	
	//LEVEL 4 - show how faster is better
	//HACK: the training for this level is customized in the setupFinger function
	//just because i didn't want to code all the logic to handle multiple positions for all the levels
	//and modify all the stuff that's already working
	{	level:4,newBlockType:0,
		maxBlocks:16,maxSpawn:1,minSpawn:1,
		types:1,states:1,
		maxInterval:8.0f,minInterval:3.5f,
		messages:{@"ready?",@"steady",@"go!"},
		
		//well defined starting board:
		board: {
			{0,0,0,0,0},
			{1,1,1,0,1},
			{0,0,0,0,0},
			{1,1,1,0,1},
			{0,0,0,0,0},
			{1,1,1,0,1}
		},
		
		//help finger position and text
		//fingerStart:CGPointZero, fingerEnd:CGPointZero,
		fingerStart:CGPointMake(3, 0), fingerEnd:CGPointMake(4, 0),		
		helpText:@"helptext-4.png"
	},
	
	//LEVEL 5 - try for a combo
	{	level:5,newBlockType:2,
		maxBlocks:20,maxSpawn:1,minSpawn:1,
		types:2,states:1,
		maxInterval:8.0f,minInterval:3.5f,
		messages:{@"ready?",@"steady",@"go!"},
			
			//well defined starting board:
		board: {
			{0,0,1,2,0},
			{0,0,0,1,2},
			{0,0,0,1,2},
			{0,0,0,1,2},
			{0,0,0,0,0},
			{0,0,0,0,0}
		},
			
			//help finger position and text
			//fingerStart:CGPointZero, fingerEnd:CGPointZero,
		fingerStart:CGPointMake(3, -1), fingerEnd:CGPointMake(4, -1),	
		helpText:@"helptext-5.png"
	}

};