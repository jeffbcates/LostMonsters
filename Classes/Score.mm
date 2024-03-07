//
//  Score.mm
//  LostMonsters
//
//  Created by Jeff Cates on 3/4/11.
//  Copyright 2011 leftygames. All rights reserved.
//

#import "Score.h"


@implementation Score

//basic properties used in serialization to user settings
@synthesize score, date;


//return the date as a formatted string
-(NSString *) formattedDate {
	//setup a date formatter to display this date
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	
	//get the results
	NSString *results = [formatter stringFromDate:date];
	
	//now change formatter to long date to get the 
	//we are done with the date formatter and our little string
	[formatter release];
	
	//return that string
	return results;
	
}


//from a string (delimited
+(Score *) fromString:(NSString *) stringValue {
	//create a new score
	Score *newScore = [[Score alloc] autorelease];
	
	//split the incoming string
	NSArray *comps = [stringValue componentsSeparatedByString:@"|"];
	
	//set the individual parts - don't worry about checking here
	//shouldn't have an issue
	[newScore setScore: [[comps objectAtIndex:0] intValue]];
	//[newScore setDate: [comps objectAtIndex:1]];
	
	//get the date from a string
	//setup a date formatter to display this date
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	
	//get the results
	NSDate *dateVal = [formatter dateFromString:[comps objectAtIndex:1]];
	
	//now change formatter to long date to get the 
	//we are done with the date formatter and our little string
	[formatter release];
	
	//update the date value we got
	[newScore setDate:dateVal];
	
	//return that new score
	return newScore;
}

-(NSString *) toString {
	//return a string with our parts
	return [NSString stringWithFormat:@"%i|%@",score,[self formattedDate]];
}

//return the descirption o this score as a string
-(NSString *) formatted {
	//return a string formatted with score and date
	return [NSString stringWithFormat:@"%i on %@",score,[self formattedDate]];
}


@end
