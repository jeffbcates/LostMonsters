//
//  Settings.h
//  testapp
//
//  Created by Jeff Cates on 1/10/11.
//  Copyright 2011 mrwired. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Settings : NSObject {
}

//internal - sets an object value
+(void) setObject:(NSString *) key:(NSObject *) value;
+(void) setBool:(NSString *)key :(bool)value;
+(void) setInt:(NSString *) key : (int) value;

//internal - get different types of values
+(NSString *) getString:(NSString *) key:(NSString *) defaultValue;
+(bool) getBool:(NSString *) key:(bool) defaultValue;
+(int) getInt:(NSString *) key:(int) defaultValue;

//get and set music  enabled
+(bool) getMusicEnabled;
+(void) setMusicEnabled:(bool) musicEnabled;

//get and set sound enabled
+(bool) getSoundEnabled;
+(void) setSoundEnabled:(bool) soundEnabled;

//get and set if tutorial is enabled
//this is cross-game compatible
+(bool) getTutorialEnabled;
+(void) setTutorialEnabled:(bool) tutorialEnabled;

//get an array from settings
+(NSMutableArray *) getArray:(NSString *) key;

//get and set the max score on this iphone
+(int) getMaxScore;
+(void) setMaxScore:(int) score;
+(bool) pushScore:(int) score:(NSString *) scoreType;



//get and set the # of unlocked monsters
+(int) getUnlockedMonsters;
+(void) setUnlockedMonsters:(int) monsterCount;

//get set bonus
+(void) incrementBonus;
+(int) useBonus;


//sync settings that were updated
+(void) sync;


@end
