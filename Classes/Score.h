//
//  Score.h
//  LostMonsters
//
//  Created by Jeff Cates on 3/4/11.
//  Copyright 2011 leftygames. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Score : NSObject {

}

//we have a numeric score and a date the score was accomplished
@property (nonatomic, assign) int score;
@property (nonatomic, assign) NSDate *date;

//from and to a pipe delimited string
-(NSString *) toString;
+(Score *) fromString:(NSString *)stringValue;

//return the descirption o this score as a string
-(NSString *)formatted;


@end
