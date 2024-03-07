//
//  LGAchievement.h
//  LostMonsters
//
//  Created by Jeff Cates on 6/11/11.
//  Copyright 2011 leftygames. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LGAchievement : NSObject {
	int _achievement;
	float _percentComplete;

}

//get and set the achievement
-(void) setAchievement:(int) achievement;
-(int) achievement;

//get and set the percent complete
-(void) setPercentComplete:(float) percentComplete;
-(float) percentComplete;

//return a new achievement with given percent complete and achievement id
+(id) achievementWithValues:(int) achievement:(float) percentComplete;


@end
