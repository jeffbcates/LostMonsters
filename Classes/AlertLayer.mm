//
//  AlertLayer.mm
//  testapp
//
//  Created by Jeff Cates on 7/25/10.
//  Copyright 2010 catesgroup llc.  All rights reserved.
//


// Import the interfaces
#import "AlertLayer.h"

// HelloWorld implementation
@implementation AlertLayer


// initialize your instance here
-(void) startScene {
}

//actors do not respond to touch in this scene
-(bool) enableActorTouch {
	return false;
}

//but they do respond the tick event

@end
