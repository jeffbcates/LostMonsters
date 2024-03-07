/*
 *  PickConstants.h
 *  testapp
 *
 *  Created by Jeff Cates on 12/22/10.
 *  Copyright 2010 mrwired. All rights reserved.
 *	
 *	constants applied for the pick game
 *
 */

//#define BALL_TYPES 26

//#define BLOCK_FILE @"letters.png"

#define COL_WIDTH 62
#define ROW_HEIGHT 62
#define X_SPACER  ( (320 - (COL_WIDTH * COLS)) / 2 )
#define Y_SPACER 68 /*( (480 - 40 - (ROW_HEIGHT * ROWS)) / 2 )*/

/***these defines are calculated off the above ones***/

#define X_SPACE (COL_WIDTH/2+X_SPACER)
#define Y_SPACE_BOTTOM (ROW_HEIGHT/2+Y_SPACER)
#define Y_SPACE_TOP (480-ROWS*ROW_HEIGHT-Y_SPACER)

#define SPAWN_INTERVAL_MAX 8.0f
#define SPAWN_INTERVAL_MIN 3.0f
#define SPAWN_INTERVAL_DEC 0.02f
#define SPAWN_COUNT 0

//the following will spawn a bunch of blocks
//if there are not enough on the screen
#define MASS_SPAWN_THRESHOLD 6
#define MASS_SPAWN_COUNT 10
#define MASS_POINT_BONUS 50

//determine the min and max spawn counts
#define MIN_SPAWN_COUNT 1
#define MAX_SPAWN_COUNT 5


//these determine the spacing for alert messages
//so they are not too close to the sides
#define ALERT_SPACE_X 0
#define ALERT_SPACE_Y 0
