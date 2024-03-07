//
//  HelloWorldScene.mm
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces
#import "ThoughtfulScores.h"

// HelloWorld implementation
@implementation ThoughtfulScores

//only change 3 things - title and score type, plus scene method
-(NSString *) scoreType {
	return @"thoughtfulScores";
}
-(NSString *) title {
	return @"Thoughtful";
}


+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ThoughtfulScores *layer = [ThoughtfulScores node];
	
	// add layer as a child to scene
	//[scene addChild: back];
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


@end
