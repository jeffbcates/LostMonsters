//
//  HelloWorldScene.h
//  testapp
//
//  Created by Joe Free on 7/25/10.
//  Copyright 2010 catesgroup llc. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h" 
#import "GLES-Render.h"
#import "BoxListener.h"
#import "Actor.h"
#import "Behaviors.h"
#import "BehavioralScene.h"

@interface HelloScene : BehavioralScene <BehavioralScene> {
	//scene level actors
	CCSpriteSheet *blockSheet;
	
	
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

// adds a new sprite at a given coordinate
-(b2Body *) addNewSpriteWithCoords:(CGPoint)p;

@end

/**** OLD POINTS CODE ****
 
 //track basics like banana count
 CCLabel	*pointsLabel;
 int points;
 
 //setup points counter on the screen
 pointsLabel = [CCLabel labelWithString:@"Points: 0" fontName:@"Marker Felt" fontSize:16];
 points = 0; //start with no points
 [self addChild:pointsLabel z:0];
 [pointsLabel setColor:ccc3(0,0,255)];
 pointsLabel.position = ccp( screenSize.width - 50, screenSize.height-20);
 
 
 //here a monkey died so we start over 
 -(void) failedGame {
 //just start over for now
 points = 0;
 [pointsLabel setString:@"You Lose"];
 
 }
 
 //add a number of points
 -(void) addPoints:(int) newPoints {
 //add to the points
 points += newPoints;
 
 //get the points label
 NSString *newPointsLabel = [NSString stringWithFormat:@"Points: %i",points];
 
 //update the label
 [pointsLabel setString:newPointsLabel];
 }
 
 
 
**** OLD POINTS CODE ****/