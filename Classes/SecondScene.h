//
//  HelloWorldScene.h
//  testapp
//
//  Created by Joe Free on 7/25/10.
//  Copyright 2010 catesgroup llc. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "BehavioralLayer.h"

//*****INTERNVALS*****/

#define SPAWN_INTERVAL_REDUCER 0.2f
#define SPAWN_INTERVAL_START 5.0f
#define SPAWN_INTERVAL_MIN 1.5f
#define SPAWN_COUNT_START 2


@interface SecondScene : BehavioralLayer <BehavioralLayer> {
	
	
	//testing: quickly toggle settings
	bool immediateOnlyCache;	
	
	//scene level actors
	CCSpriteSheet *blockSheet;
	
	//primary actors
	Actor *points;
	
	//spawn count
	int spawnCount;
	float spawnInterval; //how long to wait between spawns
	
	//max types of colors
	int maxTypes;
	
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

// adds a new sprite at a given coordinate
-(Actor *) addNewSpriteWithCoords:(CGPoint)p;

//add a random sprite
-(void) addRandomSprite;
-(void) configure:(bool) immediateOnly;


@end
