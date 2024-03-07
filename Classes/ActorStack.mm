//
//  ActorStack.mm
//  LostMonsters
//
//  Created by Jeff Cates on 3/4/11.
//  Copyright 2011 leftygames. All rights reserved.
//

#import "ActorStack.h"


@implementation ActorStack

//pop a specific actor
-(void) popActor:(Actor *) actor {
	//quit if not found
	if (actor == nil ) return;
	
	//if we are currently in a pop operation
	//then just schedule this for later
	if ( _inPop) {
		//add this to the pending pop list
		//but only if its not already in the list
		//since we shouldn't pop something twice
		//which would cause some big problems for us
		if ( ! [pendingPops containsObject:actor] ) {
			[pendingPops addObject:actor];
		}
		
		return;		
	}
	
	//now we are "in a pop"
	_inPop = true;
	
	//trigger a slick little action so the guy puffs up then shrinks down
	//and then disappears
	[[actor mainSprite] runAction:[CCSequence actions:
								   [CCScaleTo actionWithDuration:0.1f scale:0.8f],
								   [CCScaleTo actionWithDuration:0.1f scale:0.0f],
								   nil
								   ]];
	
	//kill the actor after a slight delay
	//just slightly after it disappears from the scene
	[[actor scene] performSelector:@selector(removeActor:) withObject:actor afterDelay:0.42f];
	
	//remove from array and replace with a nil
	//note: should finde a better way to do this
	//i need to modify the CCArray object to allow "replaceObject', which
	//would be more efficient, but low on priority list right now
	int idx = [actors indexOfObject:actor];
	[actors removeObjectAtIndex:idx];
	
	//this will store the last delay time which we use in calling endPop
	ccTime lastDelay = 0;
	
	//slide all of the statuses after this status down 1
	for (uint c = idx; c < [actors count]; c++ ) {
		//calculate delay time
		lastDelay = 0.1f + (c-idx) * 0.1f;
		
		//kick off an action to slide this guy down
		[[(Actor *)[actors objectAtIndex:c] mainSprite] runAction:
		 [CCSequence actions:
		  //wait a moment and then slide over
		  //note each subsequent monsters waits a moment as well
		  //this creates a very natural movement
		  //we should also move slightly too far and then back up a bit
		  [CCDelayTime actionWithDuration:lastDelay],
		  [CCEaseElastic actionWithAction:[CCMoveBy actionWithDuration:0.25f position:ccp(-1 * actorSpacer * 1.1f,0)] period:2 ],
		  [CCEaseElastic actionWithAction:[CCMoveBy actionWithDuration:0.05f position:ccp(1 * actorSpacer * 0.2f,0)] period:2 ],
		  [CCEaseElastic actionWithAction:[CCMoveBy actionWithDuration:0.05f position:ccp(-1 * actorSpacer * 0.1f,0)] period:2 ],
		  
		  nil
		  ]];
	}
	
	//call end pop after all the actions are done
	[self performSelector:@selector(endPop) withObject:nil afterDelay:lastDelay + 0.35f + 0.05f];
}

//pop the first actor in the stack
-(void) popActor {
	//pop the first actor if there is one
	[self popActorAtIndex:0];
}

//this is at the end of the pop and will trigger any pending pop operations
-(void) endPop {
	//we are no longer popping
	_inPop = false;
	
	
	//fire all the pending adds now, get them done
	while ( [pendingAdds count] > 0 ) {
		//remove this guy from the pending list and push him in right now
		Actor *firstActor = (Actor *) [pendingAdds objectAtIndex:0];
		[self pushActor:firstActor];
		[pendingAdds removeObjectAtIndex:0];
	}
	
	if ( [pendingPops count] > 0) {
		//get a reference to the first actor to pop
		//and remove it from our popping array
		Actor *firstActor = [pendingPops objectAtIndex:0];
		[pendingPops removeObjectAtIndex:0];
		
		//visually pop the actor now
		[self popActor:firstActor];		
	}
}



//pop an item off the stack
//this will pop a completed status off the menu
-(void) popActorAtIndex:(uint) idx {
	//get actor at index	
	Actor *actor = [actors objectAtIndex:idx];
	
	//pop the actor
	[self popActor:actor];
}

