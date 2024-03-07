//
//  ActorStack.h
//  LostMonsters
//
//	this is a visual list of sprites that get used and slide over
//	the poof off nd everything else
//
//  Created by Jeff Cates on 3/4/11.
//  Copyright 2011 leftygames. All rights reserved.
//

#import "BehavioralLayer.h"


@interface ActorStack : NSObject {
	//we can only perform one pop at a time
	//so we just stack them up here if we need to
	//the reason we can only do one at a time is that the sliding
	//actions get confused when you call them multiple times on each of the left over
	//actors.... resulting in actors that don't slide far enough down, (inconsistently)
	CCArray *pendingPops;
	CCArray *pendingAdds; //we can't add while we are popping either, because the position will be wrong
	bool _inPop; //are we currently in a pop operation?
	
	
	//testing:
	Actor *_pendingPops[32];
	int _pendingPopCount;
	
	//our list of actors that we manage
	CCArray *actors;
	
	//the spacing of actors in this visual stack
	//and the starting location
	int actorSpacer;
	CGPoint stackStart;
}

//initialize the actor stack
-(id) initWithSpacer:(int) spacer:(CGPoint) pos;

//return the # of items in our stack
-(uint) count;

//ways to push an actor to the stack
-(void) pushActor:(Actor *) actor;

//this gets called when a pop is complete
-(void) endPop;

//inspect actors with different properties
-(Actor *) actorAtIndex:(uint) idx;
-(Actor *) actorWithTag:(int) tag;
-(Actor *) actorWithType:(int) type;

//ways to pop an actor from the stack
-(void) popActor:(Actor *)actor;
-(void) popActor;
-(void) popActorAtIndex:(uint) idx;
-(void) popActorWithTag:(int)tag;
-(void) popActorWithType:(int) type;

//clear the stack
-(void) clear;

@end
