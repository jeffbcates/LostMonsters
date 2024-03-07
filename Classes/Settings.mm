//
//  Settings.mm
//  testapp
//
//  Created by Jeff Cates on 1/10/11.
//  Copyright 2011 mrwired. All rights reserved.
//

#import "Settings.h"
#import "Score.h"


@implementation Settings

//internal - sets a string value
+(void) setObject:(NSString *) key:(NSObject *) value {
	//debug information
	//NSLog(@"Settings: set %@ = %@",key,(NSString *) value);
	
	//update key value
	[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

//internal - get an array value
+(NSMutableArray *) getArray:(NSString *) key {
	//get return value
	NSMutableArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	
	//return to user
	return results;
	
}

+(void) setArray:(NSString *) key :(NSMutableArray *) value {
	[self setObject:key :value];
}

//internal - get a string value
+(NSString *) getString:(NSString *) key:(NSString *) defaultValue {
	//get return value
	NSString *results = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	
	//update default value if not found
	if (results == nil) results = defaultValue;
	
	//testing:
	//NSLog(@"Settings Get %@ = %@",key,results);
	
	//return to user
	return results;
	
}

//internal - set a bool value
+(void) setBool:(NSString *) key:(bool) value {
	//set a string value based on the boolean
	[self setObject:key :[NSString stringWithFormat:@"%i",value]];	
}

//internal - set an int value
+(void) setInt:(NSString *) key: (int) value {
	//set a string based on the int value
	[self setObject:key:[NSString stringWithFormat:@"%i",value]];
}

//internal - get a string value
+(bool) getBool:(NSString *) key:(bool) defaultValue {
	//get return value
	NSString *results = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	bool returnValue = defaultValue;
	
	//update default value if not found
	if (results != nil) {
		returnValue = [results intValue]; //yes or no
	}
	
	//testing:
	//NSLog(@"Settings Get %@ = %@",key,results);
	
	
	
	//return to user
	return returnValue;
	
}

//get an integer value
+(int) getInt:(NSString *) key:(int) defaultValue {
	//get return value
	NSString *results = [[NSUserDefaults standardUserDefaults] objectForKey:key];
	int returnValue = defaultValue;
	
	//update default value if not found
	if (results != nil) {
		returnValue = [results intValue]; //yes or no
	}
	
	//testing:
	//NSLog(@"Settings Get %@ = %@",key,results);
	
	//return to user
	return returnValue;
	
}

+(int) getUnlockedMonsters {
	//return that value
	return [self getInt:@"unlockedMonsters":0];
	
}

+(void) setUnlockedMonsters:(int) monsterCount {
	//update the monster count
	[self setInt:@"unlockedMonsters" :monsterCount];
}

+(int) getMaxScore {
	//return that value
	return [self getInt:@"maxScore":0];
	
}

+(void) setMaxScore:(int) score {
	//update the score value
	[self setInt:@"maxScore":score];
}


//get and set if music is enabled
+(bool) getMusicEnabled {
	//return that value
	return [self getBool:@"musicEnabled":true];
	
}
+(void) setMusicEnabled:(bool) musicEnabled {
	//save this value using generic bool setter
	
	[self setBool:@"musicEnabled" :musicEnabled];
}

//get and set if sound is enabled
+(bool) getSoundEnabled {
	//return that value
	return [self getBool:@"soundEnabled":true];
	
}

+(void) setSoundEnabled:(bool) soundEnabled {
	//save this value using generic bool setter

	[self setBool:@"soundEnabled" :soundEnabled];
}

//get and set if sound is enabled
+(bool) getTutorialEnabled {
	//return that value
	return [self getBool:@"tutorialEnabled":true];
	
}

+(void) setTutorialEnabled:(bool) tutorialEnabled {
	//save this value using generic bool setter
	
	[self setBool:@"tutorialEnabled" :tutorialEnabled];
}

+(void) sync {
	//syncs settings with our changes
	[[NSUserDefaults standardUserDefaults] synchronize];
}



//push a single high score against the stack
//it will "stick" if appropriate
//if it does stick we return true

+(bool) pushScore:(int) score:(NSString *) scoreType {
	//first get the array of high scores
	NSMutableArray *scores = [self getArray:scoreType];

	//are there no scores at all?
	if ( scores == nil ) scores = [[[NSMutableArray alloc] init] autorelease];
	
	//what is the appropriate index of this score?
	uint idx = 0;
	bool found = false;
	while (!found && [scores count] > idx) {
		//get the score at this index
		Score *currentScore = [Score fromString:[scores objectAtIndex:idx]];
		
		//check this one
		if ( [currentScore score] < score ) {
			//this is it
			found = true;
		} else {
			//check next
			idx++;
		}
	}

	//as long as its within the top 10
	if ( idx <= 10 ) {
		//create a new score object
		Score *newScore = [[Score alloc] autorelease];
		[newScore setScore:score];
		NSDate *now = [NSDate date];
		[newScore setDate:now];
		
		//insert this score at that location
		[scores insertObject:[newScore toString] atIndex:idx];
		
		//strip off the 11th item
		while ( [scores count] > 10 ) {
			//remove the last item in the array (11th item is at index 10)
			[scores removeObjectAtIndex:10];
		}

		//update high scores in settings
		//and sync so they are saved right away
		//we don't want to take a chance with the score 
		[self setArray:scoreType:scores];
		[self sync];

		return true;
	}
			 
	return false;
	
}

//get set bonus
+(void) incrementBonus {
	//get current bonus
	int currentBonus = [Settings getInt:@"social_bonus" :0];
	currentBonus++;
	
	//save back
	[Settings setInt:@"social_bonus":currentBonus];
	
	
}

+(int) useBonus {
	//get current bonus
	int currentBonus = [Settings getInt:@"social_bonus" :0];
	
	//clear it now
	[Settings setInt:@"social_bonus":0];
	
	//return that bonus
	return currentBonus;
	
}



@end