//get the index based on the tag
//get thge index based on the type
-(int) indexWithTag:(int) tag {
	//find the status with the given tag
	int idx = -1;
	for (uint c = 0; c < [actors count]; c++ ) {
		//is this it?
		if ( [(Actor *)[actors objectAtIndex:c] tag] == tag ) {
			//we found it - break the loop
			idx = c;
			break;
		}
	}
	return idx;
	
}

//get the index based on the tag
//get thge index based on the type
-(int) indexWithType:(int) type {
	//find the status with the given tag
	int idx = -1;
	for (uint c = 0; c < [actors count]; c++ ) {
		//is this it?
		if ( [(Actor *)[actors objectAtIndex:c] getType] == type ) {
			//we found it - break the loop
			idx = c;
			break;
		}
	}
	return idx;	
}


//pop an item off the stack
//this will pop a completed status off the menu
-(void) popActorWithTag:(int) tag {
	//get the index
	int idx = [self indexWithTag:tag];
	
	//quit if not found
	if (idx < 0 ) return;
	
	//pop with that index
	[self popActorAtIndex:(uint)idx];
}

//pop an item off the stack
//this will pop given the type of the actor
-(void) popActorWithType:(int) type {
	//get the index
	int idx = [self indexWithType:type];
	
	//quit if not found
	if (idx < 0 ) return;
	
	//pop with that index
	[self popActorAtIndex:(uint)idx];
}


//inspect actors with different properties
-(Actor *) actorAtIndex:(uint) idx {
	if ( idx < 0 || idx > [actors count]-1 || [actors count] == 0) {
		return nil;
	}
	return [actors objectAtIndex:idx];
}
-(Actor *) actorWithTag:(int) tag {
	int idx = [self indexWithTag:tag];
	return [self actorAtIndex:idx];
	
}
-(Actor *) actorWithType:(int) type {
	int idx = [self indexWithType:type];
	return [self actorAtIndex:idx];
}

//add a new status for a specific block type
-(void) pushActor:(Actor *) actor {
	//if we are in a pop, then save this for later
	//TODO: revisit this - do we need to push adds into a pending array, or can we do them immediately
	if ( false ) {
		//and to a pending add list, we will add the second the pop is done
		[pendingAdds addObject:actor];
		return;
	}
	
	//add to our array
	//and retrieve location and scale
	[actors addObject:actor];
	uint idx = [actors count]-1;
	CGFloat scale = [[actor mainSprite] scale];
	
	//we determine the position
	[actor setPosition:CGPointMake(stackStart.x+idx*actorSpacer, stackStart.y)];
	
	//run a little opening animation to make ourselves look sweet and cool
	CCSprite *actorSprite = [actor mainSprite];
	[actorSprite setScale:0.00];
	[actorSprite runAction:[CCSequence actions:			
		[CCDelayTime actionWithDuration:idx * 0.1f + 0.25f],
		[CCEaseElastic actionWithAction:[CCScaleTo actionWithDuration:0.1f scale:scale] period:0.1],
		[NamedAction Pulsate:0.2f:2:scale],							
		nil
	]];

	//that's it - we have added a sprite
}


//clear the stack without popping
-(void) clear {
	//kill any existing statuses if they are there at all
	while ([actors count] > 0) {		
		//kill this actor
		if ( [actors objectAtIndex:0] != nil ) {
			Actor * actor = [actors objectAtIndex:0];
			[[actor scene] removeActor:actor];
		}
		
		//pop off array
		[actors removeObjectAtIndex:0];
	}
	
}

//return the # of items in our stack
-(uint) count {
	//simple - from actor array
	return [actors count];
}


//initialize the stack
-(id) initWithSpacer:(int) spacer :(CGPoint) pos{
	//set the spacer
	actorSpacer = spacer;
	stackStart = pos;	
	
	//create the actor array
	actors = [[CCArray alloc] init];
	pendingPops = [[CCArray alloc] init];
	pendingAdds = [[CCArray alloc] init];
	
	//return ourselves
	return self;
}

//clean up
-(void) dealloc {
	//kill actor array
	[actors release];
	[pendingPops release];
	[pendingAdds release];
	
	//clean up super
	[super dealloc];
}

@end
