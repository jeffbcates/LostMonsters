//
//  LGAchievement.mm
//  LostMonsters
//
//  Created by Jeff Cates on 6/11/11.
//  Copyright 2011 leftygames. All rights reserved.
//

#import "LGAchievement.h"


@implementation LGAchievement

//get and set the achievement
-(void) setAchievement:(int) achievement {
	_achievement = achievement;
}

-(int) achievement {
	return _achievement;
}

//get and set the percent complete
-(void) setPercentComplete:(float) percentComplete {
	_percentComplete = percentComplete;
}
-(float) percentComplete {
	return _percentComplete;
}

//return a new achievement with given percent complete and achievement id
+(id) achievementWithValues:(int) achievement:(float) percentComplete {
	LGAchievement *newAchievement = [LGAchievement alloc];
	[newAchievement setAchievement:achievement];
	[newAchievement setPercentComplete:percentComplete];
	return [newAchievement autorelease];
}


@end
